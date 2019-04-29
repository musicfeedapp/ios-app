//
//  MFNativeYoutubePlayer.m
//  botmusic
//
//  Created by Panda Systems on 4/2/15.
//
//

#import "MFNativeYoutubePlayer.h"
#import "XCDYouTubeVideoPlayerViewController.h"
#import "MPMoviePlayerController+BackgroundPlayback.h"

@interface MFNativeYoutubePlayer ()
@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
@end

@implementation MFNativeYoutubePlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add observers
        [self addPlaybackStateDidChangeNotificationObserver];
        [self addPlaybackDidFinishNotificationObserver];
    }
    return self;
}

#pragma mark - Properties

- (NSTimeInterval)duration {
    return self.videoPlayerViewController.moviePlayer.duration;
}

- (NSTimeInterval)currentTime {
    return self.videoPlayerViewController.moviePlayer.currentPlaybackTime;
}

#pragma mark - Player Actions

- (void)loadVideoWithId:(NSString *)videoId {
    [super loadVideoWithId:videoId];
    
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoId];
    self.videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = YES;
    self.videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    [self addDidReceiveVideoNotificationObserver];
}

- (void)play {
    [self.videoPlayerViewController.moviePlayer play];
}

- (void)pause {
    [self.videoPlayerViewController.moviePlayer pause];
}

- (void)stop {
    [self.videoPlayerViewController.moviePlayer stop];
}

- (void)seekToSeconds:(float)seekOffset {
    self.videoPlayerViewController.moviePlayer.currentPlaybackTime = seekOffset;
}

#pragma mark - Internal methods

- (void)addDidReceiveVideoNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayerViewControllerDidReceiveVideo:)
                                                 name:XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification
                                               object:self.videoPlayerViewController];
}

- (void)removeDidReceiveVideoNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification
                                                  object:self.videoPlayerViewController];
}

- (void)addPlaybackStateDidChangeNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayerViewControllerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.videoPlayerViewController];
}

- (void)removePlaybackStateDidChangeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:self.videoPlayerViewController];
}

- (void)addPlaybackDidFinishNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayerViewControllerPlaybackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.videoPlayerViewController];
}

- (void)removePlaybackDidFinishNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.videoPlayerViewController];
}

#pragma mark - NotificationCenter observers

- (void)videoPlayerViewControllerDidReceiveVideo:(NSNotification *)notification {
    [self.videoPlayerViewController presentInView:self.containerView];
    self.videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    // TODO: check if it is needed
    [self removeDidReceiveVideoNotificationObserver];
    
    if (self.delegate) {
        [self.delegate youtubePlayerDidBecomeReady:self];
    }
}

- (void)videoPlayerViewControllerPlaybackStateDidChange:(NSNotification *)notification {
    if (notification.object == self.videoPlayerViewController.moviePlayer) {
        NSError *error = notification.userInfo[@"error"];
        if (error) {
            if (self.delegate) {
                [self.delegate youtubePlayer:self didReceiveError:error];
            }
        } else {
            MPMoviePlayerController *moviePlayerController = notification.object;
            
            switch (moviePlayerController.playbackState) {
                case MPMoviePlaybackStatePlaying:
                    if (self.delegate) {
                        [self.delegate youtubePlayer:self didChangeToState:MFYoutubePlayerStatePlaying];
                    }
                    break;
                case MPMoviePlaybackStatePaused:
                    if (self.delegate) {
                        [self.delegate youtubePlayer:self didChangeToState:MFYoutubePlayerStatePaused];
                    }
                    break;
                case MPMoviePlaybackStateInterrupted:
                    if (self.delegate) {
                        [self.delegate youtubePlayer:self didChangeToState:MFYoutubePlayerStatePaused];
                    }
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)videoPlayerViewControllerPlaybackDidFinish:(NSNotification *)notification {
    if (notification.object == self.videoPlayerViewController.moviePlayer) {
        if ([notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] != nil) {
            MPMovieFinishReason reason = [[notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
            
            if (reason == MPMovieFinishReasonPlaybackError) {
                if (self.delegate) {
                    [self.delegate youtubePlayer:self didReceiveError:nil];
                }
            } else {
                if (self.delegate) {
                    [self.delegate youtubePlayer:self didChangeToState:MFYoutubePlayerStateEnded];
                }
            }
        } else {
            if (self.delegate) {
                [self.delegate youtubePlayer:self didChangeToState:MFYoutubePlayerStateEnded];
            }
        }
    }
}

@end
