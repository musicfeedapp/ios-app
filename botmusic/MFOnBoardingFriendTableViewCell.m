//
//  MFOnBoardingFriendTableViewCell.m
//  botmusic
//
//  Created by Panda Systems on 8/27/15.
//
//

#import "MFOnBoardingFriendTableViewCell.h"
#import "UIImageView+WebCache_FadeIn.h"

@implementation MFOnBoardingFriendTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.separatorHeight.constant = 1.0/[UIScreen mainScreen].scale;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.height/2.0;
    [self.unfollowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unfollowViewTapped) ]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) setUserInfo:(MFUserInfo*) userInfo{
    
    self.contact = userInfo;
    [self.avatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:userInfo.profileImage] name:userInfo.name cropRoundedImage:YES];


    [self.nameLabel setText:userInfo.name];
    [self.followedMark setHidden:!userInfo.isFollowed];
    [self.unfollowView setHidden:!userInfo.isFollowed];
    [self.followButton setHidden:userInfo.isFollowed];
}

- (void) unfollowViewTapped{
    [self.delegate cellDidChangeFollowedState:self];
}

- (IBAction)followButtonTapped:(id)sender {
    [self.delegate cellDidChangeFollowedState:self];
}

@end
