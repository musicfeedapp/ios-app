//
//  PlayerViewController.h
//  botmusic
//
//  Created by Илья Романеня on 17.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerViewControllerDelegate.h"
#import "AbstractViewController.h"
#import "CommentsViewController.h"
#import <MarqueeLabel.h>
#import "YTPlayerView.h"
#import "MFYoutubePlayer.h"
#import "MFNativeYoutubePlayer.h"
#import "MFIFrameYoutubePlayer.h"
#import "MFPlayerMenuViewController.h"

@class ActionView;
@class ProgressView;

@protocol MFPlayerNewDelegate <NSObject>

- (void)viewPanned:(UIPanGestureRecognizer*)sender;
- (void)didTapAtTrackNameForTrack:(MFTrackItem*)track;

@end

@interface PlayerViewController : AbstractViewController <PlayerViewControllerDelegate, CommentViewControllerDelegate, MFPlayerMenuViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) id <MFPlayerNewDelegate> pannableDelegate;
@property (weak, nonatomic) IBOutlet UIView *actionViewContainer;
@property (strong, nonatomic) ActionView *actionView;
@property (weak, nonatomic) IBOutlet UIView *gradientContainer;

@property (nonatomic, weak) IBOutlet UIView *airPlayView;

@property (nonatomic, weak) IBOutlet UIView *nativePlayerView;
@property (nonatomic, weak) IBOutlet YTPlayerView *iFramePlayerView;

@property (nonatomic, readonly) BOOL isNativePlayer;

@property (nonatomic, weak) IBOutlet UIImageView *bigTrackImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bigSquareTrackImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *bigActivityView;
@property (nonatomic, weak) IBOutlet ProgressView *bigProgressView;

@property (nonatomic, weak) IBOutlet UIView *trackPointer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointerWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@property (nonatomic, weak) IBOutlet UIView *controlsView;
@property (nonatomic, weak) IBOutlet UIButton* bigPlayButton;
@property (nonatomic, weak) IBOutlet UIButton* hideButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBlurView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBlurPrevView;

@property (weak, nonatomic) IBOutlet UIView *tapToPauseView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainedTimeLabel;

@property (nonatomic, strong)        NSString* currentVideoId;
@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic) BOOL isPreview;

@property (nonatomic, strong) UITapGestureRecognizer *playerViewTap;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *playerViewSwipeLeft;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *playerViewSwipeRight;

- (IBAction)didTouchUpPlayButton:(id)sender;
- (IBAction)didTouchUpNextButton:(id)sender;
- (IBAction)didTouchUpPreviousButton:(id)sender;

- (IBAction)didTapAtView:(id)sender;
- (IBAction)didSwipeDownAtView:(id)sender;
- (IBAction)didPanTrackPointer:(UIPanGestureRecognizer*)pan;

- (IBAction)didTouchUpHideButton:(id)sender;

- (void)changeToIFramePlayer;
- (void)changeToNativePlayer;

/*
 Video playing control
 */
- (void)playVideo;
- (void)pauseVideo;
- (void)stopVideo;
- (void)clearVideo;
- (void)seekToSeconds:(float)seekToSeconds;
- (NSTimeInterval)duration;
- (NSTimeInterval)currentTime;

- (void)configureForState:(BOOL)isHidden;
@end
