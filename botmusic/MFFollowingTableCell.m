//
//  MFFollowingTableCell.m
//  botmusic
//
//  Created by Panda Systems on 2/9/15.
//
//

#import "MFFollowingTableCell.h"
#import "MGSwipeButton.h"
#import <UIColor+Expanded.h>
#import "UIImageView+WebCache_FadeIn.h"
static UIImage* defaultArtwork;

@implementation MFFollowingTableCell

- (void)awakeFromNib {
    // Initialization code
    if (!defaultArtwork) {
        defaultArtwork = [UIImage imageNamed:@"defaultAvatar.jpg"];
    }
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.clipsToBounds = NO;

    //    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path addArcWithCenter:CGPointMake(self.userImageView.bounds.size.width / 2.0, self.userImageView.bounds.size.height / 2.0) radius:self.userImageView.bounds.size.width * 0.50 startAngle:0 endAngle:M_PI * 2.0 clockwise:YES];
//
//    //Create a new layer to use as a mask
//
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//
//    // Set the path of the layer
//
//    maskLayer.path = path.CGPath;
//    self.userImageView.layer.mask = maskLayer;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    UIColor* color = self.followButton.backgroundColor;
    [super setSelected:selected animated:animated];
    self.followButton.backgroundColor = color;

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {

    UIColor* color = self.followButton.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.followButton.backgroundColor = color;

    // Configure the view for the selected state
}

#pragma mark - Setup methods

- (void)setFollowingInfo:(MFFollowItem*)followItem
{
    self.followItem = followItem;
    self.suggestion = nil;
    if (followItem) {
        self.usernameLabel.text = followItem.name;
        self.tracksLabel.text = [NSString stringWithFormat:@"%ld", (long)followItem.timelineCount];
        //NSURL *avatarUrl = [NSURL URLWithString:[followItem.picture stringByReplacingOccurrencesOfString:@"large" withString:@"normal"]];
        NSURL *avatarUrl = [NSURL URLWithString:followItem.picture];
        [_userImageView sd_setAvatarWithUrl:avatarUrl name:followItem.name cropRoundedImage:YES];
//        if ( _userImageView.image){
//            _userImageView.image = [self makeRoundedImage:_userImageView.image radius:_userImageView.image.size.width/2.0];
//        }
    }
    self.tracksCountLabel.text = [NSString stringWithFormat:@"%li", (long)followItem.timelineCount];
    self.verifiedUserLabel.hidden = !followItem.isVerified;
    [self updateFollowingState];
}

- (void)setSearchResult:(IRSuggestion*)suggestion{
    self.followItem = nil;
    self.suggestion = suggestion;
    self.usernameLabel.text = suggestion.name;
    NSURL *avatarUrl = [NSURL URLWithString:[suggestion.avatar_url stringByReplacingOccurrencesOfString:@" " withString:@""]];
    self.verifiedUserLabel.hidden = !suggestion.is_verified;
    [_userImageView sd_setAvatarWithUrl:avatarUrl name:suggestion.name];

    [self updateFollowingState];

}

- (void)setSwipeButtons:(MFFollowItem *)followItem
{
    MGSwipeButton *swipeButtonRemove = [MGSwipeButton buttonWithTitle:(followItem.isFollowed ? NSLocalizedString(@"unfollow",nil) : NSLocalizedString(@"follow",nil))
                                                      backgroundColor:[UIColor colorWithRGBHex:kOffWhiteColor]
//                                                              padding:20
                                                             callback:^BOOL(MGSwipeTableCell *sender) {
                                                                 [self followUser];
                                                                 return YES;
                                                             }];
    [swipeButtonRemove setTitleColor:[UIColor colorWithRGBHex:kBrandPinkColor] forState:UIControlStateNormal];
    [swipeButtonRemove.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    
    UIPanGestureRecognizer *removePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [swipeButtonRemove addGestureRecognizer:removePanRecognizer];
    
    self.rightButtons =  @[swipeButtonRemove];
    self.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    MGSwipeExpansionSettings* sws = [[MGSwipeExpansionSettings alloc] init];
    sws.buttonIndex = 0;
    sws.fillOnTrigger = YES;
    sws.threshold = 1.5;
    self.rightExpansion = sws;
}

#pragma mark - Helpers
- (IBAction)followButtonTapped:(id)sender {
    if (self.followItem){
        if (!self.followItem.isFollowed){
            [self followUser];
        }
    } else if (self.suggestion) {
        if (!self.suggestion.is_followed){
            [self followUser];
        }
    }
}

- (void)updateFollowingState{
    self.tracksCountView.hidden = YES;
    self.followButton.hidden = YES;
    self.checkmarkLabel.hidden = YES;
    if (self.followItem){
        if (self.isMyFollowItem) {
            if (self.followItem.isFollowed) {
                self.checkmarkLabel.hidden = NO;
            } else {
                self.followButton.hidden = NO;
            }
        } else {
            self.tracksCountView.hidden = NO;
        }
    } else if (self.suggestion){
        if (![self.suggestion.ext_id isEqualToString:userManager.userInfo.extId]) {
            if (self.suggestion.is_followed) {
                self.checkmarkLabel.hidden = NO;
            } else {
                self.followButton.hidden = NO;
            }
        } else {
            self.followButton.hidden = YES;
            self.checkmarkLabel.hidden = YES;
        }
    }
}

- (void)followUser
{
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (!(networkStatus == NotReachable)) {
        if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(didSelectFollow:)]) {
            [_cellDelegate didSelectFollow:self];
            [self updateFollowingState];
        }
    }
}

@end
