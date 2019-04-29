//
//  TrackResultsTableCell.h
//  botmusic
//
//  Created by Panda Systems on 2/3/15.
//
//

#import <UIKit/UIKit.h>
@protocol TrackResultsCellDelegate <NSObject>

- (void)didLikeTrack:(MFTrackItem *)track;
- (void)didUnlikeTrack:(MFTrackItem *)track;
- (void)didAddTrackToPlaylist:(MFTrackItem *)track;
- (void)repostTrack:(MFTrackItem *)track;
- (void)shouldShowTrackInfo:(MFTrackItem *)track;
- (void)shouldShowComments:(MFTrackItem *)track;

@end

@class MFTrackItem;

@interface TrackResultsTableCell : UITableViewCell

@property (nonatomic, weak) id<TrackResultsCellDelegate> trackResultsCellDelegate;
@property (nonatomic, weak) IBOutlet UIImageView *trackImageView;
@property (nonatomic, weak) IBOutlet UILabel *trackNameLabel;

@property (nonatomic, weak) IBOutlet UIButton *commentsButton;
@property (nonatomic, weak) IBOutlet UILabel *commentsLabel;
@property (nonatomic, weak) IBOutlet UIButton *likesButton;
@property (nonatomic, weak) IBOutlet UILabel *likesLabel;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@property (nonatomic, strong) MFTrackItem *track;

- (IBAction)didTouchUpCommentsButton:(id)sender;
- (IBAction)didTouchUpLikesButton:(id)sender;
- (IBAction)didTouchUpShowTrackInfoButton:(id)sender;
- (IBAction)didTouchUpAddButton:(id)sender;

- (void)setInfo:(MFTrackItem *)trackItem;

@end
