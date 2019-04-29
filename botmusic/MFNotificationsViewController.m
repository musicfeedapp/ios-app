//
//  MFNotificationsViewController.m
//  botmusic
//
//  Created by Panda Systems on 9/10/15.
//
//

#import "MFNotificationsViewController.h"
#import "MFNotificationCell.h"
#import "UIImageView+WebCache_FadeIn.h"
#import "MFUserNotification.h"
#import "MFAddUserNotification.h"
#import "MFCommentUserNotification.h"
#import "MFFollowUserNotification.h"
#import "MFJoinUserNotification.h"
#import "MFLikeUserNotification.h"
#import "MagicalRecord/MagicalRecord.h"
#import <UIScrollView+SVPullToRefresh.h>
#import <UIScrollView+SVInfiniteScrolling.h>
#import "UIColor+Expanded.h"
#import "MFArtistsAddedUserNotification.h"
#import "MFFriendsOnBoardingViewController.h"

@interface MFNotificationsViewController ()<UITableViewDataSource, UITableViewDelegate, MFNotificationCellDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UITableView *notificationsTableView;
@property (strong, nonatomic) NSArray<MFUserNotification*>* notifications;
@property (nonatomic, strong) UIImage* defaultAvatar;
@end

@implementation MFNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINib *nib = [UINib nibWithNibName:@"MFNotificationCell" bundle:nil];
    [self.notificationsTableView registerNib:nib  forCellReuseIdentifier:@"MFNotificationCell"];
    self.headerImageView.image = self.headerImage;
    [self.notificationsTableView addPullToRefreshWithActionHandler:^
     {
         [self pullTriggered];
     }];
    [self.notificationsTableView addInfiniteScrollingWithActionHandler:^
     {
         [self nextPageTriggered];
     }];

//    self.tableView.pullToRefreshView.arrowColor = [UIColor colorWithRGBHex:kActiveColor];
//    self.tableView.pullToRefreshView.textColor = [UIColor colorWithRGBHex:kActiveColor];
//    self.tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
//    self.tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.defaultAvatar = [UIImage imageNamed:@"defaultAvatar.jpg"];
    [self showNotificationsForPage:1];
    [self downloadNotificationsForPage:1];

}

- (void)pullTriggered{
    [self showNotificationsForPage:1];
    [self downloadNotificationsForPage:1];
}

- (void)nextPageTriggered{
    int nextPage = (int)self.notifications.count/25 + 1;
    [self showNotificationsForPage:nextPage];
    [self downloadNotificationsForPage:nextPage];
}

- (void)showNotificationsForPage:(int)page{

    NSFetchRequest* request = [MFUserNotification MR_requestAllSortedBy:@"createdAt" ascending:NO];
    [request setFetchLimit:page*25];
    NSArray* array = [MFUserNotification MR_executeFetchRequest:request];
    self.notifications = array;
    [self.notificationsTableView reloadData];

}

- (void)downloadNotificationsForPage:(int)page{

    [[IRNetworkClient sharedInstance] getNotificationsWithEmail:userManager.userInfo.email token:userManager.fbToken page:page successBlock:^(NSArray *array) {
        self.notifications = array;

        NSArray* notifs = [[dataManager convertAndAddNotificationItemsToDatabase:array] mutableCopy];

        [self showNotificationsForPage:page];

        [self.notificationsTableView.pullToRefreshView stopAnimating];
        [self.notificationsTableView.infiniteScrollingView stopAnimating];

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSMutableArray* ids = [NSMutableArray array];
        for (MFUserNotification* notif in notifs) {
            if ([notif isNotSeen]) {
                NSNumber* identifier = [formatter numberFromString:notif.identifier];
                [ids addObject:identifier];
            }
        }
        if (ids.count) {
            [[IRNetworkClient sharedInstance] seenNotificationsByID:ids successBlock:^(NSArray *array) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MFRefreshUnreadMessagesNumber" object:nil];
            } failureBlock:^(NSString *errorMessage) {
                [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

            }];
        }

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
        [self.notificationsTableView.pullToRefreshView stopAnimating];
        [self.notificationsTableView.infiniteScrollingView stopAnimating];

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notifications.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"MFNotificationCell";
    
    MFNotificationCell *cell = (MFNotificationCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MFNotificationCell" owner:nil options:nil] lastObject];
    }
    MFUserNotification* notification = self.notifications[indexPath.row];
    cell.timeLabel.text = notification.createdTime;
    if ([notification isKindOfClass:[MFArtistsAddedUserNotification class]] && ((MFArtistsAddedUserNotification*)notification).artists.count) {
        [cell.avatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:((MFUserInfo*)((MFArtistsAddedUserNotification*)notification).artists[0]).profileImage] name:((MFUserInfo*)((MFArtistsAddedUserNotification*)notification).artists[0]).name cropRoundedImage:YES];
    } else {
        [cell.avatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:notification.userPicture] name:notification.userName cropRoundedImage:YES];
    }
    //[cell.avatarImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:notification.userPicture] placeholderImage:_defaultAvatar];
    cell.nameLabel.text = notification.userName;
    cell.delegate = self;
    if (notification.isRead){
        cell.readView.hidden = NO;
    } else {
        cell.readView.hidden = YES;
    }
    if ([notification isKindOfClass:[MFCommentUserNotification class]] ) {
        MFCommentUserNotification* notif = (MFCommentUserNotification*)notification;
        cell.descriptionLabel.text = NSLocalizedString(@"commented your track", nil);
        cell.itemLabel.text = notif.trackTitle;
        cell.activityLabel.text = @"";
        return cell;
    }

    if ([notification isKindOfClass:[MFAddUserNotification class]] ) {
        MFAddUserNotification* notif = (MFAddUserNotification*)notification;
        cell.descriptionLabel.text = NSLocalizedString(@"added your track", nil);
        cell.itemLabel.text = notif.trackTitle;
        cell.activityLabel.text = @"";
        return cell;
    }

    if ([notification isKindOfClass:[MFLikeUserNotification class]] ) {
        MFLikeUserNotification* notif = (MFLikeUserNotification*)notification;
        cell.descriptionLabel.text = NSLocalizedString(@"loved your track", nil);
        cell.itemLabel.text = notif.trackTitle;
        cell.activityLabel.text = @"";
        return cell;
    }

    if ([notification isKindOfClass:[MFFollowUserNotification class]] ) {
        cell.descriptionLabel.text = NSLocalizedString(@"started following you", nil);
        cell.itemLabel.text = @"";
        cell.activityLabel.text = @"";
        return cell;
    }

    if ([notification isKindOfClass:[MFJoinUserNotification class]] ) {
        cell.descriptionLabel.text = NSLocalizedString(@"is now on Musicfeed", nil);
        cell.itemLabel.text = @"";
        cell.activityLabel.text = @"";
        return cell;
    }

    if ([notification isKindOfClass:[MFArtistsAddedUserNotification class]] ) {
        cell.descriptionLabel.text = @"";
        cell.nameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%i artists added to Musicfeed", nil), ((MFArtistsAddedUserNotification*)notification).count];
        cell.itemLabel.text = @"";
        cell.activityLabel.text = @"";
        return cell;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MFUserNotification* notification = self.notifications[indexPath.row];

    if ([notification isKindOfClass:[MFFollowUserNotification class]]) {
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:notification.userExtID];
        userInfo.profileImage = notification.userPicture;
        userInfo.name = notification.userName;
        [self showUserProfileWithUserInfo:userInfo];
    }

    if ([notification isKindOfClass:[MFJoinUserNotification class]]) {
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:notification.userExtID];
        userInfo.profileImage = notification.userPicture;
        userInfo.name = notification.userName;
        [self showUserProfileWithUserInfo:userInfo];
    }

    if ([notification isKindOfClass:[MFAddUserNotification class]] || [notification isKindOfClass:[MFLikeUserNotification class]] || [notification isKindOfClass:[MFCommentUserNotification class]]) {
        MFAddUserNotification* notif = (MFAddUserNotification*)notification;
        MFTrackItem* track = [MFTrackItem MR_findFirstByAttribute:@"itemId" withValue:notif.trackID];
        if (track) {
            [self shouldOpenTrackInfo:track];
        } else {
            [[IRNetworkClient sharedInstance] getTrackByID:notif.trackID successBlock:^(NSDictionary *dictionary) {
                NSArray* tracks = [dataManager convertAndAddTracksToDatabase:@[dictionary]];
                [self shouldOpenTrackInfo:tracks[0]];
            } failureBlock:^(NSString *errorMessage) {
                [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

            }];
        }
    }

    if ([notification isKindOfClass:[MFArtistsAddedUserNotification class]] && ((MFArtistsAddedUserNotification*)notification).artists.count) {
        MFFriendsOnBoardingViewController* vc = [[UIStoryboard storyboardWithName:@"OnBoarding" bundle:nil] instantiateViewControllerWithIdentifier:@"MFFriendsOnBoardingViewController"];

        vc.friends = [((MFArtistsAddedUserNotification*)notification).artists array];
        vc.showListOfGivenArtistsMode = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }

    if (!notification.isRead) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;

        [[IRNetworkClient sharedInstance] readNotificationByID:[f numberFromString:notification.identifier] withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSArray *array) {
            notification.status = @"read";
            if (userManager.numberOfUnreadNotifications>0) {
                userManager.numberOfUnreadNotifications--;
            }
            if ([self.notifications containsObject:notification]) {
                NSIndexPath* ip = [NSIndexPath indexPathForItem:[self.notifications indexOfObject:notification] inSection:0];
                [self.notificationsTableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MFNumberOfUnfeadNotificationsChanged" object:nil];

            }
        } failureBlock:^(NSString *errorMessage) {
            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

        }];
    }

}

- (void) notificationCellDidTouchThumb:(MFNotificationCell *)cell{
    NSIndexPath* indexPath = [self.notificationsTableView indexPathForCell:cell];
    MFUserNotification* notification = self.notifications[indexPath.row];
    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:notification.userExtID];
    userInfo.profileImage = notification.userPicture;
    userInfo.name = notification.userName;
    [self showUserProfileWithUserInfo:userInfo];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)xButtonTapped:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionReveal; //kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromBottom; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)showUserProfileWithUserInfo:(MFUserInfo*)userInfo
{
    [super showUserProfileWithUserInfo:userInfo];
}

- (void)shouldOpenTrackInfo:(MFTrackItem *)trackItem
{
    [super shouldOpenTrackInfo:trackItem];
}

- (void)shouldOpenPlaylist:(MFPlaylistItem *)playlistItem ofUser:(MFUserInfo*)userInfo{
    [super shouldOpenPlaylist:playlistItem ofUser:userInfo];
}

@end
