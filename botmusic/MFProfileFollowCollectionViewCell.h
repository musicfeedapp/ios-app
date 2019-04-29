//
//  MFProfileFollowCollectionViewCell.h
//  botmusic
//
//  Created by Panda Systems on 1/13/16.
//
//

#import <UIKit/UIKit.h>
@class MFProfileFollowCollectionViewCell;
@protocol MFProfileFollowCellDelegate <NSObject>

-(void)profileFollowCellDidSelectFollow:(MFProfileFollowCollectionViewCell*)cell;

@end

@interface MFProfileFollowCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property id<MFProfileFollowCellDelegate> delegate;
@property MFFollowItem* followItem;
@end
