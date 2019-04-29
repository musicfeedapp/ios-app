//
//  TrackView.h
//  botmusic
//
//  Created by Supervisor on 06.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FXBlurView.h"
#import "MFTrackItem+Behavior.h"
#import "ActionView.h"
#import "ActionViewCreator.h"
#import "NSDate+TimesAgo.h"
#import "SSSliderView.h"
#import <SDWebImage/UIImageView+WebCache.h>

static CGFloat const COMMENTS_TRACK_VIEW_HEIGHT=180.0f;
static CGFloat const COMMENTS_TRACK_VIEW_FOOTER_HEIGHT=40.0f;

@interface CommentsTrackView : UIView<UIGestureRecognizerDelegate, ActionViewDelegate>

@property (nonatomic,weak)IBOutlet FXBlurView *blurView;
@property(nonatomic,weak)IBOutlet UIView *upperView;
@property(nonatomic,weak)IBOutlet UIView *infoView;
@property(nonatomic,weak)IBOutlet UIView *separatorView;
@property(nonatomic,weak)IBOutlet UIImageView *trackImage;

@property(nonatomic,weak)IBOutlet UILabel *trackNameLabel;
@property(nonatomic,weak)IBOutlet UIImageView *autorImageView;
@property(nonatomic,weak) IBOutlet UIButton *videoButton;
@property(nonatomic,weak) IBOutlet UIButton *restoreButton;

@property(nonatomic,weak)IBOutlet UIActivityIndicatorView *activityView;

@property(nonatomic,strong)ActionView *actionView;

@property(nonatomic,weak)IBOutlet UIButton *deleteButton;
@property(nonatomic,strong)IBOutlet UIView *playerView;


@property(nonatomic,weak)IBOutlet UILabel *usernameLabel;

@property(nonatomic,strong)NSIndexPath *indexPath;
@property(nonatomic,copy)NSString *trackLink;

@property(nonatomic)BOOL isLiked;
@property(nonatomic)BOOL isPlayVideo;

@property(nonatomic)BOOL tapEnable;
@property(nonatomic)BOOL longTapEnable;

@property(nonatomic)BOOL isCommentsOpen;
@property(nonatomic)BOOL isFooterOpen;
@property(nonatomic) BOOL showGradient;
@property(nonatomic) BOOL isCommentsView;

@property(nonatomic,weak)id<TrackViewDelegate> delegate;

+(CommentsTrackView*)createTrackView;

- (IBAction)didSelectShare:(id)sender;
- (IBAction)didSelectLike:(id)sender;
- (IBAction)didSelectComment:(id)sender;
- (IBAction)didSelectDelete:(id)sender;
- (IBAction)didSelectPlayVideo:(id)sender;

- (IBAction)didTouchUpRestoreButton:(id)sender;

- (void)setTrackInfo:(MFTrackItem*)trackItem;
- (void)setIsLiked:(BOOL)isLiked;

- (void)openFooterViewAnimated:(BOOL)animated;
- (void)closeFooterView;

- (void)setTrackViewHeight:(CGFloat)height;

@end
