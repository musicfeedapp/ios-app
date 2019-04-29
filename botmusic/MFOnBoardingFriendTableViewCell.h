//
//  MFOnBoardingFriendTableViewCell.h
//  botmusic
//
//  Created by Panda Systems on 8/27/15.
//
//

#import <UIKit/UIKit.h>
@class MFOnBoardingFriendTableViewCell;

@protocol MFOnBoardingFriendTableViewCellDelegate <NSObject>

- (void) cellDidChangeFollowedState:(MFOnBoardingFriendTableViewCell*)cell;

@end

@interface MFOnBoardingFriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followedMark;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeight;
@property (weak, nonatomic) IBOutlet UIView *unfollowView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) MFUserInfo* contact;
@property (weak, nonatomic) id<MFOnBoardingFriendTableViewCellDelegate> delegate;
//- (void)setContactInfo:(NSDictionary*)contact;
//- (void)setFacebookInfo:(NSDictionary*)contact;
//- (void)setArtistInfo:(NSDictionary*)contact;
- (void) setUserInfo:(MFUserInfo*) userInfo;
@end
