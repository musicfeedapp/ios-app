//
//  IRPlayerManager.h
//  botmusic
//
//  Created by Илья Романеня on 30.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerViewController.h"
#import "MFTrackItem+Behavior.h"
#import "PlayerViewControllerDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioSession.h>

#import <CocoaSoundCloudAPI/SCAPI.h>
#import <Spotify/Spotify.h>
#import "STrack.h"
#import "YTPlayerView.h"

typedef void(^ParseOverBlockWithDirectURL)(NSURL* directURL);

@interface IRPlayerManager : NSObject <SPTAudioStreamingPlaybackDelegate, MFYoutubePlayerDelegate>

+ (IRPlayerManager*)sharedInstance;

@property (nonatomic, strong) MFYoutubePlayer *baseYoutubePlayer;

@property (nonatomic, weak) PlayerViewController *videoPlayer;
@property (nonatomic, weak) id<PlayerViewControllerDelegate> delegateVC;
@property (nonatomic, weak) id<PlayerPreparationDelegate> preparationVC;

@property (nonatomic, strong) YTPlayerView *youtubePlayer;

@property (nonatomic, readonly, assign) BOOL playing;
@property (nonatomic, readonly, assign) BOOL haveTrack;
@property (nonatomic, readonly, assign) BOOL loading;
//track which added when changeTracks called
@property (nonatomic)                   BOOL hasTransitionalTrack;
@property (nonatomic, assign) BOOL isManualTrackSwitching;

@property (nonatomic, assign) NSUInteger currentTrackIndex;
@property (nonatomic) BOOL startedPlayingFirstTime;

@property (nonatomic, readonly, assign) MFTrackItem* currentTrack;
@property (nonatomic, strong) NSArray* nowPlayingQueue;
@property (nonatomic) BOOL isPlayingPlaylist;
@property (nonatomic, strong) NSString* currentSourceName;
@property (nonatomic, strong) MFPlaylistItem* upNextPlaylist;

- (CGFloat)trackProgress;
- (void)playTrack;
- (void)resumeTrack;
- (void)pauseTrack;
- (void)stopTrack;
- (void)nextTrack;
- (void)prevTrack;
- (void)seekToOffset:(CGFloat)offset;
- (void)removeTrackAtIndex:(NSInteger)index;
- (void)insertTrack:(MFTrackItem *)trackItem atIndex:(NSInteger)index;
- (void)changeTracks:(NSArray *)tracks;
- (CGFloat)trackDuration;
- (void)playTrackAfterErrorWithDelay:(BOOL)isDelay;
- (void)playbackNotStarted:(NSString*)errorMessage;
- (void)playbackNotStarted:(NSString*)errorMessage delay:(BOOL) delayBeforeNext;

- (void)addTrackToNowPlaying:(MFTrackItem*)trackItem;

- (void)playSingleTrack:(MFTrackItem*)trackItem;

- (void)playPlaylist:(NSArray<MFTrackItem*>*)playlist fromIndex:(int)index;

- (NSArray*)getCurrentQueue;
- (void)reorderCurrentQueueFromIndex:(int)index;
- (void)removeAllTracks;
- (void)shuffleTracks;
- (void)moveTrackAtIndex:(NSInteger)index1 toIndex:(NSInteger)index2;

@end
