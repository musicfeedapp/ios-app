//
//  PlaylistTrackCell.m
//  botmusic
//
//  Created by Panda Systems on 1/26/15.
//
//

#import "PlaylistTrackCell.h"

#import <UIColor+Expanded.h>

#import "UIImageView+WebCache_FadeIn.h"
#import <MFNotificationManager.h>
#import "Reachability.h"
#import "NDMusicControl.h"

static NSString * const kTrackStateKeyPath = @"track.trackState";
static UIImage* defaultArtwork;
static UIImage* playBig;
static UIImage* shareSmall;
static UIImage* playlistSmall;
static UIImage* repostSmall;
static UIImage* restore;
static UIImage* deleteSmall;
static UIImage* love;
static UIImage* loveSelected;
static UIImage* unlove;

@implementation PlaylistTrackCell

- (void)awakeFromNib
{
    self.separatorHeightConstraints.constant = 1.0/[UIScreen mainScreen].scale;
    
//    UITapGestureRecognizer *likesTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchUpLikesButton:)];
//    [self.likesLabel addGestureRecognizer:likesTap];

    UITapGestureRecognizer *playTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchThumb:)];
    [self.thumbTapView addGestureRecognizer:playTap];
    self.playingIndicator = [MFPlayerAnimationView playerAnimationViewWithFrame:self.playingIndicatorContainer.bounds color:[UIColor whiteColor]];
    [self.playingIndicatorContainer addSubview:self.playingIndicator];
//    UITapGestureRecognizer *commentsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchUpCommentsButton:)];
//    [self.commentsLabel addGestureRecognizer:commentsTap];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(trackLiked:)
//                                                 name:[MFNotificationManager nameForNotification:MFNotificationTypeTrackLiked]
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(trackDisliked:)
//                                                 name:[MFNotificationManager nameForNotification:MFNotificationTypeTrackDisliked]
//                                               object:nil];
    [self addObserver:self forKeyPath:kTrackStateKeyPath
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:nil];
    self.activityIndicator.color = [UIColor whiteColor];
    if (!defaultArtwork) {
        defaultArtwork = [UIImage imageNamed:@"DefaultArtwork"];
        playBig = [UIImage imageNamed:@"Play.png"];
        shareSmall = [UIImage imageNamed:@"shareSmall"];
        playlistSmall = [UIImage imageNamed:@"playlistSmall"];
        repostSmall = [UIImage imageNamed:@"repostSmall"];
        love = [UIImage imageNamed:@"love"];
        loveSelected = [UIImage imageNamed:@"love_selected"];
        restore = [UIImage imageNamed:@"restore"];
        deleteSmall = [UIImage imageNamed:@"deleteSmall"];
        unlove = [UIImage imageNamed:@"unlove"];

    }
    _smallPlayButton.image = playBig;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    if (selected) {
        self.trackNameLabel.textColor = [UIColor colorWithRGBHex:kBrandPinkColor];
    }
    else {
        if (self.isDarkBackGround) {
            self.trackNameLabel.textColor = [UIColor whiteColor];
        } else {
            self.trackNameLabel.textColor = [UIColor colorWithRGBHex:kDarkColor];
        }
    }
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    //[super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.trackNameLabel.textColor = [UIColor colorWithRGBHex:kBrandPinkColor];
    }
    else {
        if (self.isDarkBackGround) {
            self.trackNameLabel.textColor = [UIColor whiteColor];
        } else {
            self.trackNameLabel.textColor = [UIColor colorWithRGBHex:kDarkColor];
        }
    }
}

- (void)setTrack:(MFTrackItem *)track
{
    _track = track;
    
    self.trackNameLabel.text = track.trackName;
    self.durationLabel.text = track.authorName;

    if (self.isDarkBackGround) {
        self.trackNameLabel.textColor = [UIColor whiteColor];
    }
    NSURL* imageUrl = [NSURL URLWithString:track.trackPicture];
    if (!self.hideDefaultArtwork) {
        [self.trackImageView sd_setImageAndFadeOutWithURL:imageUrl
                               placeholderImage:defaultArtwork];
    } else {
        [self.trackImageView sd_setImageAndFadeOutWithURL:imageUrl
                               placeholderImage:nil];
    }

    for (UIButton* button in self.rightButtons) {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    }
    for (UIButton* button in self.leftButtons) {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    }

    if (self.leftButtons.count && self.track.isLiked) {
        [self showLike];
    } else if (self.leftButtons.count && !self.track.isLiked){
        [self showUnlike];
    }

}

- (void) checkIsPostedState{
    if (self.leftButtons.count) {
        MGSwipeButton* postButton = self.leftButtons[0];
        if (_track.isNotPosted) {
            [postButton setBackgroundColor:[UIColor colorWithRGBHex:0x00CC77]];
            [postButton setTitle:@"Post" forState:UIControlStateNormal];
            [postButton setImage:shareSmall forState:UIControlStateNormal];
            [postButton centerIconOverText];
        } else {
            [postButton setBackgroundColor:[UIColor colorWithRGBHex:0x3284FF]];
            [postButton setTitle:@"Repost" forState:UIControlStateNormal];
            [postButton setImage:repostSmall forState:UIControlStateNormal];
            [postButton centerIconOverText];
        }
    }
}

- (void)setIsRemovedTrack:(BOOL)isRemovedTrack
{
    _isRemovedTrack = isRemovedTrack;

    if (isRemovedTrack) {
        if (!self.rightButtons.count) {
            MGSwipeButton *swipeButtonRemove = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Restore",nil)
                                                                         icon:restore
                                                              backgroundColor:[UIColor colorWithRGBHex:0x1AC363]
                                                                      padding:3
                                                                     callback:^BOOL(MGSwipeTableCell *sender) {
                                                                         [self restoreTrack];
                                                                         return YES;
                                                                     }];
            [swipeButtonRemove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [swipeButtonRemove.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
            swipeButtonRemove.buttonWidth = 90.0;
            [swipeButtonRemove centerIconOverText];
            
            UIPanGestureRecognizer *addPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
            [swipeButtonRemove addGestureRecognizer:addPanRecognizer];
            
            self.rightButtons =  @[swipeButtonRemove];
            self.rightSwipeSettings.transition = MGSwipeTransitionBorder;
        }

    }
}

- (void)setIsDefaultTrack:(BOOL)isDefaultTrack
{
    _isDefaultTrack = isDefaultTrack;
    
}

- (void)setIsMyMusic:(BOOL)isMyMusic
{
    _isMyMusic = isMyMusic;
    
    if (_isMyMusic) {
        if (!self.rightButtons.count) {

            NSString* removeName = NSLocalizedString(@"Remove",nil);
            UIImage* removeImage = deleteSmall;
            if (self.isFromLovedTracks) {
                removeName = NSLocalizedString(@"Unlove",nil);
                removeImage = unlove;
            }
            MGSwipeButton *swipeButtonRemove = [MGSwipeButton buttonWithTitle:removeName
                                                                         icon:removeImage
                                                              backgroundColor:[UIColor colorWithRGBHex:0xFB0035]
                                                                      padding:3
                                                                     callback:^BOOL(MGSwipeTableCell *sender) {
                                                                         [self removeTrackFromPlaylist];
                                                                         return YES;
                                                                     }];

            [swipeButtonRemove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [swipeButtonRemove.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
            swipeButtonRemove.buttonWidth = 90.0;
            [swipeButtonRemove centerIconOverText];

            self.rightButtons =  @[swipeButtonRemove];
            self.rightSwipeSettings.transition = MGSwipeTransitionBorder;
        }
    }
    if (!self.leftButtons.count) {

//        UIImage* icon;
//        if (self.track.isLiked) {
//            icon = loveSelected;
//        } else {
//            icon = love;
//        }
//        
//        self.swipeButtonLove = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Love",nil)
//                                                                     icon:icon
//                                                          backgroundColor:[UIColor colorWithRGBHex:0xFF1A57]
//                                                                  padding:0.0f
//                                                                 callback:^BOOL(MGSwipeTableCell *sender) {
//                                                                     [self didTouchUpLikesButton:nil];
//                                                                     return YES;
//                                                                 }];
//
//        [_swipeButtonLove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_swipeButtonLove.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
//        _swipeButtonLove.buttonWidth = 65.0;
//        [_swipeButtonLove centerIconOverText];

        MGSwipeButton *swipeButtonRepost = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Repost",nil)
                                                                     icon:repostSmall
                                                          backgroundColor:[UIColor colorWithRGBHex:0x3284FF]
                                                                  padding:0.0f
                                                                 callback:^BOOL(MGSwipeTableCell *sender) {
                                                                     [self repostTrack];
                                                                     return YES;
                                                                 }];


        [swipeButtonRepost setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [swipeButtonRepost.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
        swipeButtonRepost.buttonWidth = 65.0;
        [swipeButtonRepost centerIconOverText];

        MGSwipeButton *swipeButtonAdd = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Playlist",nil)
                                                                  icon:playlistSmall
                                                       backgroundColor:[UIColor colorWithRGBHex:0x8B8A90]
                                                               padding:0.0f
                                                              callback:^BOOL(MGSwipeTableCell *sender) {
                                                                  [self addTrackToPlaylist];
                                                                  return YES;
                                                              }];


        [swipeButtonAdd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [swipeButtonAdd.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
        swipeButtonAdd.buttonWidth = 65.0;
        [swipeButtonAdd centerIconOverText];

        MGSwipeButton *swipeButtonShare = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Share",nil)
                                                                    icon:shareSmall
                                                         backgroundColor:[UIColor colorWithRGBHex:0xA3A3A6]
                                                                 padding:0.0f
                                                                callback:^BOOL(MGSwipeTableCell *sender) {
                                                                    [self didTouchUpShowTrackInfoButton:nil];
                                                                    return YES;
                                                                }];


        [swipeButtonShare setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [swipeButtonShare.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
        swipeButtonShare.buttonWidth = 65.0;
        [swipeButtonShare centerIconOverText];

        self.leftButtons =  @[swipeButtonRepost, swipeButtonAdd, swipeButtonShare];
        self.leftSwipeSettings.transition = MGSwipeTransitionBorder;

    }

}

- (void)repostTrack
{
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }
    if (self.playlistTrackCellDelegate && [self.playlistTrackCellDelegate respondsToSelector:@selector(didRepostTrack:)]) {
        [self.playlistTrackCellDelegate didRepostTrack:self.track];
    }
}

- (void)addTrackToPlaylist
{
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }
    if (self.playlistTrackCellDelegate && [self.playlistTrackCellDelegate respondsToSelector:@selector(didAddTrackToPlaylist:)]) {
        [self.playlistTrackCellDelegate didAddTrackToPlaylist:self.track];
    }
}

- (void)removeTrackFromPlaylist
{
    if (self.playlistTrackCellDelegate && [self.playlistTrackCellDelegate respondsToSelector:@selector(didRemoveTrackFromPlaylist:)]) {
        [self.playlistTrackCellDelegate didRemoveTrackFromPlaylist:self.track];
    }
}

- (void)restoreTrack
{
    if (self.playlistTrackCellDelegate && [self.playlistTrackCellDelegate respondsToSelector:@selector(didRestoreTrack:)]) {
        [self.playlistTrackCellDelegate didRestoreTrack:self.track];
    }
}

#pragma mark - Button Touches

- (IBAction)didTouchUpCommentsButton:(id)sender
{
    if (self.playlistTrackCellDelegate && [self.playlistTrackCellDelegate respondsToSelector:@selector(shouldShowComments:)]) {
        [self.playlistTrackCellDelegate shouldShowComments:self.track];
    }
}

- (IBAction)didTouchUpLikesButton:(id)sender
{
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (!(networkStatus == NotReachable)) {
        
        if (!self.track.isLiked) {

            [self.track likeTrackItem];
            [self showLike];
            if (self.playlistTrackCellDelegate && [self.playlistTrackCellDelegate respondsToSelector:@selector(didLikeTrack:)]) {
                [self.playlistTrackCellDelegate didLikeTrack:self.track];
            }
        } else {

            [self.track dislikeTrackItem];
            [self showUnlike];
            if (self.playlistTrackCellDelegate && [self.playlistTrackCellDelegate respondsToSelector:@selector(didUnlikeTrack:)]) {
                [self.playlistTrackCellDelegate didUnlikeTrack:self.track];
            }
        }
    }
}

- (void)showLike{
    [self.swipeButtonLove setImage:loveSelected forState:UIControlStateNormal];
}

- (void)showUnlike{
    [self.swipeButtonLove setImage:love forState:UIControlStateNormal];
}

- (IBAction)showButtonsMenu:(id)sender {
    [self showSwipe:MGSwipeDirectionLeftToRight animated:YES];
}

- (IBAction)didTouchUpShowTrackInfoButton:(id)sender
{
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }
    if (self.playlistTrackCellDelegate && [self.playlistTrackCellDelegate respondsToSelector:@selector(shouldShowTrackInfo:)]) {
        [self.playlistTrackCellDelegate shouldShowTrackInfo:self.track];
    }
}

-(void) trackLiked:(NSNotification*) notification{
    NSString* trackId = [notification.userInfo valueForKey:@"trackID"];
    if ([trackId isEqualToString:_track.itemId]){
        if (!_track.isLiked){
            [_track likeTrackItem];
        }
        [self setTrack:_track];
    }
}

-(void) trackDisliked:(NSNotification*) notification{
    NSString* trackId = [notification.userInfo valueForKey:@"trackID"];
    if ([trackId isEqualToString:_track.itemId]){
        if (_track.isLiked){
            [_track dislikeTrackItem];
        }
        [self setTrack:_track];
    }
}

- (void)didTouchThumb:(MFTrackItem *)track{
    if (self.playlistTrackCellDelegate && [self.playlistTrackCellDelegate respondsToSelector:@selector(didTouchThumb:)]) {
        [self.playlistTrackCellDelegate didTouchThumb:self.track];
    }
    if (self.playlistTrackCellDelegate && [self.playlistTrackCellDelegate respondsToSelector:@selector(playlistTrackCell:didTouchThumb:)]) {
        [self.playlistTrackCellDelegate playlistTrackCell:self didTouchThumb:self.track];
    }
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

- (void)trackStateChanged:(NDMusicConrolStateType)state {
    switch (state) {
        case NDMusicConrolStateTypeNotStarted:
            self.playingIndicator.hidden = YES;
            self.activityIndicator.hidden = YES;
            self.smallPlayButton.hidden = NO;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypeLoading:
            self.playingIndicator.hidden = YES;
            self.activityIndicator.hidden = NO;
            self.smallPlayButton.hidden = YES;
            [self.activityIndicator startAnimating];
            break;
        case NDMusicConrolStateTypeFailed:
            self.playingIndicator.hidden = YES;
            self.activityIndicator.hidden = YES;
            self.smallPlayButton.hidden = NO;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypePaused:
            self.playingIndicator.hidden = NO;
            [self.playingIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            self.smallPlayButton.hidden = YES;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypePlaying:
            self.playingIndicator.hidden = NO;
            [self.playingIndicator startAnimating];
            self.activityIndicator.hidden = YES;
            self.smallPlayButton.hidden = YES;
            [self.activityIndicator stopAnimating];
            
            break;
        default:
            break;
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    [self removeObserver:self
              forKeyPath:kTrackStateKeyPath
                 context:nil];
    [self.playingIndicator stopAnimating];
}
@end
