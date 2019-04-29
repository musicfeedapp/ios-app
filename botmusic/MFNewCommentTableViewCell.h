//
//  MFNewCommentTableViewCell.h
//  botmusic
//
//  Created by Panda Systems on 11/10/15.
//
//

#import <UIKit/UIKit.h>
@class MFNewCommentTableViewCell;

@protocol MFNewCommentTableViewCellDelegate <NSObject>

-(void) didTappedAvatarAtCell:(MFNewCommentTableViewCell*)cell;
- (void) didSelectDeleteComment:(MFNewCommentTableViewCell*)cell;
- (void) didSelectEditComment:(MFNewCommentTableViewCell*)cell;

@end

@interface MFNewCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *commentField;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatatarImageView;
@property (weak, nonatomic) IBOutlet UIView *tappableView;
@property (weak, nonatomic) id<MFNewCommentTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *darkView;
@property (weak, nonatomic) IBOutlet UIView *underlyingDarkView;
@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (nonatomic) BOOL isMyComment;
@end
