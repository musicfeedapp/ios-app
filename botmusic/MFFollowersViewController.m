//
//  MFFollowersViewController.m
//  botmusic
//
//  Created by Panda Systems on 2/9/15.
//
//

#import "MFFollowersViewController.h"
#import "MFFollowingTableCell.h"
#import "MFNotificationManager.h"
#import "MFNumberOfFollowersTableViewCell.h"

@interface MFFollowersViewController () <MFFollowingTableCellDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@property (nonatomic) BOOL isScrollToBottom;

@end

@implementation MFFollowersViewController{
    CGFloat previousTableViewYOffset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_shouldJustDisplayGivenFollowItems) {
        [self getFollowItemsFromDatabase];
        [self followItemsRequest];
    }
    UINib *followCellNib = [UINib nibWithNibName:@"MFFollowingTableCell" bundle:nil];
    [self.tableView registerNib:followCellNib forCellReuseIdentifier:@"MFFollowingTableCell"];
    
    int topInset = 0;
    int botInset = 0;

    if (!self.container.isPlayerViewHidden) {
        botInset += self.tabBarController.tabBar.bounds.size.height;
    }
    topInset = 64 + 20;
    self.headerImageView.image = self.headerImage;
    [self.tableView setContentInset:UIEdgeInsetsMake(topInset, 0, botInset, 0)];
    [self.tableView setContentOffset:CGPointMake(0, -topInset)];
}

-(void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.tableView.delegate = nil;
}

#pragma mark - Properties

- (void)getFollowItemsFromDatabase{
    self.followers = [[self.userInfo.followed array] mutableCopy];
    
}

- (void)followItemsRequest{
    [[IRNetworkClient sharedInstance] userFollowersWithUsername:self.userInfo.extId successBlock:^(NSDictionary *dictionary) {
        NSArray* followers = [dataManager convertAndAddFollowItemsToDatabase:dictionary[@"followed"]];
        
        self.userInfo.followed = [NSOrderedSet orderedSetWithArray:followers];
        
        [self getFollowItemsFromDatabase];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

    }];
}

- (void)setFollowers:(NSMutableArray *)followers
{
    _followers = followers;
    [self.tableView reloadData];
}

#pragma mark - TableView Delegate & Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1){
        if (self.followers.count>0){
            return 1;
        } else {
            return 0;
        }
    }
    return _followers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1){
        MFNumberOfFollowersTableViewCell* cell = (MFNumberOfFollowersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MFNumberOfFollowersTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MFNumberOfFollowersTableViewCell" owner:nil options:nil] lastObject];
        }
        if (self.shouldJustDisplayGivenFollowItems) {
            cell.label.text = [NSString stringWithFormat:NSLocalizedString(@"and %lu other followers",nil), self.numberOfTotalFollowers - self.followers.count];
        } else {
            cell.label.text = [NSString stringWithFormat:NSLocalizedString(@"%lu followers",nil), self.followers.count];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
    static NSString *cellID = @"MFFollowingTableCell";
    
    MFFollowingTableCell *cell = (MFFollowingTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MFFollowingTableCell" owner:nil options:nil] lastObject];
    }
    
    cell.cellDelegate = self;
    cell.isMyFollowItem = self.isMyFollowItems;
    [cell setFollowingInfo:_followers[indexPath.row]];
    if (self.isMyFollowItems) {
        [cell setSwipeButtons:_followers[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0){
        MFFollowItem *followItem = _followers[indexPath.row];
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:followItem.extId];
        userInfo.username = followItem.username;
        userInfo.profileImage = [followItem.picture stringByReplacingOccurrencesOfString:@" " withString:@""];
        userInfo.facebookID = followItem.facebookID;
        userInfo.extId = followItem.extId;
        userInfo.name = followItem.name;
        userInfo.isFollowed = followItem.isFollowed;
        //userInfo.isArtist = NO;
        [self showUserProfileWithUserInfo:userInfo];
        //[self.delegate didSelectUserWithUserInfo:userInfo];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - MFFollowingTableCellDelegate methods

- (void)didSelectFollow:(MFFollowingTableCell *)cell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    MFFollowItem *followItem = _followers[indexPath.row];
    
    followItem.isFollowed = !followItem.isFollowed;
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
                                                   [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                               }];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ScrollView delegate

@end
