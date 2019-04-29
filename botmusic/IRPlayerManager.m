//
//  IRPlayerManager.m
//  botmusic
//
//  Created by Илья Романеня on 30.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "IRPlayerManager.h"
#import "IRNetworkClient.h"
#import "MFNotificationManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FeedViewController.h"
#import "MFConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Mixpanel.h>
#import "NSMutableArray+MFShuffling.h"
#import "MFPlaylistItem+Behavior.h"
#import "MagicalRecord/MagicalRecord.h"

const NSString* soundcloudUserID = @"7c8ddbf46678a7f03b1c064e257e9632";
const CGFloat   IRPlayerDefaultDelayAfterFail = 1.5;

@interface IRPlayerManager()
@property (nonatomic) BOOL isManualBuffering;
@property (nonatomic, strong) AVPlayer* AVplayer;
@property (nonatomic, strong) SPTAudioStreamingController* spotifyPlayer;
@property (nonatomic, strong) SPTTrack* currentSpotifyTrack;

@property (nonatomic, strong) NSArray* tracks;

@property (nonatomic, readwrite, assign) BOOL playing;
@property (nonatomic, readwrite, assign) BOOL haveTrack;
@property (nonatomic, readwrite, assign) BOOL loading;

@property (nonatomic, strong) NSString* currentTrackType;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isManualPause;

@property (nonatomic, assign) BOOL isReversePlayingDirection;
@property (nonatomic, strong) NSTimer* loadingTimer;

@property (nonatomic, assign) BOOL isDelayBeforeNext;

@property (nonatomic, strong) UIImage *currentArtwork;

@property (nonatomic, strong) MFTrackItem* notificatedTrack;

// YES if track was interrupted after lose network connection
@property (nonatomic, getter=isInterrupted) BOOL interrupted;
@property (nonatomic) NSTimeInterval trackTimeBeforeInterruption;

@property (nonatomic) BOOL isLoggingInSpotify;
@property (nonatomic) NSInteger interruptionsCount;
@end

@implementation IRPlayerManager

+ (IRPlayerManager *)sharedInstance
{
    static IRPlayerManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[IRPlayerManager alloc] init];
                  });
    return sharedInstance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

- (id)init
{
    if (self = [super init])
    {
        self.haveTrack = NO;
        self.playing = NO;
        self.isReversePlayingDirection = NO;
        self.isDelayBeforeNext = NO;
        self.currentTrackIndex = 0;
        [self setReachabilityNotifications];
        if (self.delegateVC)
        {
            [self.delegateVC playbackAvailable:NO];
        }
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPlayToEnd) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPlayToEnd) name:AVPlayerItemPlaybackStalledNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        self.upNextPlaylist = [MFPlaylistItem MR_findFirstByAttribute:@"itemId" withValue:@"MF_UP_NEXT_PLAYLIST"];
        if (!self.upNextPlaylist) {
            self.upNextPlaylist = [MFPlaylistItem MR_createEntity];
            self.upNextPlaylist.itemId = @"MF_UP_NEXT_PLAYLIST";
            self.upNextPlaylist.songs = [[NSOrderedSet alloc] init];
            self.upNextPlaylist.isPrivate = YES;
        }
        self.upNextPlaylist.title = NSLocalizedString(@"Up Next", nil);
    }
    
    return self;
}

#pragma mark - Interruptions

- (void)handleAudioSessionInterruption:(NSNotification*)notification {
    
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
            // • Audio has stopped, already inactive
            // • Change state of UI, etc., to reflect non-playing state
            [self pauseTrack];
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                // Here you should continue playback.
                [self pauseTrack];
            }
        } break;
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        NSLog(@"Rate = %f", self.AVplayer.rate);
    }
}

#pragma mark - Player create/remove methods

- (void)createAVPlayer{
    
    if(!self.AVplayer){
        self.AVplayer = [[AVPlayer alloc]init];
    
//        [self.AVplayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeAVPlayer{
    
    if(self.AVplayer){
        [self.AVplayer replaceCurrentItemWithPlayerItem:nil];
//        [self.AVplayer removeObserver:self forKeyPath:@"status" context:nil];
        
        self.AVplayer=nil;

    }
}

- (void)createSpotifyPlayer{
    
    if(self.spotifyPlayer == nil){
        self.spotifyPlayer=[[SPTAudioStreamingController alloc] initWithClientId:kMFSpotifyClientID];
        //self.spotifyPlayer.delegate=self;
    }
}

- (void)removeSpotifyPlayer{
    
    if(self.spotifyPlayer){
        [self.spotifyPlayer stop:^(NSError* error){
            self.spotifyPlayer.delegate=nil;
            
            //self.spotifyPlayer=nil;
        }];
        //[self.spotifyPlayer playTrackProvider:nil callback:^(NSError* error){
        //}];
    }
}

- (void)removeYoutubePlayer{
    if (self.baseYoutubePlayer) {
        [self.videoPlayer stopVideo];
        [self.videoPlayer clearVideo];
    }
}

#pragma mark - Play track

- (void)playTracks:(NSArray*)tracks trackIndex:(NSUInteger)index
{
    if (!_startedPlayingFirstTime && tracks.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playerFirstTimeAppears" object:nil];
        _startedPlayingFirstTime = YES;
    }
    [self stopTrack];
    if (_currentTrackIndex < [_tracks count]) {
        self.currentTrack.trackState = IRTrackItemStateNotStarted;
    }
    self.tracks = [tracks copy];
    self.currentTrackIndex = index;
    
    if (self.currentTrack) {
        [self playTrack];
    }
}

- (void)playTrack
{
    if (!self.currentTrack) return;
    _isDelayBeforeNext = NO;
    self.haveTrack = NO;
    self.isManualPause = NO;
    self.interrupted = NO;
    
    //TODO loading state
    if ([[Reachability reachabilityForInternetConnection] isReachable]){
        self.currentTrack.trackState = IRTrackItemStateLoading;
        [self.loadingTimer invalidate];
        self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(trackStillLoading:) userInfo:nil repeats:NO];
    }
    else self.currentTrack.trackState = IRTrackItemStateFailed;
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.currentTrack.trackPicture] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (image && finished) {
            self.currentArtwork = image;
            
        } else {
            self.currentArtwork = nil;
        }
    }];
    
    if (self.delegateVC)
    {
        if (self.currentTrack.trackState != IRTrackItemStateFailed){
            [self.delegateVC playbackAvailable:YES];
        } else {
            [self.delegateVC playbackAvailable:NO];
        }
        [self.delegateVC startPlayingTrack:self.currentTrack];
    }
    if (self.preparationVC) {
        [self.preparationVC didStartTrack:self.currentTrack afterTrack:nil];
    }
    
    [self startUpdateProgress];
    
    if (self.currentTrack != self.notificatedTrack) {
        self.notificatedTrack = self.currentTrack;
        [dataManager updateTrackPlayedTime:self.currentTrack];
        [[Mixpanel sharedInstance] track:@"Track played" properties:@{@"trackID": self.currentTrack.itemId,
                                                                      @"authorID": self.currentTrack.authorId}];
        [FBSDKAppEvents logEvent:@"Track played" parameters:@{@"trackID": self.currentTrack.itemId,
                                                              @"authorID": self.currentTrack.authorId}];
    }
    
    //[self checkIfVolumeTurnOff];
    
    if ([self.currentTrackType isEqualToString:feedTypeYoutube] || [self.currentTrackType isEqualToString:feedTypeGrooveshark] || [self.currentTrackType isEqualToString:feedTypeShazam])
    {
        [self playYoutubeTrack];
    }
    else if ([self.currentTrack isSpotifyTrack])
    {
        [self playSpotifyTrack];
    }
    else if ([self.currentTrack isSoundcloudTrack])
    {
        [self playSoundcloudTrack];
    }
    else if ([self.currentTrack isMixcloudTrack])
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           NSURL *mp3URL = [NSURL URLWithString:self.currentTrack.stream];
                           [self createAVPlayer];
//                           self.AVplayer = [[AVPlayer alloc] initWithPlayerItem:[AVPlayerItem playerItemWithURL:mp3URL]];
                           
//                           [self.AVplayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
                           [self.AVplayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:mp3URL]];
                           
                           [self.AVplayer play];
                           [self playbackStarted];
                       });
        
//        [[UIApplication sharedApplication] openURL:url];
//        
//        [self stopAllSources];
//        [NSObject showErrorMessage:[NSString stringWithFormat:@"Cannot play from %@", self.currentTrackType]];
    }
}

- (void)playYoutubeTrack {
    [self.baseYoutubePlayer loadVideoWithId:self.currentTrack.videoID];
}

- (void)playSpotifyTrack
{
    SPTSession *session=[userManager spotifySession];
    
    if (session) {
        // We have a session stored.
        if ([session isValid]) {
            
            if (self.spotifyPlayer == nil) {
                self.spotifyPlayer = [[SPTAudioStreamingController alloc] initWithClientId:kMFSpotifyClientID];
                self.spotifyPlayer.playbackDelegate = self;
            }
            // It's still valid, enable playback.
            
            if (!self.isLoggingInSpotify) {
                self.isLoggingInSpotify = YES;
                
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"spotifyLoginErrorNotPremium"] isEqualToNumber:@1]) {
                    NSLog(@"Can't play spotify track");
                    [self playbackNotStarted:@"Can't play spotify track"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"spotifyNotPremiumError" object:nil];
                    //[self playSpotifyAfterLogin:session];
                    self.isLoggingInSpotify = NO;
                }
                else {
                    if (self.spotifyPlayer.loggedIn) {
                        self.isLoggingInSpotify = NO;
                        [self playSpotifyAfterLogin:session];
                    } else {
                        [self.spotifyPlayer loginWithSession:session callback:^(NSError *error) {
                            
                            self.isLoggingInSpotify = NO;
                            
                            if (error != nil) {
                                NSLog(@"Can't play spotify track");
                                [self playbackNotStarted:@"Can't play spotify track"];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"spotifyNotPremiumError" object:nil];
                                [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"spotifyLoginErrorNotPremium"];
                            } else {
                                [self playSpotifyAfterLogin:session];
                            }
                        }];
                    }
                }
            }
        } else {
            // Oh noes, the token has expired.
            [self.loadingTimer invalidate];
            [userManager loginInSpotify];
            // If we're not using a backend token service we need to prompt the user to sign in again here.
//            [userManager refreshSpotifySessionWithCallback:^(NSError* error){
//                if (error != nil) {
//                    [self playTrackAfterError];
//                }
//                else {
//                    [self playSpotifyAfterLogin:session];
//                }
//            }];
        }
    } else {
        // We don't have an session, prompt the user to sign in.
        //[self playbackNotStarted:nil];
        [self.loadingTimer invalidate];
        [userManager loginInSpotify];
    }
}

- (void)playSpotifyAfterLogin:(SPTSession *)session
{
    NSString *trackLink=self.currentTrack.link;
    trackLink=[trackLink substringFromIndex:30];
    
    [SPTTrack trackWithURI:[NSURL URLWithString:[NSString stringWithFormat:@"spotify:track:%@",trackLink]]
                     session:session
                        callback:^(NSError *error, id object) {
                            
                            if (error != nil) {
                                NSLog(@"*** Album lookup got error %@", error);
                                return;
                            }
                            
                            STrack *track=[[STrack alloc]initWithTrack:(SPTTrack*)object];
                            
                            [self createSpotifyPlayer];
                            if (self.spotifyPlayer != nil) {
                                [self.spotifyPlayer playTrackProvider:(id <SPTTrackProvider>)track.track callback:^(NSError* error){
                                    if (error != nil) {
                                        NSLog(@"Can't play spotify track");
                                        [self playbackNotStarted:@"Can't play spotify track"];
                                        self.isManualTrackSwitching = NO;
                                    }
                                    else {
                                        [self playbackStarted];
                                        self.isManualTrackSwitching = NO;
                                    }
                                }];
                                
                                self.currentSpotifyTrack=(SPTTrack*)object;
                            }
                            
                        }];
}

- (void)playSoundcloudTrack{
    NSDictionary* param = @{@"url": self.currentTrack.link, @"client_id": soundcloudUserID};
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:@"https://api.soundcloud.com/resolve.json"]
             usingParameters:param
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error)
         {
             NSLog(@"SoundCloud play track error: %@", error.localizedDescription);
             [self playbackNotStarted:@"Cannot play SoundCloud track"];
         }
         else
         {
             NSError *jsonError = nil;
             NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                                  JSONObjectWithData:data
                                                  options:0
                                                  error:&jsonError];
             if (!jsonError && [jsonResponse isKindOfClass:[NSDictionary class]])
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    NSLogExt(@"%@",jsonResponse);
                                    NSString *streamURL = [(NSDictionary*)jsonResponse objectForKey:@"stream_url"];
                                    NSArray* streamComponents = [streamURL componentsSeparatedByString:@"?secret_token="];
                                    NSString *urlString = [NSString stringWithFormat:@"%@?client_id=%@", streamComponents[0], soundcloudUserID];
                                    
                                    if (streamURL == nil)
                                    {
                                        NSLog(@"SoundCloud play track error: stream url is nil");
                                        [self playbackNotStarted:@"Cannot play SoundCloud track"];
                                    }
                                    
                                    
                                    
                                    [self createAVPlayer];
                                    [self.AVplayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlString]]];
                                    
                                    [self.AVplayer play];
                                    [self playbackStarted];
                                });
             }
             else
             {
                 [self playbackNotStarted:@"Cannot play SoundCloud track"];
                 NSLog(@"SoundCloud play track error: %@", jsonError.localizedDescription);
             }
         }
     }];
}

#pragma mark - Other controls

- (void)resumeTrack
{
    self.playing = YES;
    
    self.isManualPause = NO;
    
    [self startUpdateProgress];
    
    if (self.haveTrack) {
        if ([self.currentTrack isSpotifyTrack]) {
            [self.spotifyPlayer setIsPlaying:YES callback:nil];
        } else if ([self.currentTrack isSoundcloudTrack] || [self.currentTrack isMixcloudTrack]) {
            [self.AVplayer play];
        } else {
            if (self.isInterrupted) {
                if ([IRNetworkClient isReachable]) {
                    self.isManualTrackSwitching = YES;
                    [self.videoPlayer changeToNativePlayer];
                    
                    [self playTrack];
                    self.interrupted = YES;
                }
            } else {
                [self.baseYoutubePlayer play];
            }
        }
    }
    
    if (self.delegateVC)
    {
        [self.delegateVC resumeTrack];
    }
    
    if (self.preparationVC && [self.preparationVC respondsToSelector:@selector(didResumeTrack:)]) {
        [self.preparationVC didResumeTrack:self.currentTrack];
    }
    
    self.currentTrack.trackState = IRTrackItemStatePlaying;
}

- (void)pauseTrack
{
    self.playing = NO;
    [self stopUpdateProgress];
    
    self.isManualPause=YES;
    
    if (self.haveTrack)
    {
        if([self.currentTrack isSpotifyTrack])
        {
            [self.spotifyPlayer setIsPlaying:NO callback:nil];
        }
        else if([self.currentTrack isSoundcloudTrack] || [self.currentTrack isMixcloudTrack])
        {
            [self.AVplayer pause];
        }
        else
        {
            [self.baseYoutubePlayer pause];
        }
    }
    if (self.delegateVC)
    {
        [self.delegateVC pauseTrack];
    }
    
    if (self.preparationVC && [self.preparationVC respondsToSelector:@selector(didPauseTrack:)]) {
        [self.preparationVC didPauseTrack:self.currentTrack];
    }
    
    self.currentTrack.trackState = IRTrackItemStatePaused;
}

- (void)nextTrack
{
    [self stopTrack];
        [self.videoPlayer changeToNativePlayer];
        
        _isDelayBeforeNext = NO;
        self.playing = NO;
        
        if ([IRNetworkClient isReachable]) {
            if (self.tracks.count != 0)
            {
                // self.isReversePlayingDirection = NO;
                NSUInteger prevIndex = self.currentTrackIndex;
                if (self.currentTrack.trackState != IRTrackItemStateFailed) {
                    self.currentTrack.trackState = IRTrackItemStateNotStarted;
                }
                //BOOL stopPlaying = NO;
                if (self.isPlayingPlaylist) {
                    self.currentTrackIndex = (self.currentTrackIndex + 1) % self.tracks.count;
                } else {
                    self.currentTrackIndex = 0;
                    if (self.nowPlayingQueue.count>1) {
                        self.nowPlayingQueue = [self.nowPlayingQueue subarrayWithRange:NSMakeRange(1, self.nowPlayingQueue.count - 1)];
                    } else {
                        //stopPlaying = YES;
                    }
                    self.tracks = [self.nowPlayingQueue copy];
                }
                if (self.currentTrack.trackState != IRTrackItemStateFailed) {
                    self.currentTrack.trackState = IRTrackItemStatePlaying;
                    [self playTrack];

                    if (self.preparationVC && [self.preparationVC respondsToSelector:@selector(didStartTrackAtIndex:afterTrackAtIndex:)]) {
                        [self.preparationVC didStartTrackAtIndex:self.currentTrackIndex afterTrackAtIndex:prevIndex];
                    }
                    if (self.preparationVC && [self.preparationVC respondsToSelector:@selector(didStartTrack:afterTrack:)] && prevIndex < _tracks.count) {
                        [self.preparationVC didStartTrack:self.currentTrack afterTrack:_tracks[prevIndex]];
                    }
                }
            }
        }
        else {
            [MFNotificationManager postNetworkNotification];
        }
    
}

- (void)prevTrack
{
    [self stopTrack];
    [self.videoPlayer changeToNativePlayer];
    
    _isDelayBeforeNext = NO;
    if (self.tracks.count != 0)
    {
        // self.isReversePlayingDirection = YES;
        NSUInteger prevIndex = self.currentTrackIndex;
        self.currentTrack.trackState = IRTrackItemStateNotStarted;
        if (self.currentTrackIndex==0) {
            self.currentTrack.trackState = IRTrackItemStatePlaying;
            [self playTrack];
        }
        else {
            if (self.isPlayingPlaylist) {
                self.currentTrackIndex = (self.currentTrackIndex - 1) % self.tracks.count;
            } else {

            }
            self.currentTrack.trackState = IRTrackItemStatePlaying;
            [self playTrack];
            
            if (self.preparationVC && [self.preparationVC respondsToSelector:@selector(didStartTrackAtIndex:afterTrackAtIndex:)]) {
                [self.preparationVC didStartTrackAtIndex:self.currentTrackIndex afterTrackAtIndex:prevIndex];
            }
            if (self.preparationVC && [self.preparationVC respondsToSelector:@selector(didStartTrack:afterTrack:)]) {
                [self.preparationVC didStartTrack:self.currentTrack afterTrack:_tracks[prevIndex]];
            }
        }
    }
}

- (void)stopTrack
{
    [self stopAllSources];
    [self stopUpdateProgress];
    self.currentTrack.trackState = IRTrackItemStateNotStarted;
}

-(void)seekToOffset:(CGFloat)offset
{
    NSInteger seekOffset=offset*[self trackDuration];
    
    if([self.currentTrack isSpotifyTrack])
    {
        [self.spotifyPlayer seekToOffset:seekOffset callback:nil];
    }
    else if([self.currentTrack isSoundcloudTrack])
    {
        [self.AVplayer seekToTime:CMTimeMakeWithSeconds(seekOffset, NSEC_PER_SEC)];
        if(self.playing)
        {
            [self.AVplayer pause];
            [self.AVplayer play];
        }
    }
    else if ([self.currentTrack isMixcloudTrack]) {
        [self.AVplayer seekToTime:CMTimeMakeWithSeconds(seekOffset, NSEC_PER_SEC)];
        if (self.playing) {
            [self.AVplayer pause];
            [self.AVplayer play];
        }
    }
    else
    {
        self.isManualBuffering = YES;
        [self.baseYoutubePlayer seekToSeconds:seekOffset];

    }
}

- (void)playTrackAfterError {
    [self playTrackAfterErrorWithDelay:YES];
}

- (void)playTrackAfterErrorWithDelay:(BOOL)isDelay {
    CGFloat delay = 0.0;
    if (isDelay) {
        delay = IRPlayerDefaultDelayAfterFail;
    }
    if (self.isReversePlayingDirection) {
        _isDelayBeforeNext = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           if (_isDelayBeforeNext) {
                               [self prevTrack];
                           }
                       });
    }
    else {
        _isDelayBeforeNext = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           if (_isDelayBeforeNext) {
                               [self nextTrack];
                           }
                       });
    }
}

- (void)removeTrackAtIndex:(NSInteger)index{
    if (index < self.tracks.count) {
        NSMutableArray *tracks=[self.tracks mutableCopy];
        if(_hasTransitionalTrack && [((MFTrackItem *)tracks[index]).trackName isEqualToString:((MFTrackItem *)tracks[0]).trackName]){
            [tracks removeObjectAtIndex:0];
            if (index!=0) {
                index--;
            }
            _hasTransitionalTrack = NO;
            _currentTrackIndex = index;
        }
        [tracks removeObjectAtIndex:index];
        
        if(index<self.currentTrackIndex){
            if (self.currentTrackIndex!=0) {
                self.currentTrackIndex--;
            }
            [self setTracks:tracks];
        }else if(index==self.currentTrackIndex){
            if ([tracks count] <= self.currentTrackIndex) {
                if (self.currentTrackIndex!=0) {
                    self.currentTrackIndex--;
                }
                [self stopTrack];
            }
            else {
                [self playTracks:tracks trackIndex:self.currentTrackIndex];
            }
        }else{
            _tracks = tracks;
        }
    }
}

- (void)insertTrack:(MFTrackItem *)trackItem atIndex:(NSInteger)index{
    if (index < self.tracks.count + 1) {
        NSMutableArray *tracks=[self.tracks mutableCopy];
        [tracks insertObject:trackItem atIndex:index];
        
        if(index<=self.currentTrackIndex){
            self.currentTrackIndex++;
            [self setTracks:tracks];
        }else{
            [self setTracks:tracks];
        }
    }
}

- (void)changeTracks:(NSArray *)tracks {
    NSMutableArray *tracksArray = [NSMutableArray array];
    MFTrackItem *currentTrack = self.currentTrack;
    self.currentTrackIndex = -1;
    
    for (int i = 0; i < tracks.count; i++) {
        if ([((MFTrackItem *)tracks[i]).itemId isEqualToString:currentTrack.itemId]) {
            [tracksArray addObject:currentTrack];
            self.currentTrackIndex = i;
        } else {
            [tracksArray addObject:tracks[i]];
        }
    }
    if (currentTrack && self.currentTrackIndex == -1) {
        [tracksArray insertObject:currentTrack atIndex:0];
        self.currentTrackIndex = 0;
    }
    self.tracks = tracksArray;
}

#pragma mark - Playbacks

- (void)playbackStarted
{
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.currentTrack.trackPicture] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (image && finished) {
            self.currentArtwork = image;
            
        } else {
            self.currentArtwork = nil;
        }
    }];
    NSLog(@"playbackStarted");
    [self.loadingTimer invalidate];
    
    self.loading=YES;
    [self notifyDelegateAboutPrepareToPlay];
    
    self.haveTrack = YES;//TODO: fix for youtube
    self.playing = YES;
    
    if (self.delegateVC)
    {
        [self.delegateVC playbackAvailable:YES];
        [self.delegateVC startPlayingTrack:self.currentTrack];
    }
    [self updateTrackProgress];
    [self notifyDelegateAboutStartPlaying];

    [self stopAnotherSources:self.currentTrackType];
}

- (void)playbackNotStarted:(NSString*)errorMessage 
{
    [self playbackNotStarted:errorMessage delay:YES];
}

- (void)playbackNotStarted:(NSString*)errorMessage delay:(BOOL) delayBeforeNext{
    self.haveTrack = NO;
    [self stopAllSources];
    [self.loadingTimer invalidate];
    self.currentArtwork = nil;
    if (errorMessage)
    {
        
        if ([IRNetworkClient isReachable]) {
            [MFNotificationManager postCantLoadTrackNotification];
            [[Mixpanel sharedInstance] track:@"Cannot load track" properties:@{ @"trackID" : self.currentTrack.itemId }];
        }
        else {
            [MFNotificationManager postNetworkNotification];
        }
    }
    
    self.currentTrack.trackState = IRTrackItemStateFailed;
    [self playTrackAfterErrorWithDelay:delayBeforeNext];
}

- (void)stopAllSources
{
    //NSLog(@"All Sources Stop [%@]: %@ - %@", self.currentTrackType, self.currentTrack.artist, self.currentTrack.trackName);
    
    self.playing = NO;
    self.haveTrack = NO;
    
    if (self.delegateVC)
    {
        [self.delegateVC stopTrack];
        [self.delegateVC playbackAvailable:NO];
    }
    
    //[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
    
    [self stopAnotherSources:nil];
}

- (void)stopAnotherSources:(NSString*)source
{
    //NSLog(@"Another Sources Stop [%@]: %@ - %@", self.currentTrackType, self.currentTrack.artist, self.currentTrack.trackName);
    
    if(source==nil)
    {
        [self removeAVPlayer];
        [self removeSpotifyPlayer];
        [self removeYoutubePlayer];
    }
    else if([self.currentTrack isSpotifyTrack])
    {
        [self removeAVPlayer];
        [self removeYoutubePlayer];
    }
    else if([self.currentTrack isSoundcloudTrack])
    {
        [self removeSpotifyPlayer];
        [self removeYoutubePlayer];
    }
    else if([self.currentTrack isMixcloudTrack])
    {
        [self removeSpotifyPlayer];
        [self removeYoutubePlayer];
    }
    else
    {
        [self removeAVPlayer];
        [self removeSpotifyPlayer];
    }
}

#pragma mark - Track duration methods

- (CGFloat)trackCurrentTime
{
    if (self.haveTrack)
    {
        if([self.currentTrack isSpotifyTrack])
        {
            return self.spotifyPlayer.currentPlaybackPosition;
        }
        else if([self.currentTrack isSoundcloudTrack])
        {
            if  (self.AVplayer.currentItem.duration.timescale == 0.0)
            {
                return 0;
            }
            else
            {
                return self.AVplayer.currentItem.currentTime.value / self.AVplayer.currentItem.currentTime.timescale;
            }
        }
        else if([self.currentTrack isMixcloudTrack])
        {
            return CMTimeGetSeconds(self.AVplayer.currentTime);
        }
        else
        {
            return [self.videoPlayer currentTime];
        }
    }
    
    return 0;
}

- (CGFloat)trackDuration
{
    if (self.haveTrack)
    {
        if([self.currentTrack isSpotifyTrack])
        {
            return self.currentSpotifyTrack.duration;
        }
        else if([self.currentTrack isSoundcloudTrack])
        {
            if  (self.AVplayer.currentItem.status == AVPlayerItemStatusFailed || self.AVplayer.currentItem == nil)
            {
                [self playTrackAfterError];
            }
            else
            {
                if (self.AVplayer.currentItem.duration.timescale > 0.f) {
                    return self.AVplayer.currentItem.duration.value / self.AVplayer.currentItem.duration.timescale;
                }
                else {
                    return 0.f;
                }
            }
        }
        else if([self.currentTrack isMixcloudTrack])
        {
            if (!CMTIME_IS_INDEFINITE(self.AVplayer.currentItem.duration) && !CMTIME_IS_INVALID(self.AVplayer.currentItem.duration)) {
                return CMTimeGetSeconds(self.AVplayer.currentItem.duration);
            } else {
                return 0;
            }
        }
        else
        {
            return [self.videoPlayer duration];
        }
    }
    
    return 0;
}
- (CGFloat)trackProgress
{
    if (self.haveTrack)
    {
        if ([self trackDuration] == 0.0)
        {
            return 0;
        }
        else
        {
            return [self trackCurrentTime] / [self trackDuration];
        }
    }
    
    return 0;
}

- (void)updateTrackProgress
{
    if (self.haveTrack && self.currentTrack)
    {
        CGFloat progress = [self trackProgress];
        
        if (self.delegateVC)
        {
            [self.delegateVC updateProgress:progress];
        }
        
        NSMutableDictionary* mpInfoWithTime =[@{} mutableCopy];        
        [mpInfoWithTime setObject:[self currentTrack].trackName forKey:MPMediaItemPropertyTitle];
        [mpInfoWithTime setObject:[self currentTrack].artist forKey:MPMediaItemPropertyArtist];
        [mpInfoWithTime setObject:[self currentTrack].album forKey:MPMediaItemPropertyAlbumTitle];
        MPMediaItemArtwork *albumArt;
        if (self.currentArtwork)
        {
            albumArt = [[MPMediaItemArtwork alloc] initWithImage:self.currentArtwork];
        } else
        {
            albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"DefaultArtwork"]];
        }
        [mpInfoWithTime setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        [mpInfoWithTime setValue:@([self trackCurrentTime]) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [mpInfoWithTime setValue:@([self trackDuration]) forKeyPath:MPMediaItemPropertyPlaybackDuration];
        [mpInfoWithTime setValue:@(self.currentTrackIndex + 1) forKey:MPNowPlayingInfoPropertyPlaybackQueueIndex];
        [mpInfoWithTime setValue:@(self.tracks.count) forKey:MPNowPlayingInfoPropertyPlaybackQueueCount];
        
        [[MPNowPlayingInfoCenter defaultCenter]setNowPlayingInfo:mpInfoWithTime];
    }
}
-(void)startUpdateProgress{
    
    if(![self.timer isValid]){
        self.timer=[NSTimer scheduledTimerWithTimeInterval:0.5f
                                                    target:self
                                                  selector:@selector(updateTrackProgress)
                                                  userInfo:nil
                                                   repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
-(void)stopUpdateProgress{
    if([self.timer isValid]){
        [self.timer invalidate];
        self.timer=nil;
    }
}

#pragma mark - Preparation methods
       
- (void)notifyDelegateAboutStartPlaying
{
    self.loading=NO;
    if(self.delegateVC && [self.delegateVC respondsToSelector:@selector(loadingFinished)])
    {
        [self.delegateVC loadingFinished];
    }
    
    self.currentTrack.trackState = IRTrackItemStatePlaying;
}

- (void)notifyDelegateAboutPrepareToPlay
{
    if(self.preparationVC && [self.preparationVC respondsToSelector:@selector(didPreparePlaying)])
    {
        [self.preparationVC didPreparePlaying];
    }
}
-(void)notifyDelegateAboutUnstartPaying
{
    self.currentTrack.trackState = IRTrackItemStateNotStarted;
    if(self.preparationVC && [self.preparationVC respondsToSelector:@selector(didUnstartPlaying)])
    {
        [self.preparationVC didUnstartPlaying];
    }
}

#pragma mark - Helpers

- (NSString*)currentTrackType{
    
    return self.currentTrack.type;
}

- (MFTrackItem*)currentTrack
{
    if (self.currentTrackIndex < self.tracks.count) {
        return self.tracks[self.currentTrackIndex];
    }
    return nil;
}

- (void)replaceCurrentTrackOnTrack:(MFTrackItem*)trackItem
{
    NSMutableArray *array=[_tracks mutableCopy];
    array[self.currentTrackIndex]=trackItem;
    _tracks=array;
}

- (void)setPlayerTrack:(NSArray*)tracks
{
    self.tracks=tracks;
}
-(void) setTracks:(NSArray *)tracks{
    _tracks = tracks;
    self.hasTransitionalTrack = NO;
}
- (void)checkIfVolumeTurnOff
{
    float volume=[[AVAudioSession sharedInstance]outputVolume];
    
    if(volume<=5.0/16){
        [[self topViewController].parentViewController showErrorMessage:@"Turn up volume"];
    }
}

- (void)itemDidPlayToEnd:(NSNotification*)notification
{
    if (notification.object == self.AVplayer.currentItem) {
        if (![self.currentTrack.type isEqualToString:feedTypeYoutube]) {
            [self nextTrack];
        }
    }
}

- (void)failedPlayToEnd {
    NSLog(@"Can't play audio");
//    [self playbackNotStarted:@"Cannot play track"];
}

#pragma mark - SPTAudioStreamingPlaybackDelegate

/** Called when playback status changes.
 @param audioStreaming The object that sent the message.
 @param isPlaying Set to `YES` if the object is playing audio, `NO` if it is paused.
 */
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying
{
    if (isPlaying) {
        self.currentTrack.trackState = IRTrackItemStatePlaying;
    }
    else {
        self.currentTrack.trackState = IRTrackItemStatePaused;
    }
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSURL *)trackUri
{
    NSLog(@"Start track %@", trackUri);
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri
{
    if (self.currentTrack.trackState == IRTrackItemStatePaused) {
        if (self.isManualTrackSwitching) {
            self.isManualTrackSwitching = NO;
        } else {
            [self nextTrack];
        }
    }
}

/** Called when the streaming controller fails to play a track.
 
 This typically happens when the track is not available in the current users' region, if you're playing
 multiple tracks the playback will start playing the next track automatically
 
 @param audioStreaming The object that sent the message.
 @param trackUri The URI of the track that failed to play.
 */
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri
{
    NSLog(@"Can't play track");
    [self playbackNotStarted:@"Cannot play track"];
}

/** Called when the streaming controller lost permission to play audio.
 
 This typically happens when the user plays audio from their account on another device.
 
 @param audioStreaming The object that sent the message.
 */
- (void)audioStreamingDidLosePermissionForPlayback:(SPTAudioStreamingController *)audioStreaming
{
    //TODO test and implement
}

- (BOOL)isEqualToPlayer:(MFYoutubePlayer *)youtubePlayer {
    return youtubePlayer.videoId && [youtubePlayer.videoId isEqualToString:self.currentTrack.videoID] && ((self.videoPlayer.isNativePlayer && [youtubePlayer isKindOfClass:[MFNativeYoutubePlayer class]]) || ((!self.videoPlayer.isNativePlayer) && [youtubePlayer isKindOfClass:[MFIFrameYoutubePlayer class]]));
}

#pragma mark - MFYoutubePlayerDelegate methods

- (void)youtubePlayerDidBecomeReady:(MFYoutubePlayer *)youtubePlayer {
    if ([self isEqualToPlayer:youtubePlayer]) {
        [self.baseYoutubePlayer play];
    } else {
        [youtubePlayer stop];
    }
}

- (void)youtubePlayer:(MFYoutubePlayer *)youtubePlayer didChangeToState:(MFYoutubePlayerState)state {
    if (self.interrupted) {
        if (state == MFYoutubePlayerStatePlaying) {
            [self.baseYoutubePlayer seekToSeconds:self.trackTimeBeforeInterruption];
        }
        self.interrupted = NO;
    }
    if ([self isEqualToPlayer:youtubePlayer]) {
        switch (state) {
            case MFYoutubePlayerStatePlaying:
                [self playbackStarted];
                self.isManualTrackSwitching = NO;
                break;
            case MFYoutubePlayerStatePaused:
                if (!self.isManualPause) {
                    if (self.delegateVC) {
                        [self.delegateVC pauseTrack];
                    }
                    if ([self trackProgress]<0.95){
                        self.currentTrack.trackState = IRTrackItemStatePaused;
                        [self nativePlayerInterruption];
                    }
                    self.interrupted = YES;
                    self.trackTimeBeforeInterruption = youtubePlayer.currentTime;
                }
                break;
            case MFYoutubePlayerStateLoading:
                if (!self.isManualBuffering && [self trackProgress]<0.95 && [self trackProgress]>0.05){
                    [self iframePlayerInterruption];
                }
                break;
            case MFYoutubePlayerStateEnded:
                if (self.isManualTrackSwitching && self.videoPlayer.isNativePlayer) {
                    self.isManualTrackSwitching = NO;
                } else {
                    self.isManualTrackSwitching = NO;
                    if (self.playing) {
                        [self nextTrack];
                    }
                }
                break;
            default:
                break;
        }
    } else {
        [youtubePlayer stop];
    }
    self.isManualBuffering = NO;
}

- (void)youtubePlayer:(MFYoutubePlayer *)youtubePlayer didReceiveError:(NSError *)error {
    if ([self isEqualToPlayer:youtubePlayer]) {
        if ([self.currentTrack isYoutubeTrack]) {
            if (self.videoPlayer.isNativePlayer) {
                [self.videoPlayer changeToIFramePlayer];
                [self playTrack];
            } else {
                [self playbackNotStarted:nil];
                [MFNotificationManager postCantLoadTrackNotification];
                
//              [self nextTrack];
            }
        }
    } else {
        [youtubePlayer stop];
    }
}

- (void)setReachabilityNotifications {
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [networkReachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *) notification
{
    Reachability *reachability = [notification object];
    
    if ([reachability isReachable] && (self.currentTrack.trackState == IRTrackItemStateLoading || self.currentTrack.trackState == IRTrackItemStateFailed)) {
        [self playTrack];
    }
}

- (void)trackStillLoading:(NSTimer*)timer{
    [MFNotificationManager postTrackLoagingTooLongNotification];
}

- (NSArray*)getCurrentQueue{
    if (_tracks.count) {
        NSArray* result = [[self.tracks subarrayWithRange:NSMakeRange(self.currentTrackIndex, self.tracks.count - self.currentTrackIndex)] arrayByAddingObjectsFromArray:[self.tracks subarrayWithRange:NSMakeRange(0, self.currentTrackIndex)]];
        return result;
    } else {
        return [NSArray array];
    }
}

- (void)addTrackToNowPlaying:(MFTrackItem*)trackItem{
    if ([self.nowPlayingQueue containsObject:trackItem]) {
        return;
    }
    NSMutableArray* array = [self.nowPlayingQueue mutableCopy];
    [array addObject:trackItem];
    self.nowPlayingQueue = array;
    if (!self.isPlayingPlaylist) {
        if (self.tracks) {
            self.tracks = [self.tracks arrayByAddingObject:trackItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MFUpdateTrackHistory" object:nil];
        } else {
            self.isPlayingPlaylist = NO;
            self.isManualTrackSwitching = YES;
            [self playTracks:self.nowPlayingQueue trackIndex:0];
        }
    }
    
}

- (void)playSingleTrack:(MFTrackItem*)trackItem{
    self.isManualTrackSwitching = YES;
    self.isPlayingPlaylist = NO;
    if ([self.nowPlayingQueue containsObject:trackItem]) {
        NSMutableArray* array = [self.nowPlayingQueue mutableCopy];
        [array removeObject:trackItem];
        self.nowPlayingQueue = array;
    }
    if (self.nowPlayingQueue.count>0) {
        NSMutableArray* array = [self.nowPlayingQueue mutableCopy];
        [array removeObjectAtIndex:0];
        self.nowPlayingQueue = array;
    }
    NSMutableArray* array = [self.nowPlayingQueue mutableCopy];
    [array insertObject:trackItem atIndex:0];
    self.nowPlayingQueue = array;
    [self playTracks:self.nowPlayingQueue trackIndex:0];
}

- (void)playPlaylist:(NSArray<MFTrackItem*>*)playlist fromIndex:(int)index{
    self.isManualTrackSwitching = YES;
    self.isPlayingPlaylist = YES;
    [self playTracks:playlist trackIndex:index];
}

- (void)reorderCurrentQueueFromIndex:(int)index{
    self.isManualTrackSwitching = YES;

    if (self.isPlayingPlaylist) {
        [self playTracks:self.tracks trackIndex:(self.currentTrackIndex+index)%self.tracks.count];
    } else {
        NSMutableArray* newQueue = [[self.nowPlayingQueue subarrayWithRange:NSMakeRange(index, self.nowPlayingQueue.count - index)] mutableCopy];
        [newQueue addObjectsFromArray:[self.nowPlayingQueue subarrayWithRange:NSMakeRange(0, index)]];
        self.nowPlayingQueue = newQueue;
        [self playTracks:self.nowPlayingQueue trackIndex:0];
    }
}

- (void)removeAllTracks{
    self.isManualTrackSwitching = YES;
    [self playTracks:nil trackIndex:0];
}

- (void)shuffleTracks{
    self.isManualTrackSwitching = YES;
    if (self.isPlayingPlaylist) {
        NSMutableArray* shuffledTracks = [self.tracks mutableCopy];
        [shuffledTracks shuffle];
        [self playTracks:shuffledTracks trackIndex:self.currentTrackIndex];
    } else {
        NSMutableArray* newQueue = [self.nowPlayingQueue mutableCopy];
        [newQueue shuffle];
        self.nowPlayingQueue = newQueue;
        [self playTracks:self.nowPlayingQueue trackIndex:0];
    }
}

- (NSArray*)nowPlayingQueue{
    return [[self.upNextPlaylist.songs array] mutableCopy];
}

- (void)setNowPlayingQueue:(NSArray *)nowPlayingQueue{
    self.upNextPlaylist.songs = [NSOrderedSet orderedSetWithArray:nowPlayingQueue];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];

}

- (void)moveTrackAtIndex:(NSInteger)index1 toIndex:(NSInteger)index2{
    NSInteger playerIndex1 = (self.currentTrackIndex+index1)%self.tracks.count;
    NSInteger playerIndex2 = (self.currentTrackIndex+index2)%self.tracks.count;

    if (self.isPlayingPlaylist) {

        NSMutableArray* tracks = [self.tracks mutableCopy];
        MFTrackItem* track = [tracks objectAtIndex:playerIndex1];
        [tracks removeObjectAtIndex:playerIndex1];
        [tracks insertObject:track atIndex:playerIndex2];
        self.tracks = [tracks copy];

    } else {

        NSMutableArray* tracks = [self.nowPlayingQueue mutableCopy];
        MFTrackItem* track = [tracks objectAtIndex:playerIndex1];
        [tracks removeObjectAtIndex:playerIndex1];
        [tracks insertObject:track atIndex:playerIndex2];
        self.nowPlayingQueue = [tracks copy];
        self.tracks = self.nowPlayingQueue;

    }
}

- (void) nativePlayerInterruption{
    [self interruptionWithWeight:2];
}

- (void) iframePlayerInterruption{
    [self interruptionWithWeight:1];
}

- (void) interruptionWithWeight:(NSInteger)weight{
    self.interruptionsCount += weight;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.interruptionsCount -= weight;
    });
    if (self.interruptionsCount > 3) {
        if (![userManager isSwitchToAudioPromptShown]) {
            [[[UIAlertView alloc] initWithTitle:@"Weak bandwidth detected" message:@"You can switch to audio only filter on feed" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
            [userManager setSwitchToAudioPromptShown:YES];
        }

    }

}
@end
