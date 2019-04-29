//
//  TrackView.m
//  botmusic
//
//  Created by Supervisor on 06.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "TrackView.h"
#import "UIColor+Expanded.h"
#import "UIImage+Resize.h"
#import "NDMusicControl.h"
#import <MFNotificationManager.h>
#import "MGSwipeButton.h"
#import "UIImageView+WebCache_FadeIn.h"

static NSString * const kTrackStateKeyPath = @"trackItem.trackState";

static CGFloat trackViewWidth;
static CGFloat trackViewHeight;
static UIImage* defaultImage;
static UIImage* defaultAvatar;

@interface TrackView() <MGSwipeTableCellDelegate>
@property (nonatomic, strong) NDMusicControl *musicControl;
@property (nonatomic, assign) BOOL isAnimated;
@end

@implementation TrackView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addObserver:self forKeyPath:kTrackStateKeyPath
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:nil];
    }
    return self;
}

+ (TrackView *)createTrackView {
    TrackView* trackView = [[[NSBundle mainBundle]loadNibNamed:@"TrackView" owner:nil options:nil] lastObject];
    CGRect frame = trackView.frame;
    frame.size.height = [TrackView trackViewHeight];
    frame.size.width = [TrackView trackViewWidth];
    trackView.frame = frame;
    [trackView makeGradient];
    if (!defaultImage) {
        defaultImage = [UIImage imageNamed:@"DefaultArtwork"];
        defaultAvatar = [UIImage imageNamed:@"defaultAvatar.jpg"];
    }
    return trackView;
}

- (void)makeGradient{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*0.75);
    UIColor *startColour = [UIColor colorWithWhite:0.0 alpha:0.8];
    UIColor *endColour = [UIColor colorWithWhite:0.0 alpha:0.0];
    [gradient setStartPoint:CGPointMake(0.5, 0.0)];
    [gradient setEndPoint:CGPointMake(0.5, 1.0)];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [_gradientContainer.layer addSublayer:gradient];
}

+ (CGFloat) trackViewWidth{
    if (trackViewWidth) {
        return trackViewWidth;
    } else {
        trackViewWidth = MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    return trackViewWidth;
}

+ (CGFloat) trackViewHeight{
//    if (trackViewHeight) {
//        return trackViewHeight;
//    } else {
//        trackViewHeight = TRACK_VIEW_HEIGHT - (MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width) - TRACK_VIEW_HEIGHT + TRACK_VIEW_FOOTER_HEIGHT)/15;
//    }
//    return trackViewHeight;
    return [TrackView trackViewWidth];
}

#pragma mark - Settings Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self addObserver:self forKeyPath:kTrackStateKeyPath
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentAdded:)
                                                 name: [MFNotificationManager nameForNotification:MFNotificationTypeCommentsCountChanged] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toPlaylistAdded:)
                                                 name: [MFNotificationManager nameForNotification:MFNotificationTypeAddedToPlaylist] object:nil];
    [self defaultSettings];
}

- (void)commentAdded:(NSNotification *)notification;
{
    NSString* trackID = [[notification userInfo] objectForKey:@"trackID"];
    if([trackID isEqualToString:self.trackItem.itemId]){
//        self.trackItem.lastActivityType = @"Comment";
//        self.trackItem.lastActivityTime = [NSDate date];
        [self setTrackInfo:self.trackItem];
    }
}

- (void)toPlaylistAdded:(NSNotification *)notification;
{
    NSString* trackID = [[notification userInfo] objectForKey:@"trackID"];
    if([trackID isEqualToString:self.trackItem.itemId]){
//        self.trackItem.lastActivityType = @"Playlist";
//        self.trackItem.lastActivityTime = [NSDate date];
        [self setTrackInfo:self.trackItem];
    }
}


- (void)dealloc {
    [self removeObserver:self
              forKeyPath:kTrackStateKeyPath
                 context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)defaultSettings {    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapRecognize:)];
    [tap setNumberOfTapsRequired:1];
    [self.playTapView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tapLikesLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAtLikesLabel:)];
    [self.likesLabel addGestureRecognizer:tapLikesLabel];
    
    UITapGestureRecognizer *tapCommentsLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAtCommentsLabel:)];
    [self.commentsLabel addGestureRecognizer:tapCommentsLabel];
    
    UITapGestureRecognizer *tapTrackNameView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectShowTrackInfo:)];
    [self addGestureRecognizer:tapTrackNameView];
    
    UITapGestureRecognizer *tapUserInfoView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAtUserThumb:)];
    [self.autorImageView addGestureRecognizer:tapUserInfoView];
    
    [self createActionView];
    
    [self roundUserImage];
    
    [self createMusicControl];
    
}

- (void)createActionView {
    _actionView=[ActionViewCreator createActionViewInView:self.animationView];
    [_actionView setDelegate:self];
}

- (void)roundUserImage {
    _autorImageView.layer.cornerRadius = _autorImageView.frame.size.width / 2;
    _autorImageView.clipsToBounds=YES;
}

- (void)createMusicControl {
    CGFloat musicControlSize = 50;
    _musicControl = [[NDMusicControl alloc] initWithFrame:CGRectMake(CGRectGetMidX(_upperView.bounds) - musicControlSize/2,
                                                                     [TrackView trackViewHeight]/2 - musicControlSize/2 - 30,
                                                                     musicControlSize,
                                                                     musicControlSize)];
    _musicControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [_musicControl addTarget:self action:@selector(musicControlTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [_upperView addSubview:_musicControl];
    _musicControl.hidden = YES;
}

- (void)setTapEnable:(BOOL)tapEnable {
    _tapEnable = tapEnable;
    self.musicControl.hidden = YES;
}

#pragma mark - Tap Recogizer Methods

- (void)tapRecognize:(UITapGestureRecognizer*)tapRecognizer {
    if (self.trackItem.trackState == IRTrackItemStatePlaying) {
        //[_actionView makePauseAnimation];
    } else {
        //[self makeStartPlayingAnimation];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnView:)]) {
        [_delegate didTapOnView:_trackItem];
    }
}

- (void)like {
    if (_delegate && [_delegate respondsToSelector:@selector(didLike:)]) {
        [_delegate didLike:_trackItem];
    }
}

- (void)unlike {
    if (_delegate && [_delegate respondsToSelector:@selector(didUnlike:)]) {
        [_delegate didUnlike:_trackItem];
    }
}

- (void)didTapAtUserThumb:(UITapGestureRecognizer*)tap {
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectShowFriend:)]) {
        [_delegate didSelectShowFriend:_trackItem];
    }
}

- (void)didTapAtCommentsLabel:(UITapGestureRecognizer*)tap {
    [self didSelectComment:nil];
}

- (void)didTapAtLikesLabel:(UITapGestureRecognizer*)tap {
    [self didSelectLike:nil];
}

#pragma mark - Actions

- (IBAction)didSelectShare:(id)sender {
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(didShare:)]) {
        [_delegate didShare:_trackItem];
    }
}

- (IBAction)didSelectLike:(id)sender {
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (!(networkStatus == NotReachable)) {
        if (_isLiked) {
            _isLiked = NO;
            [self unlike];
        } else {
            _isLiked = YES;
            
            [self like];
        }
    }
}

- (IBAction)didSelectComment:(id)sender {
    if (_isCommentsOpen) {
//        if (_delegate && [_delegate respondsToSelector:@selector(didDeselectComent:)]) {
//            [_delegate didDeselectComent:_indexPath];
//        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(didSelectComment:)]) {
            [_delegate didSelectComment:_trackItem];
        }
    }
}

- (IBAction)didSelectPlayVideo:(id)sender {
//    if (_delegate && [_delegate respondsToSelector:@selector(didPlayVideo:)]) {
//        [_delegate didPlayVideo:_indexPath];
//    }
}

- (IBAction)didSelectShowTrackInfo:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldOpenTrackInfo:)]) {
        [self.delegate shouldOpenTrackInfo:_trackItem];
    }
}

- (IBAction)didSelectAddToPlaylist:(id)sender {
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(didAddToPlaylist:)]) {
        [self.delegate didAddToPlaylist:_trackItem];
    }
}

#pragma mark - Track Info

- (void)setTrackInfo:(MFTrackItem *)trackItem {
    // Remove observer to ignore animation when cell is reused
    [self removeObserver:self
              forKeyPath:kTrackStateKeyPath
                 context:nil];
    // Set track item
    [self setValue:trackItem forKey:@"trackItem"];
    // Add observer for track state
    [self addObserver:self forKeyPath:kTrackStateKeyPath
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:nil];
    
    // Set gradient background if track is playing
    if (trackItem.trackState == NDMusicConrolStateTypeLoading
        || trackItem.trackState == NDMusicConrolStateTypePaused
        || trackItem.trackState == NDMusicConrolStateTypePlaying) {
//        [_playingView setAlpha:0.4];
        if (trackItem.trackState == NDMusicConrolStateTypePaused) {
            [_actionView showPauseButton];
            //[_actionView showPlayButton];
        } else {
            //[_actionView showPauseButton];
            [_actionView showPlayingButton];
        }
    } else {
        [_actionView showPlayButton];

        [_playingView setAlpha:0.0];
//        [_actionView hideAllButtons];
    }
    
    [self setTrackName:trackItem.trackName];
    [self setDuration:trackItem.authorName];
    
    self.verifiedLabel.hidden = !trackItem.isVerifiedUser;
    self.verifiedBackLabel.hidden = !trackItem.isVerifiedUser;
    
    NSURL* cellUrl = [NSURL URLWithString:trackItem.trackPicture];
    if (cellUrl != nil) {
        if (trackItem.isYoutubeTrack) {
            _imageViewTopConstraint.constant = -trackViewWidth/4.0;
        } else {
            _imageViewTopConstraint.constant = 0;
        }
        [_trackImage sd_setImageAndFadeOutWithURL:cellUrl placeholderImage:defaultImage];
    }

    NSURL* avatarUrl = [NSURL URLWithString:trackItem.authorPicture relativeToURL:BASE_URL];
    //if (avatarUrl != nil) {
        [_autorImageView sd_setAvatarWithUrl:avatarUrl name:trackItem.authorName];
    //}
    
//    _likesLabel.text=[NSString stringWithFormat:@"%d",[trackItem.likes intValue]];
//    _commentsLabel.text=[NSString stringWithFormat:@"%d",[trackItem.comments intValue]];

    [self setIsLiked:trackItem.isLiked];
    [self.feedTimeLabel setText:[trackItem.lastFeedAppearanceDate timeAgo]];
    
//    if(self.trackItem.lastActivityTime) {
//        [self.feedTimeLabel setText:[trackItem.lastActivityTime timeAgo]];
//    }
//    else {
//        [self.feedTimeLabel setText:[trackItem.timestamp timeAgo]];
//    }

    for (UIButton* button in _correspondingCell.rightButtons) {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    }
    for (UIButton* button in _correspondingCell.leftButtons) {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    }
}

- (void)configureButtons{
    //configure right buttons
    CGFloat buttonWidth = [UIScreen mainScreen].bounds.size.width*0.27;

    MGSwipeButton *swipeButtonRemove = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Not Interested",nil)
                                                                 icon:[UIImage imageNamed:@"delete"]
                                                      backgroundColor:[UIColor colorWithRGBHex:0xFF0044]
                                                              padding:5.0f
                                                             callback:^BOOL(MGSwipeTableCell *sender) {
                                                                 [self didDeleteTrack];
                                                                 return YES;
                                                             }];
    [swipeButtonRemove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [swipeButtonRemove.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    swipeButtonRemove.tag = _indexPath.row;
    swipeButtonRemove.buttonWidth = buttonWidth;
    [swipeButtonRemove centerIconOverText];

    UIPanGestureRecognizer *removePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:_correspondingCell action:@selector(panHandler:)];
    [swipeButtonRemove addGestureRecognizer:removePanRecognizer];

    _correspondingCell.rightButtons =  @[swipeButtonRemove];
    _correspondingCell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    _correspondingCell.delegate = self;
    MGSwipeExpansionSettings* sws = [[MGSwipeExpansionSettings alloc] init];
    sws.buttonIndex = 0;
    sws.fillOnTrigger = YES;
    sws.threshold = 1.5;
    _correspondingCell.rightExpansion = sws;
    [self.restoreButton setHidden:YES];


    MGSwipeButton *swipeButtonRepost = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Repost",nil)
                                                                 icon:[UIImage imageNamed:@"repost"]
                                                      backgroundColor:[UIColor colorWithRGBHex:0x3284FF]
                                                              padding:10.0f
                                                             callback:^BOOL(MGSwipeTableCell *sender) {
                                                                 [self didRepost];
                                                                 return YES;
                                                             }];


    [swipeButtonRepost setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [swipeButtonRepost.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    swipeButtonRepost.tag = _indexPath.row;
    swipeButtonRepost.buttonWidth = buttonWidth;
    [swipeButtonRepost centerIconOverText];
    
    UIPanGestureRecognizer *repostPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:_correspondingCell action:@selector(panHandler:)];
    [swipeButtonRepost addGestureRecognizer:repostPanRecognizer];

    MGSwipeButton *swipeButtonAdd = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Add to Playlist",nil)
                                                              icon:[UIImage imageNamed:@"add"]
                                                      backgroundColor:[UIColor colorWithRGBHex:0x8B8A90]
                                                              padding:10.0f
                                                             callback:^BOOL(MGSwipeTableCell *sender) {
                                                                 [self didSelectAddToPlaylist:nil];
                                                                 return YES;
                                                             }];


    [swipeButtonAdd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    swipeButtonAdd.buttonWidth = buttonWidth;
    [swipeButtonAdd.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    swipeButtonAdd.tag = _indexPath.row;
    [swipeButtonAdd centerIconOverText];

    UIPanGestureRecognizer *addPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:_correspondingCell action:@selector(panHandler:)];
    [swipeButtonAdd addGestureRecognizer:addPanRecognizer];

    MGSwipeButton *swipeButtonShare = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Share",nil)
                                                                icon:[UIImage imageNamed:@"share"]
                                                   backgroundColor:[UIColor colorWithRGBHex:0xA3A3A6]
                                                           padding:10.0f
                                                          callback:^BOOL(MGSwipeTableCell *sender) {
                                                              [self didSelectShare:nil];
                                                              return YES;
                                                          }];


    [swipeButtonShare setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [swipeButtonShare.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    swipeButtonShare.tag = _indexPath.row;
    swipeButtonShare.buttonWidth = buttonWidth;
    [swipeButtonShare centerIconOverText];

    UIPanGestureRecognizer *sharePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:_correspondingCell action:@selector(panHandler:)];
    [swipeButtonShare addGestureRecognizer:sharePanRecognizer];

    _correspondingCell.leftButtons =  @[swipeButtonRepost, swipeButtonAdd, swipeButtonShare];
    _correspondingCell.leftSwipeSettings.transition = MGSwipeTransitionBorder;


}

-(void)didRepost{
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(didRepostTrack:)]) {
        [_delegate didRepostTrack:_trackItem];
    }
}

-(void)panHandler:(UIPanGestureRecognizer *)gesture
{
    [_correspondingCell panHandler:gesture];
}

- (void)didDeleteTrack{

    if (_delegate && [_delegate respondsToSelector:@selector(didDelete:)]) {
        [_delegate didDelete:_trackItem];
    }

}

- (void)setIsLiked:(BOOL)isLiked {
    _likesLabel.text=[NSString stringWithFormat:@"%d",[self.trackItem.likes intValue]];
    if (isLiked) {
//        [_likesLabel setTextColor:[UIColor selectedColor]];
        [self.likeButton setTitle:[NSString stringWithUTF8String:"\uF140"] forState:UIControlStateNormal];
        [self.likeButton setTitleColor:[UIColor colorWithRGBHex:0xFF1A57] forState:UIControlStateNormal];
    } else {
        [self.likeButton setTitle:[NSString stringWithUTF8String:"\uF130"] forState:UIControlStateNormal];
        [self.likeButton setTitleColor:[UIColor colorWithRGBHex:0xFFFFFF] forState:UIControlStateNormal];
//         [_likesLabel setTextColor:[UIColor unselectedColor]];
    }
    
//    [_likeButton setSelected:isLiked];
    _isLiked=isLiked;
}

#pragma mark - Track State animations

- (void)trackStateChanged:(NDMusicConrolStateType)state {
    switch (state) {
        case NDMusicConrolStateTypeNotStarted:
            [self makeFinishPlayingAnimation];
            break;
        case NDMusicConrolStateTypeLoading:
            [self makeStartLoadingAnimation];
            break;
        case NDMusicConrolStateTypeFailed:
            [self makeFinishPlayingAnimation];
            break;
        case NDMusicConrolStateTypePaused:
            [_actionView showPauseButton];
            break;
        case NDMusicConrolStateTypePlaying:
            [self makeStartPlayingAnimation];
            break;
        default:
            break;
    }
    [_musicControl changePlayState:state];
}

- (void)makeStartPlayingAnimation {
    [_actionView showPlayingButton];
}

- (void)makeStartLoadingAnimation {
    [_actionView hideAllButtons];
    [_actionView makeLoadingAnimation];
}

- (void)makeFinishPlayingAnimation {
    [_actionView finishAllAnimations];
    [_actionView showPlayButton];

}

#pragma mark - Notification center events

- (void)playerWillExitFullscreen:(MPMoviePlayerController*)player {
    AppDelegate *delegate=[NSObject appDelegate];
    [delegate setIsShowVideo:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    id newObject = [change objectForKey:NSKeyValueChangeNewKey];

    if ([NSNull null] == (NSNull*)newObject)
        newObject = nil;

    if ([kTrackStateKeyPath isEqualToString:keyPath]) {
        [self trackStateChanged:[newObject integerValue]];
    }
}

#pragma mark - actions

- (void)musicControlTouched {
    if (_tapEnable) {
        if (_delegate && [_delegate respondsToSelector:@selector(didTapOnView:)]) {
            [_delegate didTapOnView:_trackItem];
        }
    }
}

- (void)didTouchUpRestoreButton:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didRestoreDeleted:)]) {
        [_delegate didRestoreDeleted:_indexPath];
    }
}

#pragma mark - Resizing methods

- (void)setTrackName:(NSString *)trackName {
    self.trackNameLabel.text = trackName;

//    CGRect trackNameFrame = self.trackNameLabel.frame;
//    trackNameFrame.size.width = [UIScreen mainScreen].bounds.size.width-90.0f;
//    self.trackNameLabel.frame = trackNameFrame;
//    
//    [self.trackNameLabel sizeToFit];
}

- (void)setDuration:(NSString *)duration {
    self.durationLabel.text = duration;
    
//    [self.durationLabel sizeToFit];
//    
//    CGRect durationFrame = self.durationLabel.frame;
//    durationFrame.origin.y = self.trackNameLabel.frame.origin.y + self.trackNameLabel.frame.size.height;
//    durationFrame.size.height = 20.0f;
//    self.durationLabel.frame = durationFrame;
}

#pragma mark - ActionViewDelegate methods

- (void)actionAnimationWillStart {
    _isAnimated = YES;
}

- (void)actionAnimationDidFinish {
    _isAnimated = NO;
}

- (IBAction)moreButtonTapped:(id)sender {
    [_correspondingCell showSwipe:MGSwipeDirectionLeftToRight animated:YES];
}

-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState) state gestureIsActive:(BOOL) gestureIsActive{
    switch (state) {
        case MGSwipeStateNone:
            cell.backgroundColor = [UIColor clearColor];
            break;

        case MGSwipeStateSwippingLeftToRight:
            cell.backgroundColor = [UIColor colorWithRGBHex:0xA3A3A6];
            break;

        case MGSwipeStateSwippingRightToLeft:
            cell.backgroundColor = [UIColor colorWithRGBHex:0xFF0044];
            break;

        default:
            break;
    }
}
@end
