//
//  MFSuggestionTableViewCell.h
//  botmusic
//
//  Created by Vladimir on 27.11.15.
//
//

#import <UIKit/UIKit.h>
#import "MFSuggestion+Behavior.h"

@class MFSuggestionTableViewCell;

@protocol MFSuggestionTableViewCellDelegate <NSObject>

- (void)suggestionTableViewCellDidSelectCommonFollowers:(MFSuggestionTableViewCell*)cell;
- (void)suggestionTableViewCellDidSelectFollow:(MFSuggestionTableViewCell*)cell;


@end

@interface MFSuggestionTableViewCell : UITableViewCell<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *tracksCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *tracksCollectionViewFlowLayout;
@property (nonatomic, strong) MFSuggestion* suggestion;
@property (weak, nonatomic) IBOutlet UIView *grayView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *separator2View;
@property (weak, nonatomic) IBOutlet UILabel *commonFollowersLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherCommonFollowersLabel;
@property (weak, nonatomic) IBOutlet UIView *commonFollowersTappableView;
@property id<MFSuggestionTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *verifiedMark;
@property (weak, nonatomic) IBOutlet UIView *verifiedBarkground;
@end
