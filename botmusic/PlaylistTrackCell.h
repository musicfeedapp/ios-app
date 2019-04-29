//
//  PlaylistTrackCell.h
//  botmusic
//
//  Created by Panda Systems on 1/26/15.
//
//

#import <UIKit/UIKit.h>

#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "MFPlayerAnimationView.h"

@class MFTrackItem;
@class PlaylistTrackCell;

@protocol PlaylistTrackCellDelegate <NSObject>
@optional
- (void)didLikeTrack:(MFTrackItem *)track;
- (void)didUnlikeTrack:(MFTrackItem *)track;
- (void)didRemoveTrackFromPlaylist:(MFTrackItem *)track;
- (void)didAddTrackToPlaylist:(MFTrackItem *)track;
- (void)didRestoreTrack:(MFTrackItem *)track;
- (void)didRepostTrack:(MFTrackItem *)track;
- (void)shouldShowTrackInfo:(MFTrackItem *)track;
- (void)shouldShowComments:(MFTrackItem *)track;
- (void)didTouchThumb:(MFTrackItem *)track;
- (void)playlistTrackCell:(PlaylistTrackCell*)cell didTouchThumb:(MFTrackItem *)track;

@end

@interface PlaylistTrackCell : MGSwipeTableCell

@property (nonatomic, weak) id<PlaylistTrackCellDelegate> playlistTrackCellDelegate;
@property (nonatomic, weak) IBOutlet UIView *separatorView;
@property (nonatomic, weak) IBOutlet UIImageView *trackImageView;
@property (nonatomic, weak) IBOutlet UILabel *trackNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UIView *actionsView;
@property (nonatomic, weak) IBOutlet UIButton *commentsButton;
@property (nonatomic, weak) IBOutlet UILabel *commentsLabel;
@property (nonatomic, weak) IBOutlet UIButton *likesButton;
@property (nonatomic, weak) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraints;
@property (weak, nonatomic) IBOutlet UIView *undoRemoveView;
@property (strong, nonatomic) UIView* additionalBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *showMoreButton;
@property (nonatomic, assign) BOOL isRemovedTrack;
@property (nonatomic, assign) BOOL isDefaultTrack;
@property (nonatomic, assign) BOOL isMyMusic;
@property (nonatomic) BOOL hideDefaultArtwork;
@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic) BOOL isDarkBackGround;
@property (nonatomic, strong) MFTrackItem *track;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidth;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) MGSwipeButton* swipeButtonLove;
- (IBAction)didTouchUpCommentsButton:(id)sender;
- (IBAction)didTouchUpLikesButton:(id)sender;
- (IBAction)didTouchUpShowTrackInfoButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *playingIndicatorContainer;
@property (weak, nonatomic) IBOutlet UIView *thumbTapView;
@property (strong, nonatomic) MFPlayerAnimationView* playingIndicator;
@property (nonatomic) BOOL isFromLovedTracks;

- (void) checkIsPostedState;
@end
