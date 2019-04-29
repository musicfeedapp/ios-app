//
//  TrackView.h
//  botmusic
//
//  Created by Supervisor on 06.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MFTrackItem+Behavior.h"
#import "ActionView.h"
#import "ActionViewCreator.h"
#import "NSDate+TimesAgo.h"
#import "SSSliderView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@protocol TrackViewDelegate <NSObject>
@optional

- (void)didTapOnView:(MFTrackItem *)trackItem;
//- (void)didLongTapOnView:(NSIndexPath*)indexPath;
- (void)didLike:(MFTrackItem *)trackItem;
- (void)didUnlike:(MFTrackItem *)trackItem;

- (void)didSelectComment:(MFTrackItem *)trackItem;
//- (void)didDeselectComent:(NSIndexPath*)indexPath;
- (void)didRepostTrack:(MFTrackItem *)track;
//- (void)didOpenDelete:(NSIndexPath*)indexPath;
- (void)didDelete:(MFTrackItem *)feedItem;
- (void)didShare:(MFTrackItem *)trackItem;
- (void)didAddToPlaylist:(MFTrackItem *)trackItem;
//- (void)didPlayVideo:(NSIndexPath*)indexPath;
- (void)didSelectShowFriend:(MFTrackItem *)trackItem;
- (void)didRestoreDeleted:(NSIndexPath*)indexPath;

- (void)shouldOpenTrackInfo:(MFTrackItem *)trackItem;
@end

static CGFloat const TRACK_VIEW_HEIGHT = 331.0f;
static CGFloat const TRACK_VIEW_FOOTER_HEIGHT = 88.0f;

@interface TrackView : UIView <UIGestureRecognizerDelegate, ActionViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;

@property (nonatomic, weak) IBOutlet UIView *upperView;
@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UIView *playingView;
@property (nonatomic, weak) IBOutlet UIView *animationView;
@property (nonatomic, weak) IBOutlet UIView *separatorView;
@property (nonatomic, weak) IBOutlet UIImageView *trackImage;

@property (nonatomic, weak) IBOutlet UILabel *trackNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UILabel *verifiedLabel;
@property (nonatomic, weak) IBOutlet UILabel *verifiedBackLabel;
@property (nonatomic, weak) IBOutlet UIImageView *autorImageView;
@property (nonatomic, weak) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UIView *gradientContainer;
@property (weak, nonatomic) IBOutlet UIView *playTapView;

@property (nonatomic, weak) IBOutlet UIView *userInfoView;
@property (nonatomic, weak) IBOutlet UIView *trackNameView;

@property (nonatomic, strong) ActionView *actionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UILabel *likesLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentsLabel;
@property (nonatomic, weak) IBOutlet UILabel *feedTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastActivityLabel;
@property (nonatomic, strong) MFTrackItem *trackItem;

@property (nonatomic, weak) MGSwipeTableCell* correspondingCell;

@property (nonatomic, strong) NSIndexPath *indexPath;
//@property (nonatomic, copy) NSString *trackLink;

@property (nonatomic) BOOL isLiked;
@property (nonatomic) BOOL isPlayVideo;

@property (nonatomic) BOOL tapEnable;
@property (nonatomic) BOOL longTapEnable;

@property (nonatomic) BOOL isCommentsOpen;

@property (nonatomic, weak) id<TrackViewDelegate> delegate;

+ (TrackView*)createTrackView;

- (IBAction)didSelectShare:(id)sender;
- (IBAction)didSelectLike:(id)sender;
- (IBAction)didSelectComment:(id)sender;
- (IBAction)didSelectPlayVideo:(id)sender;
- (IBAction)didSelectShowTrackInfo:(id)sender;

- (IBAction)didTouchUpRestoreButton:(id)sender;

- (void)setTrackInfo:(MFTrackItem*)trackItem;
- (void)setIsLiked:(BOOL)isLiked;
- (void)configureButtons;
+ (CGFloat) trackViewHeight;
+ (CGFloat) trackViewWidth;

@end
