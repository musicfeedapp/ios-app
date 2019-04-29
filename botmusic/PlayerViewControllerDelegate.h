//
//  PlayerViewControllerDelegate.h
//  botmusic
//
//  Created by Илья Романеня on 20.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFTrackItem+Behavior.h"

@protocol PlayerViewControllerDelegate <NSObject>

@required

- (void)startPlayingTrack:(MFTrackItem*)trackItem;
- (void)pauseTrack;
- (void)resumeTrack;
- (void)stopTrack;
- (void)playbackAvailable:(BOOL)available;
- (void)updateProgress:(CGFloat)seconds;
- (void)loadingFinished;
- (void)startBuffering;

@end

@protocol PlayerPreparationDelegate <NSObject>

-(void)didPreparePlaying;
-(void)didStartPlaying;
-(void)didUnstartPlaying;

- (void)needToLoginInSoundCloud:(UIViewController*)loginController;

- (void)didStartTrackAtIndex:(NSUInteger)index afterTrackAtIndex:(NSUInteger)prevIndex;
- (void)didStartTrack:(MFTrackItem *)trackItem afterTrack:(MFTrackItem *)prevTrack;
- (void)didPauseTrackAtIndex:(NSUInteger)index;
- (void)didPauseTrack:(MFTrackItem *)trackItem;
- (void)didResumeTrackAtIndex:(NSUInteger)index;
- (void)didResumeTrack:(MFTrackItem *)trackItem;

@end