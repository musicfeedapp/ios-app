//
//  MFFollowingViewController.m
//  botmusic
//
//  Created by Panda Systems on 2/9/15.
//
//

#import "MFFollowingViewController.h"
#import "MFFollowingTableCell.h"
#import "MFNotificationManager.h"
#import <UIColor+Expanded.h>
#import "MFNumberOfFollowersTableViewCell.h"
#import "AbstractViewController.h"

static CGFloat const HEADER_HEIGHT = 55.0f;

@interface MFFollowingViewController () <MFFollowingTableCellDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;

@property (nonatomic) BOOL isScrollToBottom;

@end

@implementation MFFollowingViewController{
   CGFloat previousTableViewYOffset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getFollowItemsFromDatabase];
    [self followItemsRequest];
    // Do any additional setup after loading the view.
    
    UINib *followCellNib = [UINib nibWithNibName:@"MFFollowingTableCell" bundle:nil];
    [self.tableView registerNib:followCellNib forCellReuseIdentifier:@"MFFollowingTableCell"];
    self.showFollowingState = MFShowArtists;
    if (self.hideSortTabs) {
        self.headerViewHeightConstraint.constant = 0.0;
    }
    int topInset = 0;
    int botInset = 0;

    botInset += self.tabBarController.tabBar.bounds.size.height;
    topInset = 119+20;
    [self.tableView setContentInset:UIEdgeInsetsMake(topInset, 0, botInset, 0)];
    [self.tableView setContentOffset:CGPointMake(0, -topInset)];
    [self scrollViewDidScroll:self.tableView];
    self.segmentedControl.tintColor = [UIColor colorWithRGBHex:kMediumColor];

    if (_userInfo.isArtist) {
        [self.segmentedControl removeSegmentAtIndex:0 animated:NO];
        [self.segmentedControl setSelectedSegmentIndex:1]; // workaround for segment control bug
        [self.segmentedControl setSelectedSegmentIndex:0];
        [self.segmentedControl setTitle:@"Posts" forSegmentAtIndex:0];
        [self.segmentedControl setTitle:@"A-Z" forSegmentAtIndex:1];

    } else {
        [self.segmentedControl setSelectedSegmentIndex:1];

    }

    self.showFollowingState = MFShowArtists;
    [self didTouchSegmentControl:self.segmentedControl];
    self.headerImageView.image = self.headerImage;
}

-(void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}
- (void)dealloc {
    self.tableView.delegate = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFollowItemsFromDatabase{
    self.artistsFollowItems = [[self.userInfo.followingArtists array] mutableCopy];
    self.usersFollowItems = [[self.userInfo.followingFriends array] mutableCopy];
    [self updateAllFollowItems];

}

- (void)followItemsRequest{
    [[IRNetworkClient sharedInstance] userFollowingWithUsername:self.userInfo.extId successBlock:^(NSDictionary *dictionary) {
        NSArray* artists = [dataManager convertAndAddFollowItemsToDatabase:dictionary[@"followings"][@"artists"]];
        NSArray* friends = [dataManager convertAndAddFollowItemsToDatabase:dictionary[@"followings"][@"friends"]];

        self.userInfo.followingArtists = [NSOrderedSet orderedSetWithArray:artists];
        self.userInfo.followingFriends = [NSOrderedSet orderedSetWithArray:friends];
        
        [self getFollowItemsFromDatabase];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

- (void)updateAllFollowItems
{
    NSMutableArray *allItems = [NSMutableArray arrayWithArray:self.usersFollowItems];
    [allItems addObjectsFromArray:self.artistsFollowItems];
    self.allFollowItems = allItems;
}

#pragma mark - Properties

- (void)setArtistsFollowItems:(NSMutableArray *)artistsFollowItems
{
    _artistsFollowItems = artistsFollowItems;
    [self updateAllFollowItems];
    [self.tableView reloadData];
}

- (void)setUsersFollowItems:(NSMutableArray *)usersFollowItems
{
    _usersFollowItems = usersFollowItems;
    [self updateAllFollowItems];
    [self.tableView reloadData];
}

- (void)setAllFollowItems:(NSMutableArray *)allFollowItems
{
    _allFollowItems = [allFollowItems mutableCopy];
    //NSSortDescriptor *timelineSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timelineCount" ascending:NO];
    NSSortDescriptor *alphabetSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:alphabetSortDescriptor, nil];
    _allFollowItems = [NSMutableArray arrayWithArray:[_allFollowItems sortedArrayUsingDescriptors:sortDescriptors]];
}

#pragma mark - IBActions

- (void)didTouchUpUsersButton:(id)sender
{
    if (_showFollowingState == MFShowArtists) {
        [self.showUsersButton setSelected:YES];
        self.showFollowingState = MFShowAll;
    }
    else if (_showFollowingState == MFShowAll) {
        [self.showUsersButton setSelected:NO];
        self.showFollowingState = MFShowArtists;
    }
    //[self.delegate didChangeShowFollowingState];
    [self.tableView reloadData];
}

- (void)didTouchUpArtistsButton:(id)sender
{
    if (_showFollowingState == MFShowUsers) {
        [self.showArtistsButton setSelected:YES];
        self.showFollowingState = MFShowAll;
    }
    else if (_showFollowingState == MFShowAll) {
        [self.showArtistsButton setSelected:NO];
        self.showFollowingState = MFShowUsers;
    }
    //[self.delegate didChangeShowFollowingState];
    [self.tableView reloadData];
}

- (IBAction)didTouchSegmentControl:(id)sender {
    if (_userInfo.isArtist) {
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            self.showFollowingState = MFShowArtists;
        } else if (self.segmentedControl.selectedSegmentIndex == 1) {
            self.showFollowingState = MFShowAll;
        }
    } else {
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            self.showFollowingState = MFShowUsers;
        } else if (self.segmentedControl.selectedSegmentIndex == 1) {
           self.showFollowingState = MFShowArtists;
        } else {
            self.showFollowingState = MFShowAll;
        }
    }
    //[self.delegate didChangeShowFollowingState];
    [self.tableView reloadData];
}

#pragma mark - TableView Delegate & Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (_showFollowingState) {
        case MFShowAll:
            if (section==1){
                if (self.allFollowItems.count>0){
                    return 1;
                } else {
                    return 0;
                }
            }
            return self.allFollowItems.count;
        case MFShowUsers:
            if (section==1){
                if (self.usersFollowItems.count>0){
                    return 1;
                } else {
                    return 0;
                }
            }
            return self.usersFollowItems.count;
        case MFShowArtists:
            if (section==1){
                if (self.artistsFollowItems.count>0){
                    return 1;
                } else {
                    return 0;
                }
            }
            return self.artistsFollowItems.count;
    }
    return 0;
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
        NSUInteger number = 0;
        switch (_showFollowingState) {
            case MFShowAll:
                number = self.allFollowItems.count;
                break;
            case MFShowUsers:
                number = self.usersFollowItems.count;
                break;
            case MFShowArtists:
                number = self.artistsFollowItems.count;
                break;
        }
        cell.label.text = [NSString stringWithFormat:NSLocalizedString(@"%lu following",nil), number];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    static NSString *cellID = @"MFFollowingTableCell";
    
    MFFollowingTableCell *cell = (MFFollowingTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MFFollowingTableCell" owner:nil options:nil] lastObject];
    }
    int i = cell.frame.size.width;
    cell.cellDelegate = self;
    
    switch (_showFollowingState) {
        case MFShowAll:
            [cell setFollowingInfo:_allFollowItems[indexPath.row]];
            if (self.isMyFollowItems) {
                [cell setSwipeButtons:_allFollowItems[indexPath.row]];
            }
            break;
        case MFShowUsers:
            [cell setFollowingInfo:_usersFollowItems[indexPath.row]];
            if (self.isMyFollowItems) {
                [cell setSwipeButtons:_usersFollowItems[indexPath.row]];
            }
            break;
        case MFShowArtists:
            [cell setFollowingInfo:_artistsFollowItems[indexPath.row]];
            if (self.isMyFollowItems) {
                [cell setSwipeButtons:_artistsFollowItems[indexPath.row]];
            }
            break;
    }
    
    i = cell.frame.size.width;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        MFFollowItem *followItem;
        switch (_showFollowingState) {
            case MFShowAll:
                followItem = _allFollowItems[indexPath.row];
                break;
            case MFShowUsers:
                followItem = _usersFollowItems[indexPath.row];
                break;
            case MFShowArtists:
                followItem = _artistsFollowItems[indexPath.row];
                break;
        }
        
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:followItem.extId];
        userInfo.username = followItem.username;
        userInfo.profileImage = [followItem.picture stringByReplacingOccurrencesOfString:@" " withString:@""];
        userInfo.facebookID = followItem.facebookID;
        userInfo.extId = followItem.extId;
        userInfo.name = followItem.name;
        if ([self.artistsFollowItems containsObject:followItem]) {
            //userInfo.isArtist = YES;
        }
        //[self.delegate didSelectUserWithUserInfo:userInfo];
        [self showUserProfileWithUserInfo:userInfo];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - MFFollowingTableCellDelegate methods

- (void)didSelectFollow:(MFFollowingTableCell *)cell
{
    
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    MFFollowItem *followItem;
    switch (_showFollowingState) {
        case MFShowAll:
            followItem = _allFollowItems[indexPath.row];
            break;
        case MFShowUsers:
            followItem = _usersFollowItems[indexPath.row];
            break;
        case MFShowArtists:
            followItem = _artistsFollowItems[indexPath.row];
            break;
    }
    
    followItem.isFollowed = !followItem.isFollowed;
    NSDictionary *proposalsDictionary = @{@"ext_id" : followItem.extId,
                                          @"followed" : followItem.isFollowed ? @"true" : @"false"};
    
    
    [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                      token:[userManager fbToken]
                                                  proposals:@[proposalsDictionary]
                                               successBlock:^{
                                                    [MFNotificationManager postUpdateUserFollowingNotification:nil];
                                               }
                                               failureBlock:^(NSString *errorMessage){
                                                   [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                               }];
    
    if (!followItem.isFollowed) {
        [self.allFollowItems removeObject:followItem];
        switch (_showFollowingState) {
            case MFShowAll:
                break;
            case MFShowUsers:                        
                [self.usersFollowItems removeObject:followItem];
                break;
            case MFShowArtists:
                [self.artistsFollowItems removeObject:followItem];
                break;
        }
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    else {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:followItem.extId];
    userInfo.username = followItem.username;
    userInfo.profileImage = [followItem.picture stringByReplacingOccurrencesOfString:@" " withString:@""];
    userInfo.facebookID = followItem.facebookID;
    userInfo.extId = followItem.extId;
    userInfo.isFollowed = followItem.isFollowed;
    [MFNotificationManager postUpdateUserFollowingNotification:userInfo];
    
}

#pragma mark - Header Animation

- (CGFloat) headerHeight{
    return self.headerViewHeightConstraint.constant;
}

- (void) setHeaderHeight:(CGFloat)headerHeight{
    self.headerViewHeightConstraint.constant = headerHeight;
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.headerViewTopConstraint.constant = - scrollView.contentOffset.y;
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
