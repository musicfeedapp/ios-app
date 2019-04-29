//
//  MFNotificationCell.h
//  botmusic
//
//  Created by Panda Systems on 9/10/15.
//
//

#import <UIKit/UIKit.h>
@class MFNotificationCell;

@protocol MFNotificationCellDelegate <NSObject>

-(void)notificationCellDidTouchThumb:(MFNotificationCell*)cell;

@end

@interface MFNotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UIView *mySeparatorView;
@property (nonatomic, weak) id<MFNotificationCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *readView;
@end
