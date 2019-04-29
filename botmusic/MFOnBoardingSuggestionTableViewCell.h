//
//  MFOnBoardingSuggestionTableViewCell.h
//  botmusic
//
//  Created by Panda Systems on 8/26/15.
//
//

#import <UIKit/UIKit.h>
#import "MFSuggestion+Behavior.h"
@class MFOnBoardingSuggestionTableViewCell;
@protocol MFOnBoardingSuggestionTableViewCellDelegate <NSObject>

- (void) shouldOpenProfile:(MFOnBoardingSuggestionTableViewCell*)cell;
- (void) shouldFollow:(MFOnBoardingSuggestionTableViewCell*)cell;
- (void) shouldUnFollow:(MFOnBoardingSuggestionTableViewCell*)cell;

@end

@interface MFOnBoardingSuggestionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *unfollowView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *checkMark;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followedMark;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeight;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (strong, nonatomic) MFSuggestion* suggestion;
- (void)setSuggestionInfo:(MFSuggestion*)suggestion;
- (void) setSearchResultInfo:(IRSuggestion*)suggestion;
@property (weak, nonatomic) IBOutlet UILabel *commonFollowersLabel;
@property (weak, nonatomic) id<MFOnBoardingSuggestionTableViewCellDelegate> delegate;
@end
