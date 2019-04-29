//
//  MFFollowingTableCell.h
//  botmusic
//
//  Created by Panda Systems on 2/9/15.
//
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
@class MFFollowingTableCell;
@protocol MFFollowingTableCellDelegate <NSObject>

- (void)didSelectFollow:(MFFollowingTableCell *)cell;

@end

@interface MFFollowingTableCell : MGSwipeTableCell

@property (nonatomic, weak) id<MFFollowingTableCellDelegate> cellDelegate;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *tracksLabel;
@property (weak, nonatomic) IBOutlet UILabel *verifiedUserLabel;
@property (strong, nonatomic) MFFollowItem *followItem;
@property (strong, nonatomic) IRSuggestion* suggestion;
@property (weak, nonatomic) IBOutlet UILabel *checkmarkLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (nonatomic) BOOL isMyFollowItem;
@property (weak, nonatomic) IBOutlet UIView *tracksCountView;
@property (weak, nonatomic) IBOutlet UILabel *tracksCountLabel;

- (void)setFollowingInfo:(MFFollowItem*)followItem;
- (void)setSwipeButtons:(MFFollowItem *)followItem;
- (void)setSearchResult:(IRSuggestion*)suggestion;

@end
