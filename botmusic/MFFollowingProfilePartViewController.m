//
//  MFFollowingProfilePartViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/13/16.
//
//

#import "MFFollowingProfilePartViewController.h"
#import "MFProfileFollowCollectionViewCell.h"

static UIImage* defaultAvatar;

@interface MFFollowingProfilePartViewController () <MFProfileFollowCellDelegate>

@end

@implementation MFFollowingProfilePartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MFProfileFollowCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MFProfileFollowCollectionViewCell"];
    if (self.userInfo.isMyUserInfo) {
        NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateUserFollowing];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didUpdateFollowing:)
                                                     name:notificationName
                                                   object:nil];
    }
    if (!defaultAvatar) {
        defaultAvatar = [UIImage imageNamed:@"defaultAvatar.jpg"];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setObjectsFromCache{
    self.objects = [[self.userInfo.followingArtists array] arrayByAddingObjectsFromArray:[self.userInfo.followingFriends array]];
    if (self.objects.count>0) {
        self.countLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.objects.count];
    }
}

- (void)downloadObjects{
    [[IRNetworkClient sharedInstance] userFollowingWithUsername:self.userInfo.extId successBlock:^(NSDictionary *dictionary) {
        NSArray* artists = [dataManager convertAndAddFollowItemsToDatabase:dictionary[@"followings"][@"artists"]];
        NSArray* friends = [dataManager convertAndAddFollowItemsToDatabase:dictionary[@"followings"][@"friends"]];

        self.userInfo.followingArtists = [NSOrderedSet orderedSetWithArray:artists];
        self.userInfo.followingFriends = [NSOrderedSet orderedSetWithArray:friends];

        self.objects = [artists arrayByAddingObjectsFromArray:friends];
        self.countLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.objects.count];
        self.isLoadedObjects = YES;
        [self.delegate profilePartViewControllerLoadedObjects:self];
        
        [self.collectionView reloadData];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:((UIViewController*)self.delegate).tabBarController];

    }];
}

- (CGSize)itemSize{
    return (CGSize){80,150};
}

- (UICollectionViewCell*)cellForItemAtIndexPath:(NSIndexPath*)indexPath{
    MFProfileFollowCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MFProfileFollowCollectionViewCell" forIndexPath:indexPath];
    MFFollowItem* followItem = self.objects[indexPath.row];
    cell.followItem = followItem;
    cell.avatarImageView.alpha = 0.0;
    [cell.avatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:followItem.picture] name:followItem.name cropRoundedImage:NO];
    //[cell.avatarImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:followItem.picture] placeholderImage:defaultAvatar];
    cell.nameLabel.text = followItem.name;
    cell.followButton.hidden = !self.userInfo.isMyUserInfo || followItem.isFollowed;
    cell.delegate = self;
    return cell;
}

- (void) profileFollowCellDidSelectFollow:(MFProfileFollowCollectionViewCell *)cell{
    MFFollowItem *followItem = cell.followItem;
    followItem.isFollowed = !followItem.isFollowed;

    cell.followButton.hidden = !self.userInfo.isMyUserInfo || followItem.isFollowed;
    NSDictionary *proposalsDictionary = @{@"ext_id" : followItem.extId,
                                          @"followed" : followItem.isFollowed ? @"true" : @"false"};

    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:followItem.extId];
    userInfo.username = followItem.username;
    userInfo.profileImage = [followItem.picture stringByReplacingOccurrencesOfString:@" " withString:@""];
    userInfo.facebookID = followItem.facebookID;
    userInfo.extId = followItem.extId;

    [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                      token:[userManager fbToken]
                                                  proposals:@[proposalsDictionary]
                                               successBlock:^{
                                                   [MFNotificationManager postUpdateUserFollowingNotification:userInfo];
                                               }
                                               failureBlock:^(NSString *errorMessage){
                                                   [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:((UIViewController*)self.delegate).tabBarController];

                                                   followItem.isFollowed = !followItem.isFollowed;
                                                   if (cell.followItem == followItem) {
                                                       cell.followButton.hidden = !self.userInfo.isMyUserInfo || followItem.isFollowed;
                                                   }
                                               }];

}

- (void)didUpdateFollowing:(NSNotification *)notification
{
    [self reloadData];
}
@end
