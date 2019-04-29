//
//  PlayerViewController.m
//  botmusic
//
//  Created by Илья Романеня on 17.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "PlayerViewController.h"
#import "CommentsViewController.h"
#import "ProgressView.h"
#import "UIImage+ImageEffects.h"
#import <UIColor+Expanded.h>
#import "NSDate+TimesAgo.h"
#import "PreviewViewController.h"
#import "MPMoviePlayerController+BackgroundPlayback.h"
#import "TrackInfoView.h"
#import "PlaylistsViewController.h"
#import "TrackInfoViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "MFNotificationManager.h"
#import "UIImageView+WebCache_FadeIn.h"
#import "FeedViewController.h"
#import "UIImage+GPUBlur.h"
#import "MFSingleTrackViewController.h"
CGFloat const INFO_VIDEO_OFFSET = 277.0f;
CGFloat const INFO_TRACK_IMAGE_OFFSET = 307.0f;

@interface PlayerViewController () <TrackInfoViewDelegate, UIGestureRecognizerDelegate, PlaylistViewControllerTrackAdditionDelegate>
{
    CGFloat currentTrackDuration;
    CGFloat currentTrackPosition;
    BOOL    _isSmall;
    BOOL isRotatedToPortraitOrientation;
}
@property (weak, nonatomic) IBOutlet UIButton *playerMenuButton;
@property (weak, nonatomic) IBOutlet UIView *bottomPlayerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsWidth;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *playerPanGestureRecognizer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *squareImageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bigSquareImageViewToTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideButtonTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerContainerTop;
@property (nonatomic)           BOOL                    updateProgressAutomatically;

@property (nonatomic, readonly) NSArray*                videoQualitiesWWANPortrate;

@property (nonatomic, strong) MFYoutubePlayer *youtubePlayer;
@property (nonatomic, strong) MFNativeYoutubePlayer *nativeYoutubePlayer;
@property (nonatomic, strong) MFIFrameYoutubePlayer *iframeYoutubePlayer;

@property (nonatomic, strong, readonly) UIView *youtubePlayerView;
@property (nonatomic, strong) MPVolumeView *volumeView;

@property (nonatomic, readwrite) BOOL isNativePlayer;

@property (nonatomic) BOOL isShownFromFeed;
@property (nonatomic, strong) MFTrackItem* previousTrackItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *largeProgressViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackPointerLeading;
@property (weak, nonatomic) IBOutlet UIButton *trackTypeIndicator;
@property (weak, nonatomic) IBOutlet UIView *progressContainer;

@property (strong, nonatomic) NSTimer* tapInFullscreenTimer;
@property (nonatomic) BOOL layoutConfigured;

@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageToLeading;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;
@property (weak, nonatomic) IBOutlet UIView *headerContainer;
@property (weak, nonatomic) IBOutlet UIView *playerMenuContainerView;
@property (weak, nonatomic) IBOutlet UIView *mainPlayerView;
@property (weak, nonatomic) IBOutlet UIView *grayViewForDisabledTransparency;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *trackPointerPanRecognizer;
@property (strong, nonatomic) MFPlayerMenuViewController* playerMenuViewController;
@end

@implementation PlayerViewController{
    CGFloat _anchorPoint;
    BOOL _isDragging;
    CGFloat _lastHeight;
    CFTimeInterval _lastTime;
    double _velocity;
    BOOL _buttonsShown;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isSmall = YES;

        _updateProgressAutomatically = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.smallTrackImageView.layer.borderWidth = 1.0;
    //self.smallTrackImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.actionView = [[[NSBundle mainBundle] loadNibNamed:@"ActionView" owner:nil options:nil] lastObject];
    self.actionView.frame = self.actionViewContainer.bounds;
    [self.actionViewContainer addSubview:self.actionView];
    self.actionView.hidden = YES;
    self.volumeView = [[MPVolumeView alloc] initWithFrame:self.airPlayView.bounds];
    self.volumeView.showsVolumeSlider = NO;
    self.volumeView.showsRouteButton = YES;
    //self.trackInfoView.addButton.hidden = YES;
    [self.airPlayView addSubview:self.volumeView];
    self.airPlayView.hidden = YES;
    self.bigSquareTrackImageView.hidden = YES;
    self.bigTrackImageView.hidden = YES;
    _playerViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapInFullscreen:)];
    _isSmall = YES;
    _videoHeight.constant = [UIScreen mainScreen].bounds.size.width*9.0/16.0;
    _squareImageHeight.constant = [UIScreen mainScreen].bounds.size.width;
    _isPreview = self.parentViewController.parentViewController != nil && [self.parentViewController.parentViewController isKindOfClass:[PreviewViewController class]];
    
    if (_isPreview) {
        self.hideButton.hidden = YES;
        self.airPlayView.hidden = YES;
        self.trackItem = [((PreviewViewController *)self.parentViewController.parentViewController) tutorialTrack];
        [self setTrackInfo:self.trackItem];
        
        [self.view setBackgroundColor:[UIColor colorWithRGBHex:kAppPlayerColor]];
    }
    [self adjustForTransparencySettings];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustForTransparencySettings) name:UIAccessibilityReduceTransparencyStatusDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(like:) name:FeedLikeNotificationEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlike:) name:FeedUnlikeNotificationEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(like:) name:PlaylistLikeNotificationEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlike:) name:PlaylistUnlikeNotificationEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeNew:) name:[MFNotificationManager nameForNotification:MFNotificationTypeTrackLiked] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlikeNew:) name:[MFNotificationManager nameForNotification:MFNotificationTypeTrackDisliked] object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    [self prepareUI];
    
    // Set Base Youtube Player
    self.isNativePlayer = YES;
    [self updateYoutubePlayer];
    
    [playerManager setVideoPlayer:self];
    
    [playerManager setDelegateVC:self];

    self.airPlayView.hidden = NO;
    self.hideButton.hidden = NO;
    [self setReachabilityNotifications];
}

- (void)viewDidLayoutSubviews{
    if (!_layoutConfigured) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, _gradientContainer.bounds.size.width, _gradientContainer.bounds.size.height);
//        UIColor *startColour = [UIColor colorWithWhite:0.0 alpha:1.0];
//        UIColor *endColour = [UIColor colorWithWhite:0.0 alpha:0.0];
        [gradient setStartPoint:CGPointMake(0.5, 0.0)];
        [gradient setEndPoint:CGPointMake(0.5, 1.0)];
//        gradient.locations = [NSArray arrayWithObjects:@0.0, @0.33, @0.66, @1.0, nil];
//        gradient.colors = [NSArray arrayWithObjects:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor, [UIColor colorWithWhite:0.0 alpha:0.8].CGColor, [UIColor colorWithWhite:0.0 alpha:0.2].CGColor, [UIColor colorWithWhite:0.0 alpha:0.0].CGColor, nil];
        gradient.colors = [NSArray arrayWithObjects:[UIColor colorWithWhite:0.0 alpha:1.0].CGColor, [UIColor colorWithWhite:0.0 alpha:0.0].CGColor, nil];
        [_gradientContainer.layer addSublayer:gradient];
        _layoutConfigured = YES;
        self.pointerWidth.constant = 1.5;
        _buttonsWidth.constant = [UIScreen mainScreen].bounds.size.width*0.27;
        _videoHeight.constant = [UIScreen mainScreen].bounds.size.width*9.0/16.0;
        _squareImageHeight.constant = [UIScreen mainScreen].bounds.size.width;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight){
        if ([NSObject appDelegate].isShowVideo) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            [MFMessageManager sharedInstance].statusBarShouldBeHidden = YES;
            _hideButtonTop.constant = [UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.width + 15.0;
            _videoHeight.constant = [UIScreen mainScreen].bounds.size.width;
            _bigSquareImageViewToTop.constant = [UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.width;
            self.gradientContainer.hidden = YES;
            self.likeButton.hidden = YES;
            self.moreButton.hidden = YES;
            self.trackTypeIndicator.hidden = YES;
            self.playerMenuButton.hidden = YES;
            self.bottomPlayerView.hidden = YES;
            _progressViewTop.constant = - ( + 18.0 + 28.0 + 5.0);
            [self.view addGestureRecognizer:self.playerViewTap];
            [self.view addGestureRecognizer:self.playerViewSwipeLeft];
            [self.view addGestureRecognizer:self.playerViewSwipeRight];
            [self hideFullscreenControls];
            [self hideButtons:duration];
        }
    } else if (toInterfaceOrientation == UIDeviceOrientationPortrait) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [MFMessageManager sharedInstance].statusBarShouldBeHidden = NO;
        _hideButtonTop.constant = 35.0;
        _videoHeight.constant = [UIScreen mainScreen].bounds.size.height*9.0/16.0;
        _bigSquareImageViewToTop.constant = 0.0;
        self.gradientContainer.hidden = NO;
        self.likeButton.hidden = NO;
        self.moreButton.hidden = NO;
        self.trackTypeIndicator.hidden = NO;
        self.playerMenuButton.hidden = NO;
        self.bottomPlayerView.hidden = NO;

        _progressViewTop.constant = -28.0;
        [self.view removeGestureRecognizer:self.playerViewTap];
        [self.view removeGestureRecognizer:self.playerViewSwipeLeft];
        [self.view removeGestureRecognizer:self.playerViewSwipeRight];

        [self.progressContainer setHidden:NO];
        [self.hideButton setHidden:NO];
        [self.airPlayView setHidden:NO];
        [self.tapInFullscreenTimer invalidate];
    }

//    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
//        NSLog(@"toLandscape");
//        isRotatedToPortraitOrientation = NO;
//        self.controlsView.hidden = YES;
//        self.labelsView.hidden = YES;
//        self.hideButton.hidden = YES;
//        self.airPlayView.hidden = YES;
//        self.errorView.hidden = YES;
//        self.bigProgressView.hidden = YES;
//        self.trackView.hidden = YES;
//        self.tapToPauseView.hidden = YES;
//        //self.imageViewTopConstraint.constant = 0.0f;
//        //self.playerViewTopConstraint.constant = 0.0f;
//        self.playerViewLeadingConstraint.constant = 0.0f;
//        self.playerViewTrailingConstraint.constant = 0.0f;
//        self.squareImageViewTopConstraint.constant = 0.0f;
//        self.squareImageViewBotConstraint.constant = -268.0f;
//        [self.view addGestureRecognizer:self.playerViewTap];
//        [self.view addGestureRecognizer:self.playerViewSwipeLeft];
//        [self.view addGestureRecognizer:self.playerViewSwipeRight];
//        self.actionView.hidden = NO;
//        self.imageViewBottomConstraint.constant = 0;
//
//    }
//    else {
//        NSLog(@"toPortrait");
//        isRotatedToPortraitOrientation = YES;
//        self.controlsView.hidden = NO;
//        self.labelsView.hidden = NO;
//        self.hideButton.hidden = NO;
//        self.airPlayView.hidden = NO;
//        self.errorView.hidden = NO;
//        self.bigProgressView.hidden = NO;
//        self.trackView.hidden = NO;
//        //self.tapToPauseView.hidden = NO;
//        //self.imageViewTopConstraint.constant = 60.0f;
//        //self.playerViewTopConstraint.constant = 60.0f;
//        self.playerViewLeadingConstraint.constant = 0.0f;
//        self.playerViewTrailingConstraint.constant = 0.0f;
//        self.squareImageViewTopConstraint.constant = 60.0f;
//        self.squareImageViewBotConstraint.constant = 0.0f;
//        [self.view removeGestureRecognizer:self.playerViewTap];
//        [self.view removeGestureRecognizer:self.playerViewSwipeLeft];
//        [self.view removeGestureRecognizer:self.playerViewSwipeRight];
//        self.actionView.hidden = YES;
//        
//    }

    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

//    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
//        [self.trackInfoView setDuration:[self formattedTime:currentTrackDuration]];
//    }
//    
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight){
//        
//    } else {
//        if (playerManager.haveTrack&&!_isSmall&&_isShownFromFeed&&isRotatedToPortraitOrientation){
//            _isShownFromFeed = NO;
//            [self hidePlayer];
//            NSLog(@"hidePlayer");
//        }
//    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Two players supporting

- (UIView *)youtubePlayerView {
    if (self.isNativePlayer) {
        return self.nativePlayerView;
    } else {
        return self.iFramePlayerView;
    }
}

- (void)updateYoutubePlayer {
    if (!_nativeYoutubePlayer) {
        self.nativeYoutubePlayer = [[MFNativeYoutubePlayer alloc] init];
    }
    if (!_iframeYoutubePlayer) {
        self.iframeYoutubePlayer = [[MFIFrameYoutubePlayer alloc] init];
    }
    [self.youtubePlayer stop];
    self.youtubePlayer = self.isNativePlayer ? self.nativeYoutubePlayer : self.iframeYoutubePlayer;
    [self.youtubePlayer setContainerView:self.youtubePlayerView];
    [playerManager setBaseYoutubePlayer:self.youtubePlayer];
    [self.youtubePlayer setDelegate:playerManager];
}

- (void)changeToIFramePlayer {
    self.nativePlayerView.hidden = YES;
    self.isNativePlayer = NO;
    [self updateYoutubePlayer];
}

- (void)changeToNativePlayer {
    self.iFramePlayerView.hidden = YES;
    self.isNativePlayer = YES;
    [self updateYoutubePlayer];
//    self.nativePlayerView.hidden = YES;
//    self.isNativePlayer = NO;
//    [self updateYoutubePlayer];
}

#pragma mark - Set Reachability notifications

- (void)setReachabilityNotifications
{
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self showAndKeepTopErrorViewWithMessage:self.kErrorMessage autohide:NO];
    } else {
        [self hideTopErrorViewAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [networkReachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *) notification
{
    Reachability *reachability = [notification object];
    if ([reachability isReachable]) {
        [self hideTopErrorViewWithMessage:self.kConnectedMessage];
    }
    else {
        [self showAndKeepTopErrorViewWithMessage:self.kErrorMessage autohide:NO];
    }
    
    if ([reachability isReachableViaWiFi]) {
    }
}

#pragma mark - Preparation

- (void)prepareUI
{
    
    [self setProgress:0.0f];
    [self setProgress:0.0f];
}

#pragma mark - Player methods

- (void)playVideo
{
    [self.youtubePlayer play];
}

- (void)stopVideo
{
    [self.youtubePlayer stop];
}

- (void)pauseVideo
{
    [self.youtubePlayer pause];
}

- (void)clearVideo
{
    [self.youtubePlayer.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)seekToSeconds:(float)seekToSeconds {
    [self.youtubePlayer seekToSeconds:seekToSeconds];
}

- (NSTimeInterval)duration
{
    return self.youtubePlayer.duration;
}

- (NSTimeInterval)currentTime
{
    return self.youtubePlayer.currentTime;
}

- (void)setProgress:(CGFloat)progress {
    [self.playerMenuViewController setCurrentTrackProgress:progress];
    CGFloat progressWidth = progress*self.view.frame.size.width;
    self.largeProgressViewWidth.constant = progressWidth;
}

#pragma mark - Notification center

- (void)like:(NSNotification *)notification {
    MFTrackItem *trackItem=[[notification userInfo] objectForKey:@"trackItem"];
    if ([self.trackItem.itemId isEqual:trackItem.itemId]) {
        if (!self.trackItem.isLiked){
            [self.trackItem likeTrackItem];
        }
        [self setTrackInfo:self.trackItem];
    }
}

- (void)unlike:(NSNotification *)notification {
    MFTrackItem *trackItem=[[notification userInfo] objectForKey:@"trackItem"];
    if ([self.trackItem.itemId isEqual:trackItem.itemId]) {
        if (self.trackItem.isLiked){
            [self.trackItem dislikeTrackItem];
        }
        [self setTrackInfo:self.trackItem];
    }
}

- (void)likeNew:(NSNotification *)notification {
    NSString *trackID=[[notification userInfo] objectForKey:@"trackID"];
    if ([self.trackItem.itemId isEqual:trackID]) {
        if (!self.trackItem.isLiked){
            [self.trackItem likeTrackItem];
        }
        [self setTrackInfo:self.trackItem];
    }
}

- (void)unlikeNew:(NSNotification *)notification {
    NSString *trackID=[[notification userInfo] objectForKey:@"trackID"];
    if ([self.trackItem.itemId isEqual:trackID]) {
        if (self.trackItem.isLiked){
            [self.trackItem dislikeTrackItem];
        }
        [self setTrackInfo:self.trackItem];
    }
}

#pragma mark - PlayerVCDelegate

- (void)startPlayingTrack:(MFTrackItem*)trackItem
{
    [self resumeTrack];
    
    [self setTrackInfo:trackItem];
    if ([trackItem isYoutubeTrack]) {
        self.currentVideoId = [trackItem videoID];
    }
    else {
        self.currentVideoId = nil;
    }
    
    self.updateProgressAutomatically = YES;
}

- (void)pauseTrack
{
    [self.bigPlayButton setSelected:NO];
}

- (void)resumeTrack
{
    [self.bigPlayButton setSelected:YES];
}

- (void)stopTrack
{
    [self pauseTrack];
    self.currentVideoId = nil;
    
    [self prepareUI];
}

- (void)playbackAvailable:(BOOL)available
{
//    self.view.userInteractionEnabled=available;
    
    [self pauseTrack];

    
    [self setTrackItem:playerManager.currentTrack];
    [self updateLoadingState:available];

}

- (void)updateLoadingState:(BOOL)isLoading
{
    if(isLoading){
        //if (![playerManager.currentTrack isYoutubeTrack]) {
            [self.bigActivityView startAnimating];
        //}
        if ([playerManager.currentTrack isYoutubeTrack]&&(!self.isNativePlayer))
            [self.bigActivityView stopAnimating];
    }else{
        [self.bigActivityView stopAnimating];
    }
}

- (void)updateProgress:(CGFloat)progress
{
    [self updateProgress:progress forced:NO];
}

- (void)updateProgress:(CGFloat)progress forced:(BOOL)forced
{
    if( currentTrackDuration == 0 ) {
        currentTrackDuration=[playerManager trackDuration];
    }
    
    if (!self.isNativePlayer && !forced && !self.updateProgressAutomatically && ABS(currentTrackPosition - progress*currentTrackDuration)<2) {
        self.updateProgressAutomatically = YES;
    }
    
    if (forced || self.updateProgressAutomatically) {
        [self setProgress:progress];
        [self setProgress:progress];
        
        CGFloat pointerPosition = ceil(CGRectGetWidth(self.view.frame)*progress) - 40.f;
        self.trackPointerLeading.constant = pointerPosition;
        self.progressLabel.text = [self formattedTime:progress*currentTrackDuration];
        self.remainedTimeLabel.text = [NSString stringWithFormat:@"-%@", [self formattedTime:(1.0 - progress)*currentTrackDuration]];
        currentTrackPosition = progress*currentTrackDuration;
        
    }
}

- (void)loadingFinished {
    [self updateLoadingState:NO];
}

- (void)startBuffering {
    [self.bigActivityView stopAnimating];
}

- (void)hidePlayer {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }
//
//    MFSideMenuContainerViewController *container=(MFSideMenuContainerViewController*)self.parentViewController;
//    //if nill then we aasume that we in landscape orientation
//    if (container != nil) {
//        [[UIApplication sharedApplication] setStatusBarHidden:NO
//                                                withAnimation:UIStatusBarAnimationSlide];
//        [container hidePlayerView];
//        
//        [self showSmallPlayerView];
//        self.hideButton.hidden = YES;
//        self.airPlayView.hidden = YES;
//        //[self toogleStatusBar];
//    }
//
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFHidePlayer" object:nil];
}

#pragma mark - IBActions

- (IBAction)didTouchUpPlayButton:(id)sender{
    
    [playerManager setDelegateVC:self];
    
    if (_isPreview && playerManager.currentTrack == nil) {
            }
    
    else {
        if (playerManager.currentTrack.trackState == IRTrackItemStatePlaying)
        {
            [playerManager pauseTrack];
            [self.actionView makePauseAnimationForced:YES];
        }
        else if (playerManager.currentTrack.trackState != IRTrackItemStateFailed)
        {
            [playerManager resumeTrack];
            [self.actionView makePlayAnimationForced:YES];
        }
    }
}

- (IBAction)didTouchUpNextButton:(id)sender {
    [playerManager setIsManualTrackSwitching:YES];
    [playerManager nextTrack];
    [self.actionView makeNextAnimation];
    
}

- (IBAction)didTouchUpPreviousButton:(id)sender {
    [playerManager setIsManualTrackSwitching:YES];
    [playerManager prevTrack];
    [self.actionView makePrevAnimation];
}

- (IBAction)didTouchUpHideButton:(id)sender {
    [self hidePlayer];

//    self.hideButton.hidden = YES;
//    self.airPlayView.hidden = YES;
}

#pragma mark - Track Info

- (void)setTrackInfo:(MFTrackItem*)trackItem{
    if (!_isPreview) {
        self.trackItem = trackItem;
        
        [self.trackNameLabel setText:trackItem.trackName];
    }
    
    if (trackItem.isYoutubeTrack) {
        [self.trackTypeIndicator setTitle:@"" forState:UIControlStateNormal];
    } else if (trackItem.isSoundcloudTrack) {
        [self.trackTypeIndicator setTitle:@"" forState:UIControlStateNormal];
    } else if (trackItem.isSpotifyTrack) {
        [self.trackTypeIndicator setTitle:@"" forState:UIControlStateNormal];
    }

    if (trackItem.isLiked) {
        self.likeButton.selected = YES;
    } else {
        self.likeButton.selected = NO;
    }
    if(![trackItem isHaveVideo]) {
        self.youtubePlayerView.hidden = YES;
        self.bigTrackImageView.hidden = YES;
        self.bigSquareTrackImageView.hidden = NO;
        [self setProgressInfoToTrackImage];
    }
    else {
        self.bigTrackImageView.hidden = playerManager.playing;
        self.bigSquareTrackImageView.hidden = YES;
        self.youtubePlayerView.hidden = NO;
        
        [self setProgressInfoToVideo];
    }
    if( self.previousTrackItem != trackItem) {
        self.previousTrackItem = trackItem;

        [self.bigTrackImageView sd_setImageWithURL:[NSURL URLWithString:trackItem.trackPicture]
                                  placeholderImage:nil
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                             if (trackItem.isYoutubeTrack) {
                                                 self.bigSquareTrackImageView.hidden = YES;
                                                 self.bigTrackImageView.hidden = NO;
                                             } else {
                                                 self.bigSquareTrackImageView.hidden = NO;
                                                 self.bigTrackImageView.hidden = YES;
                                             }
                                             [self.bigTrackImageView setImage:image];
                                             [self.bigSquareTrackImageView setImage:image];
                                             if (image) {
                                                 self.backgroundBlurPrevView.image = self.backgroundBlurView.image;

                                                 self.backgroundBlurView.image = image;
                                                 self.backgroundBlurView.alpha = 0.0;
                                                 [UIView animateWithDuration:1.0 animations:^{
                                                     self.backgroundBlurView.alpha = 1.0;
                                                 } completion:^(BOOL finished) {
                                                     
                                                 }];
                                                 
                                             } else {
//                                                 [self.backgroundBlurView setImage:nil];
                                             }
                                             
                                             
                                             
                                         }];
        
        currentTrackDuration=[playerManager trackDuration];
        self.progressLabel.text = [self formattedTime:0];
        self.remainedTimeLabel.text = [NSString stringWithFormat:@"-%@", [self formattedTime:currentTrackDuration]];

    }
    self.remainedTimeLabel.text = [NSString stringWithFormat:@"-%@", [self formattedTime:currentTrackDuration]];
    //[self.trackInfoView setDuration:[self formattedTime:playerManager.trackDuration]];
}

#pragma mark - Touch Actions

- (IBAction)didTapAtView:(id)sender
{
//    MFSideMenuContainerViewController *container=(MFSideMenuContainerViewController*)self.parentViewController;
//    [container showPlayerView];

//    [self hideSmallPlayerView];
//    self.hideButton.hidden = NO;
//    self.airPlayView.hidden = NO;
//    //[self toogleStatusBar];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES
//                                            withAnimation:UIStatusBarAnimationSlide];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFShowPlayer" object:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollFeedToPlayingTrack" object:nil];
    
}

- (IBAction)didSwipeDownAtView:(id)sender{
    //[self hidePlayer];
}

- (IBAction)didPanTrackPointer:(UIPanGestureRecognizer*)gestureRecognizer{
    
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateFailed || gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        CGPoint panLocation = [gestureRecognizer locationInView:_trackPointer.superview];
        CGFloat progress = panLocation.x/CGRectGetWidth(self.view.frame);
        
        [playerManager seekToOffset:progress];
        if (playerManager.currentTrack.trackState == IRTrackItemStatePaused) {
            //[playerManager resumeTrack];
        }
        
        
        
    }
    else
    {
        if (playerManager.currentTrack.trackState == IRTrackItemStatePlaying)
        {
            //[playerManager pauseTrack];
        }
        
        [self setUpdateProgressAutomatically:NO];
    
        CGPoint panLocation = [gestureRecognizer locationInView:_trackPointer.superview];
        CGFloat progress = panLocation.x/CGRectGetWidth(self.view.frame);
        [self updateProgress:progress forced:YES];
    }

    
}

- (void)didTapInFullscreen:(id)sender
{
    [self.progressContainer setHidden:!self.progressContainer.isHidden];
    [self.hideButton setHidden:!self.hideButton.isHidden];
    [self.airPlayView setHidden:!self.airPlayView.isHidden];

    [self.tapInFullscreenTimer invalidate];

    if (!self.progressContainer.hidden) {
        self.tapInFullscreenTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(hideFullscreenControls) userInfo:nil repeats:NO];
    }

}

-(void)hideFullscreenControls{
    
    [self.progressContainer setHidden:YES];
    [self.hideButton setHidden:YES];
    [self.airPlayView setHidden:YES];
    
}

#pragma mark - Small player view methods


#pragma mark - Comment View Controller Delegate

- (void)didAddComment{
    [self.trackItem addComment];
}
- (void)didRemoveComment{
    [self.trackItem removeComment];
}
- (void)willCloseCommentController{}

#pragma mark - Helpers

- (NSString *)formattedTime:(CGFloat)totalSeconds
{
    int minutes = (int)(totalSeconds / 60) % 60;
    int hours = (int)(totalSeconds / 3600);
    int seconds = (int)ceil(totalSeconds-hours*3600-minutes*60);
    if (seconds == 60){
        seconds = 0;
        minutes++;
    }
    if (minutes == 60){
        minutes = 0;
        hours++;
    }
    
    if(hours>0)
    {
        return [NSString stringWithFormat:@"%01d:%02d:%02d",hours, minutes, seconds];
    }
    else
    {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
}

//TODO
- (void)setProgressInfoToVideo{
//    CGRect frame=self.progressInfoView.frame;
//    frame.origin.y=INFO_VIDEO_OFFSET;
//    [self.progressInfoView setFrame:frame];
}
- (void)setProgressInfoToTrackImage{
//    CGRect frame=self.progressInfoView.frame;
//    frame.origin.y=INFO_TRACK_IMAGE_OFFSET;
//    [self.progressInfoView setFrame:frame];
}

- (void)toogleStatusBar {
    if ([UIApplication sharedApplication].statusBarHidden == NO) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationSlide];
    }
}

#pragma mark - Error message methods


#pragma mark - TrackInfoView Delegate methods

- (void)didLikeTrack:(MFTrackItem *)track
{


    [[IRNetworkClient sharedInstance]likeTrackById:self.trackItem.itemId
                                         withEmail:userManager.userInfo.email
                                             token:[userManager fbToken]
                                      successBlock:^{
                                          [self.trackItem likeTrackItem];

                                          NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.trackItem
                                                                                               forKey:@"trackItem"];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:PlayerLikeNotificationEvent
                                                                                              object:self
                                                                                            userInfo:userInfo];
                                          [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
                                          [MFNotificationManager postTrackLikedNotification:track];
                                          [self hideTopErrorViewWithMessage:self.kConnectedMessage];
                                      }
                                      failureBlock:^(NSString *errorMessage){
                                          [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self];
                                          self.likeButton.selected = NO;
                                      }];
    self.likeButton.selected = YES;
    //[self setTrackInfo:self.trackItem];
}

- (void)didUnlikeTrack:(MFTrackItem *)track
{

    
    
    [[IRNetworkClient sharedInstance]unlikeTrackById:self.trackItem.itemId
                                           withEmail:userManager.userInfo.email
                                               token:[userManager fbToken]
                                        successBlock:^{
                                            [self.trackItem dislikeTrackItem];

                                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.trackItem
                                                                                                 forKey:@"trackItem"];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:PlayerUnlikeNotificationEvent
                                                                                                object:self
                                                                                              userInfo:userInfo];
                                            [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
                                            [MFNotificationManager postTrackDislikedNotification:track];

                                            [self hideTopErrorViewWithMessage:self.kConnectedMessage];
                                        }
                                        failureBlock:^(NSString *errorMessage){
                                            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self];
                                            self.likeButton.selected = YES;
                                        }];
    
    //[self setTrackInfo:self.trackItem];
    self.likeButton.selected = NO;
}

- (void)didSelectShare:(MFTrackItem *)track
{
    self.trackItem = track;
    [self showSharing];
}

- (void)didSelectDownload:(MFTrackItem *)track
{
    self.trackItem = track;
    [self buyWithITunes];
}

- (void)didAddTrackToPlaylist:(MFTrackItem *)track
{
    PlaylistsViewController *playlistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
    playlistsVC.container = self.container;
    playlistsVC.trackToAdd = track;
    
    [self.currentViewController.navigationController pushViewController:playlistsVC animated:YES];
    if (!_isPreview) {
        [self didTouchUpHideButton:nil];
    }
}

- (void)shouldShowComments:(MFTrackItem *)track
{
    
//    TrackInfoViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"trackInfoViewController"];
//    trackInfoVC.container = self.container;
//    trackInfoVC.trackItem = self.trackItem;
//    trackInfoVC.playDelegate = self;
//    trackInfoVC.isCommentsView = YES;
    
//    CommentsViewController *commentsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
//    [commentsVC setTrackItem:self.trackItem];
//    [commentsVC setDelegate:self];
//    commentsVC.container = self.container;
//    
//    [self.currentViewController.navigationController pushViewController:commentsVC animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MFSingleTrackViewController *trackInfoVC = [storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = track;
    trackInfoVC.container = self.container;
    
    [self.currentViewController.navigationController pushViewController:trackInfoVC animated:YES];
    if (!_isPreview) {
        [self didTouchUpHideButton:nil];
    }
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

//    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight){
//        if ([NSObject appDelegate].isShowVideo) {
//            _videoHeight.constant = [UIScreen mainScreen].bounds.size.height;
//            _videoBottom.constant = [UIScreen mainScreen].bounds.size.width - [UIScreen mainScreen].bounds.size.height;
//        }
//    } else if (orientation == UIDeviceOrientationPortrait) {
//
//        _videoHeight.constant = [UIScreen mainScreen].bounds.size.width*9.0/16.0;
//        _videoBottom.constant = 0.0;
//    }

//    return;

//    if (UIInterfaceOrientationIsLandscape(orientation)) {
//        NSLog(@"toLandscape");
//        isRotatedToPortraitOrientation = NO;
//        self.controlsView.hidden = YES;
//        self.labelsView.hidden = YES;
//        self.hideButton.hidden = YES;
//        self.airPlayView.hidden = YES;
//        self.errorView.hidden = YES;
//        self.bigProgressView.hidden = YES;
//        self.trackView.hidden = YES;
//        self.tapToPauseView.hidden = YES;
//        //self.imageViewTopConstraint.constant = 0.0f;
//        //self.playerViewTopConstraint.constant = 0.0f;
//        self.playerViewLeadingConstraint.constant = 0.0f;
//        self.playerViewTrailingConstraint.constant = 0.0f;
//        self.squareImageViewTopConstraint.constant = 0.0f;
//        self.squareImageViewBotConstraint.constant = -268.0f;
//        [self.view addGestureRecognizer:self.playerViewTap];
//        [self.view addGestureRecognizer:self.playerViewSwipeLeft];
//        [self.view addGestureRecognizer:self.playerViewSwipeRight];
//        self.actionView.hidden = NO;
//        self.imageViewBottomConstraint.constant = 0;
//
//    }
//    else {
//        NSLog(@"toPortrait");
//        isRotatedToPortraitOrientation = YES;
//        self.controlsView.hidden = NO;
//        self.labelsView.hidden = NO;
//        self.hideButton.hidden = NO;
//        self.airPlayView.hidden = NO;
//        self.errorView.hidden = NO;
//        self.bigProgressView.hidden = NO;
//        self.trackView.hidden = NO;
//        //self.tapToPauseView.hidden = NO;
//        //self.imageViewTopConstraint.constant = 60.0f;
//        //self.playerViewTopConstraint.constant = 60.0f;
//        self.playerViewLeadingConstraint.constant = 0.0f;
//        self.playerViewTrailingConstraint.constant = 0.0f;
//        self.squareImageViewTopConstraint.constant = 60.0f;
//        self.squareImageViewBotConstraint.constant = 0.0f;
//        [self.view removeGestureRecognizer:self.playerViewTap];
//        [self.view removeGestureRecognizer:self.playerViewSwipeLeft];
//        [self.view removeGestureRecognizer:self.playerViewSwipeRight];
//        self.actionView.hidden = YES;
//
//    }

//    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight){
//        if (playerManager.haveTrack&&_isSmall){
//            _isShownFromFeed = YES;
//            [self didTapAtView:nil];
//            NSLog(@"showPlayer");
//
//            [UIViewController attemptRotationToDeviceOrientation];
//        }
//    } else {
//        if (playerManager.haveTrack&&!_isSmall&&_isShownFromFeed&&isRotatedToPortraitOrientation){
//            _isShownFromFeed = NO;
//            [self hidePlayer];
//            NSLog(@"hidePlayer");
//        }
//    }

}

- (NSArray*)buttonTitlesForSharing{
    NSMutableArray *buttonTitles = [NSMutableArray arrayWithArray:@[@"Facebook", @"Tweet", @"Email", NSLocalizedString(@"Message",nil), NSLocalizedString(@"Copy Link",nil)]];
    return buttonTitles;
}

- (void)configureForState:(BOOL)isHidden{
    _isSmall = isHidden;
}

- (BOOL)changesStatusBarStyle{
    return NO;
}

- (IBAction)playerPanned:(id)sender {
    [_pannableDelegate viewPanned:sender];

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        if (gestureRecognizer == _trackPointerPanRecognizer) {
            return YES;
        } else {
            return NO;
        }
    }

    if (gestureRecognizer == self.playerPanGestureRecognizer && !self.playerMenuContainerView.hidden) {
        return NO;
    }
    CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self.headerContainer];
    if (gestureRecognizer == self.playerPanGestureRecognizer) {
        return fabs(velocity.y) > fabs(velocity.x);
    } else {
        return fabs(velocity.y) < fabs(velocity.x);
    }
}

- (IBAction)headerPanned:(UIPanGestureRecognizer *)sender {
    CGPoint loc1 = [sender locationInView:_imageContainer];


    if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled) {

        CGFloat maxSize = _headerContainer.bounds.size.width*0.81;
        CGFloat phase = _imageToLeading.constant/maxSize;

        if (_buttonsShown) {
            if (phase<1.0) {
                if (_velocity<150) {
                    CGFloat time = ABS(phase*maxSize/((CGFloat)_velocity));
                    if (time>0.3) time = 0.3f;
                    [self hideButtons:time];
                } else {
                    CGFloat time = ABS((1.0f-phase)*maxSize/(CGFloat)_velocity);
                    if (time>0.3) time = 0.3f;
                    [self showButtons:time];
                }
            } else {
                [self showButtons:0.3f];
            }
        } else {
            if (phase>0.0) {
                if (_velocity<-150) {
                    CGFloat time = ABS(phase*maxSize/((CGFloat)_velocity));
                    if (time>0.3) time = 0.3f;
                    [self hideButtons:time];
                } else {
                    CGFloat time = ABS((1.0f-phase)*maxSize/(CGFloat)_velocity);
                    if (time>0.3) time = 0.3f;
                    [self showButtons:time];
                }
            } else {
                [self hideButtons:0.3f];
            }
        }
        _velocity=0;
        _isDragging = NO;

    } else {
        CGPoint loc2 = [sender locationInView:_headerContainer];
        if (!_isDragging) {
            _isDragging = YES;
            _anchorPoint = loc1.x;
        }
        CGFloat currentHeight = loc2.x - _anchorPoint;
        if (currentHeight<0) {
            currentHeight=0;
        }
        CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
        _velocity = (currentHeight - _lastHeight)/(currentTime - _lastTime);
        _lastTime = currentTime;
        _lastHeight = currentHeight;
        _imageToLeading.constant = currentHeight;
    }

}

- (void) showButtons:(CGFloat)time{
    _buttonsShown = YES;
    [self.headerContainer layoutIfNeeded];
    _imageToLeading.constant = _headerContainer.bounds.size.width*0.81;
    [UIView animateWithDuration:time delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.headerContainer layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

- (void) hideButtons:(CGFloat)time{
    _buttonsShown = NO;
    [self.headerContainer layoutIfNeeded];
    _imageToLeading.constant = 0.0;
    [UIView animateWithDuration:time delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.headerContainer layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
    
}

- (IBAction)moreButtonTapped:(id)sender {
    [self showButtons:0.3];
}

- (IBAction)playerMenuButtonTapped:(id)sender {
    if (!_playerMenuViewController) {
        self.playerMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MFPlayerMenuViewController"];
        self.playerMenuViewController.view.frame = self.playerMenuContainerView.bounds;
        [self.playerMenuContainerView addSubview:self.playerMenuViewController.view];
        self.playerMenuViewController.delegate = self;
    }

    [[NSObject appDelegate] setIsShowVideo:NO];
    self.mainPlayerView.hidden = YES;
    self.playerMenuContainerView.hidden = NO;
    
}

-(void) playerMenuViewControllerDidSelectDone:(MFPlayerMenuViewController *)controller{

    [[NSObject appDelegate] setIsShowVideo:YES];
    self.playerMenuContainerView.hidden = YES;
    self.mainPlayerView.hidden = NO;

}

- (IBAction)postButtonTapped:(id)sender {
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }

    [[IRNetworkClient sharedInstance] publishTrackByID:self.trackItem.itemId SuccessBlock:^(NSDictionary *dictionary) {
        [[MFMessageManager sharedInstance] showTrackRepostedMessageInViewController:self];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self];

    }];
    [self hideButtons:0.3];
}
- (IBAction)addToPlaylistButtonTapped:(id)sender {
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }

    PlaylistsViewController *playlistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
    playlistsVC.additionDelegate = self;
    playlistsVC.trackToAdd = self.trackItem;
    [(UIViewController*)self.pannableDelegate presentViewController:playlistsVC animated:YES completion:nil];
    [self hideButtons:0.3];
}
- (IBAction)shareButtonTapped:(id)sender {
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }
    
    [self showSharing];
    [self hideButtons:0.3];
}

- (void)playlistsViewController:(PlaylistsViewController *)playlistsViewController didFinishWithResult:(BOOL)trackAdded{
    [playlistsViewController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }];
}

- (void)didAddTrack:(MFTrackItem *)trackItem toPlaylist:(MFPlaylistItem *)playlist{
    
}

- (IBAction)likeButtonTapped:(id)sender {
    if (!self.trackItem.isLiked) {
        [self didLikeTrack:self.trackItem];
    } else {
        [self didUnlikeTrack:self.trackItem];
    }
}

- (void) adjustForTransparencySettings{
    if (UIAccessibilityIsReduceTransparencyEnabled()) {
        self.grayViewForDisabledTransparency.hidden = NO;
    } else {
        self.grayViewForDisabledTransparency.hidden = YES;
    }
}
- (IBAction)trackNameTapped:(id)sender {
    if (self.trackItem) {
        [self.pannableDelegate didTapAtTrackNameForTrack:self.trackItem];
    }
}
@end
