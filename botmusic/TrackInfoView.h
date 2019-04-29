//
//  TrackInfoView.h
//  botmusic
//
//  Created by Panda Systems on 1/26/15.
//
//

#import <UIKit/UIKit.h>

@class MFTrackItem;

@protocol TrackInfoViewDelegate <NSObject>

- (void)didLikeTrack:(MFTrackItem *)track;
- (void)didUnlikeTrack:(MFTrackItem *)track;
- (void)didAddTrackToPlaylist:(MFTrackItem *)track;
- (void)didSelectShare:(MFTrackItem *)track;
- (void)didSelectDownload:(MFTrackItem *)track;
- (void)shouldShowComments:(MFTrackItem *)track;
- (void)shouldOpenAuthorProfile:(MFTrackItem *)track;

@end

@interface TrackInfoView : UIView

@property (nonatomic, weak) id<TrackInfoViewDelegate> trackInfoViewDelegate;
@property (nonatomic, weak) IBOutlet UIView *upperView;
@property (nonatomic, weak) IBOutlet UILabel *trackNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;

@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UIButton *commentsButton;
@property (nonatomic, weak) IBOutlet UILabel *commentsLabel;
@property (nonatomic, weak) IBOutlet UIButton *likesButton;
@property (nonatomic, weak) IBOutlet UILabel *likesLabel;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *playerShareButton;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *downloadButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trackNameLabelTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trackNameLabelWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trackNameLabelHeightConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *durationLabelLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *durationLabelWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *durationLabelHeightConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *progressLabelWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *progressLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressLabelTrailingConstraint;

@property (nonatomic, assign) BOOL isPlayerInfo;

@property (nonatomic, strong) MFTrackItem *track;

- (IBAction)didTouchUpCommentsButton:(id)sender;
- (IBAction)didTouchUpLikesButton:(id)sender;
- (IBAction)didTouchUpShareButton:(id)sender;
- (IBAction)didTouchUpAddButton:(id)sender;

+ (TrackInfoView *)createTrackInfoView;

- (void)setProgress:(NSString *)progress;
- (void)setDuration:(NSString *)duration;
- (void) reloadLikes;

@end
