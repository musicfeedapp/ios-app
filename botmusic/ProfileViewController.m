//
//  ProfileViewController.m
//  botmusic
//
//  Created by Илья Романеня on 04.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "ProfileViewController.h"
#import "MFStatusManager.h"
#import "ArtistCell.h"
#import "RFQuiltLayout.h"
#import "MGSwipeButton.h"
#import "MFTrackTableCell.h"
#import "TrackInfoViewController.h"

@interface ProfileViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) MFStatusManager *statusManager;
@property (nonatomic, assign) NSInteger currentIndex;

- (IBAction)didTapAtView:(id)sender;
- (IBAction)didTapAtHeader:(id)sender;

@end

CGFloat const TABLE_HEADER_HEIGHT=32.0f;
CGFloat const TABLE_VIEW_DEFAULT_OFFSET=238.0f;
CGFloat const TABLE_VIEW_FOLLOW_OFFSET=278.0f;
NSString *const COMBINED_TITLE=@"FOLLOWING";
NSString *const FRIENDS_TITLE=@"FRIENDS";
NSString *const ARTISTS_TITLE=@"ARTISTS";

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _selectedIndex=-1;

    [self setCollectionViewSettings];

    [self addToObserver];
    
    [self registerCells];
    
    [self setProfile];
    
    [self setButtons];
    
    [self setSegmentControl];
    
    [self setPullToRefresh];
    
    [self.view insertSubview:self.errorView belowSubview:self.mainHeaderView];
    
    [self setReachabilityNotifications];
    
    if (!self.container.isPlayerViewHidden) {
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, [[UIScreen mainScreen] bounds].size.height - PLAYER_VIEW_HEIGHT - self.mainHeaderView.frame.size.height)];
        [self.tableView setFrame:self.scrollView.bounds];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView setHidden:YES];
    [self.collectionView setHidden:YES];
    
    [self refreshCountLabels];
    
    [self segmentedViewController:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    playerManager.videoPlayer.currentViewController = self;
    
    [self downloadData];
    
    [self.container setPanMode:MFSideMenuPanModeDefault];
}

-(void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)addToObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didKeyboardShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willKeyboardChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

-(void)registerCells
{
    UINib *trackCellNib = [UINib nibWithNibName:@"TrackCell" bundle:nil];
    [self.tableView registerNib:trackCellNib
         forCellReuseIdentifier:@"TrackCell"];
    
    UINib *followCellNib = [UINib nibWithNibName:@"FollowCell" bundle:nil];
    [self.tableView registerNib:followCellNib
         forCellReuseIdentifier:@"FollowCell"];
    
    self.tableView.sectionHeaderHeight=0;
    self.tableView.sectionFooterHeight=0;
}

- (void)setPullToRefresh
{
    self.scrollView.delegate = self;
    
    [self.scrollView addPullToRefreshWithActionHandler:^{
        [self pullToRefreshTriggered];
    }];
    
    self.scrollView.pullToRefreshView.arrowColor = [UIColor colorWithRGBHex:kActiveColor];
    self.scrollView.pullToRefreshView.textColor = [UIColor colorWithRGBHex:kActiveColor];
    self.scrollView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}

- (void)setSegmentControl
{
    BaseButton* tracksButton = [[BaseButton alloc] initWithFrame:CGRectMake(0, 0, 106, 46)];
    BaseButton* followingButton = [[BaseButton alloc] initWithFrame:CGRectMake(0, 0, 106, 46)];
    BaseButton* followersButton = [[BaseButton alloc] initWithFrame:CGRectMake(0, 0, 106, 46)];
    
//    [self.segmentedControl addTarget:self action:@selector(segmentedViewController:) forControlEvents:UIControlEventValueChanged];
//    [self.segmentedControl setSeparatorImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:kSeparatorColor]]];
//    [self.segmentedControl setBackgroundColor:[UIColor whiteColor]];
//    [self.segmentedControl setButtonsArray:@[tracksButton, followingButton, followersButton]];
//    [self.segmentedControl setSegmentedControlMode:AKSegmentedControlModeSticky];
//    [self.segmentedControl setSelectedIndex:0];
}

- (void)setProfile
{
//    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
//    [self.profilePicture setImageSquareCropAndCacheWithURL:[NSURL URLWithString:self.userInfo.profileImage relativeToURL:BASE_URL]];
//    [self.profileBackground setImageAndCropFramewithURL:[NSURL URLWithString:self.userInfo.background] replaceImage:nil];
    
    if(self.isNotMyProfile){
        self.headerLabel.text = [self.userInfo name];
    }else{
        self.headerLabel.text = [self.userInfo abbriviatedName];
    }
}

- (void)setButtons
{
    if (self.isNotMyProfile) {
        if(!self.isSearchProfile) {
            [self.backButton setHidden:NO];
            [self.menuButton setHidden:YES];
        }
        
        [self.followButton setHidden:NO];
        [self.searchButton setHidden:YES];
        
        //[self.postLabel setText:@"Tracks"];
    }
    else {
        [self.followButton setHidden:YES];
        if (self.navigationController.viewControllers.count == 1) {
            [self.menuButton setHidden:NO];
            [self.backButton setHidden:YES];
        }
        else {
            [self.menuButton setHidden:YES];
            [self.backButton setHidden:NO];
        }
        [self.searchButton setHidden:NO];
        
        //[self.postLabel setText:@"Tracks"];
    }
}

- (void)segmentedViewController:(id)sender
{
    [self didTouchUpCancelButton:nil];
    
    //self.currentIndex=[self.segmentedControl.selectedIndexes lastIndex];
    NSMutableArray *combinedItems;
    switch (self.currentIndex)
    {
        case 0:
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self setDefalutSettings];
            [self.tableView reloadData];
            [self setTableViewHeight];
            break;
        case 1:
            combinedItems=[NSMutableArray arrayWithArray:self.friendsFollowItems];
            [combinedItems addObjectsFromArray:self.artistsFollowItems];
            self.combinedFollowItems=combinedItems;
            
            if (self.combinedFollowItems.count != 0) {
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            }
            [self setFollowingsSettings];
            [self.friendsButton setSelected:YES];
            [self.artistsButton setSelected:NO];
            [self didTouchUpArtistsButton:nil];
            break;
        case 2:
            if (self.followers.count != 0) {
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            }
            [self setDefalutSettings];
            [self.tableView reloadData];
            [self setTableViewHeight];
            break;
    }
}

- (void)downloadData
{
    self.friendsFollowItems=[self.userInfo.followingFriends mutableCopy];
    self.artistsFollowItems=[self.userInfo.followingArtists mutableCopy];
    self.followers=[self.userInfo.followed mutableCopy];
    self.tracks=[self.userInfo.tracks mutableCopy];
    
    [self refreshCountLabels];
    [self.tableView reloadData];
    
    self.statusManager=[[MFStatusManager alloc]initWithNumber:self.tracks.count];
    
    if(self.isNotMyProfile)
    {
        [self.followButton setSelected:self.userInfo.isFollowed];
    }
    else
    {
        [self profileRequest];
        //[self tracksRequest]; TODO think about
    }
    //self.currentIndex=[self.segmentedControl.selectedIndexes lastIndex];
    if (self.currentIndex == 1) {
        [self setFollowingsSettings];
        if (self.friendsButton.isSelected && self.artistsButton.isSelected) {
            [self.friendsButton setSelected:NO];
            [self didTouchUpFriendsButton:nil];
        }
        else if (self.friendsButton.isSelected) {
            [self didTouchUpFriendsButton:nil];
        }
        else {
            [self didTouchUpArtistsButton:nil];
        }
    }
    else {
        [self setDefalutSettings];
        [self setTableViewHeight];
    }
}

- (void)refreshCountLabels
{
    if (self.tracks)
    {
        NSInteger count = self.tracks.count;
        //self.tracksLabel.text = [NSString stringWithFormat:@"%ld",(long)count];
    }
    if ((self.friendsFollowItems) || (self.artistsFollowItems))
    {
        //self.followingLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)(self.friendsFollowItems.count + self.artistsFollowItems.count)];
    }
    if (self.followers)
    {
        //self.followersLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.followers.count];
    }
}

#pragma mark - Table View delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.isSearchMode)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.currentIndex)
    {
        case 0:
            return 106.5;
            break;
        case 1:
        case 2:
            return 65.0f;
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *trackCellIdentifier = @"TrackCell";
    static NSString *followingCellIdentifier = @"FollowCell";
    
    if (self.isSearchMode) {
        if (self.currentIndex == 1) {
            if (self.searchResultArray.count)
            {
                FollowCell *cell = [tableView dequeueReusableCellWithIdentifier:followingCellIdentifier forIndexPath:indexPath];
                
                cell.delegate = self;
                if (self.searchResultArray.count > indexPath.row) {
                    [cell setFollowItem:self.searchResultArray[indexPath.row] buttonHidden:NO];
                    [cell.followButton setHidden:self.isNotMyProfile];
                }
                cell.indexPath = indexPath;
                
                return cell;
            }
        }
        else if (self.currentIndex == 2) {
            FollowCell *cell = [tableView dequeueReusableCellWithIdentifier:followingCellIdentifier forIndexPath:indexPath];
            
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"FollowCell" owner:nil options:nil]lastObject];
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            if (self.searchResultArray.count>indexPath.row){
                [cell setFollowItem:self.searchResultArray[indexPath.row] buttonHidden:YES];
            }
            [cell.followButton setHidden:self.isNotMyProfile];
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            return cell;
        }
        else if (self.currentIndex == 0) {
            TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:trackCellIdentifier forIndexPath:indexPath];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            if(self.searchResultArray.count>indexPath.row){
                [cell setTrackInfo:self.searchResultArray[indexPath.row]];
            }
            
            [cell.sliderView setCanOpenRightSide:!self.isNotMyProfile];
            [cell setCanLike:self.isNotMyProfile];
            
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            UIColor *color;
            
            if(indexPath.row%2==0)
            {
                color=[UIColor colorWithRed:233.0f/255.0f green:233.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
                
            }
            else
            {
                color=[UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
            }
            
            [cell setBackgroundColor:color];
            [cell.sliderView.upperView setBackgroundColor:color];
            
            return cell;
        }
        return 0;
    }
    else {
        switch (self.currentIndex)
        {
            case 0:
            {
                TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:trackCellIdentifier forIndexPath:indexPath];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                if(self.tracks.count>indexPath.row){
                    [cell setTrackInfo:self.tracks[indexPath.row]];
                }
                
                [cell.sliderView setCanOpenRightSide:!self.isNotMyProfile];
                [cell setCanLike:self.isNotMyProfile];
                
                cell.delegate = self;
                cell.indexPath = indexPath;
                
                UIColor *color;
                
                if(indexPath.row%2==0)
                {
                    color = [UIColor colorWithRed:233.0f/255.0f green:233.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
                    
                }
                else
                {
                    color = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
                }
                
                [cell setBackgroundColor:color];
                [cell.sliderView.upperView setBackgroundColor:color];
                
                return cell;
                break;
            }
            case 1:
            {
                if (self.artistsButton.isSelected) {
                    if (self.combinedFollowItems.count) {
                        return [self cellForPeopleSectionInTableView:tableView indexPath:indexPath];
                    }
                }
                else {
                    if (self.friendsFollowItems.count) {
                        return [self cellForPeopleSectionInTableView:tableView indexPath:indexPath];
                    }
                }
            }
            case 2:
            {
                FollowCell *cell = [tableView dequeueReusableCellWithIdentifier:followingCellIdentifier forIndexPath:indexPath];
                
                if(cell==nil){
                    cell=[[[NSBundle mainBundle]loadNibNamed:@"FollowCell" owner:nil options:nil]lastObject];
                }
                
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                if (self.followers.count>indexPath.row){
                    [cell setFollowItem:self.followers[indexPath.row] buttonHidden:YES];
                }
                [cell.followButton setHidden:self.isNotMyProfile];
                cell.delegate = self;
                cell.indexPath = indexPath;
                
                return cell;
                break;
            }
            case 3:
                return 0;
                break;
            default:
                break;
        }
        
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isSearchMode)
    {
        if (self.currentIndex == 1 || self.currentIndex == 2) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            MFFollowItem* followItem;
            
            if (self.searchResultArray.count)
            {
                if (self.searchResultArray.count>indexPath.row) {
                    followItem = self.searchResultArray[indexPath.row];
                }
            }
            
            [self openAnotherUserProfileWith:followItem.username];
        }
    }
    else
    {
        switch (self.currentIndex)
        {
            case 0:
                [self didTapOnView:indexPath];
                break;
            case 1:
            {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                MFFollowItem* followItem;
                if (self.artistsButton.isSelected) {
                    if (self.combinedFollowItems.count) {
                        if(self.combinedFollowItems.count > indexPath.row) {
                            followItem = self.combinedFollowItems[indexPath.row];
                        }
                    }
                }
                else {
                    if (self.friendsFollowItems.count) {
                        if(self.friendsFollowItems.count > indexPath.row) {
                            followItem = self.friendsFollowItems[indexPath.row];
                        }
                    }
                }
                
                [self openAnotherUserProfileWith:followItem.username];
                
                break;
            }
            case 2:
            {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                MFFollowItem* followItem = self.followers[indexPath.row];
                
                [self openAnotherUserProfileWith:followItem.username];
                
                break;
            }
            default:
            {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                break;
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isSearchMode)
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    else
    {
        switch (self.currentIndex)
        {
            case 0:
                return self.tracks.count;
                break;
            case 1:
                if (self.friendsButton.isSelected && self.artistsButton.isSelected) {
                    return self.combinedFollowItems.count;
                }
                else {
                    return self.friendsFollowItems.count;
                }
                break;
            case 2:
                return self.followers.count;
                break;
        }
        
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc]initWithFrame:CGRectZero];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction{
    
    if(direction==MGSwipeDirectionRightToLeft){
        return YES;
    }else{
        return NO;
    }    
}

- (BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    NSIndexPath *indexPath=[self.tableView indexPathForCell:cell];
    MFTrackItem *trackItem=self.tracks[indexPath.row];
    
    [UIView animateWithDuration:0.0 animations:^{
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
    }];
    
    self.trackItem=trackItem;
    [self removeFromFavorites];
    
    [self.tracks removeObjectAtIndex:indexPath.row];
    
    [self refreshCountLabels]; 
    
    return YES;
}

#pragma mark - Collection View Delegate & Sources methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.isSearchMode) {
        return self.searchResultArray.count;
    }
    else {
        return self.artistsFollowItems.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"CellID";
    
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    ArtistCell *artistCell=(ArtistCell*)[cell.contentView viewWithTag:1];
    
    if(artistCell==nil)
    {
        artistCell=[[[NSBundle mainBundle]loadNibNamed:@"ArtistCell" owner:nil options:nil]lastObject];
        artistCell.tag=1;
        [cell.contentView addSubview:artistCell];
    }
    
    MFFollowItem *followItem;
    if (self.isSearchMode) {
        followItem=self.searchResultArray[indexPath.row];
    }
    else {
        followItem=self.artistsFollowItems[indexPath.row];
    }
    
    [artistCell setFollowInfo:followItem];
    [artistCell setIndexPath:indexPath];
    [self setSize:CGSizeMake([ArtistCell sizeOfArtistCell], [ArtistCell sizeOfArtistCell]) ofCollectionCell:cell];
    [artistCell setIsSelected:NO];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView cellForItemAtIndexPath:indexPath];
    
    ArtistCell *artistCell=(ArtistCell*)[cell.contentView viewWithTag:1];
    
    MFFollowItem *followItem;
    if(self.isSearchMode) {
        followItem = self.searchResultArray[artistCell.indexPath.row];
    }
    else {
        followItem = self.artistsFollowItems[artistCell.indexPath.row];
    }
    
    [self openAnotherUserProfileWith:followItem.username];
}

#pragma mark - CollectionView settings

- (void)setCollectionViewSettings
{
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CellID"];
    
    [self setQuiltLayout];
    
    [self.collectionView setHidden:YES];
    [self.collectionView reloadData];
}

- (void)setQuiltLayout
{
    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels =CGSizeMake([ArtistCell sizeOfArtistCell], [ArtistCell sizeOfArtistCell]);
}

#pragma mark - RFQuiltLayout Delegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(1, 1);
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - FeedTrack delegate

- (void)didTapOnView:(NSIndexPath *)indexPath
{
    if (self.container.isPlayerViewHidden) {
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height - PLAYER_VIEW_HEIGHT)];
        [self setTableViewHeight];
    }
    
    [self.container setPlayerViewHidden:NO];
    
//    [playerManager playTracks:self.tracks trackIndex:indexPath.row];
    [saver setTrackSource:MFTracksSourceNone];
}

- (void)didLike:(NSIndexPath *)indexPath
{
    MFTrackItem *trackItem=self.tracks[indexPath.row];
    [trackItem likeTrackItem];
    
    [self.tracks replaceObjectAtIndex:indexPath.row withObject:trackItem];
    
    [self.tableView reloadData];
    
    [[IRNetworkClient sharedInstance]likeTrackById:trackItem.itemId
                                         withEmail:userManager.userInfo.email
                                             token:[userManager fbToken]
                                      successBlock:^{}
                                      failureBlock:^(NSString *errorMessage){
                                          [self showErrorConnectionMessage];
                                      }];
}

- (void)didUnlike:(NSIndexPath *)indexPath
{
    MFTrackItem *trackItem=self.tracks[indexPath.row];
    [trackItem dislikeTrackItem];
    
    [self.tracks replaceObjectAtIndex:indexPath.row withObject:trackItem];
    
    [self.tableView reloadData];
    
    [[IRNetworkClient sharedInstance]unlikeTrackById:trackItem.itemId
                                         withEmail:userManager.userInfo.email
                                             token:[userManager fbToken]
                                        successBlock:^{}
                                      failureBlock:^(NSString *errorMessage){
                                          [self showErrorConnectionMessage];
                                      }];
}

- (void)didSelectComment:(NSIndexPath *)indexPath
{
//    TrackInfoViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"trackInfoViewController"];
//    trackInfoVC.container = self.container;
//    trackInfoVC.trackItem = (MFTrackItem*)self.tracks[indexPath.row];
////    trackInfoVC.playDelegate = self;
//    trackInfoVC.isCommentsView = YES;
    
//    [self.navControllerToPush pushViewController:trackInfoVC animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentsViewController *commentsVC = [storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    
    [commentsVC setDelegate:self];
    [commentsVC setTrackItem:(MFTrackItem*)self.tracks[indexPath.row]];
    
    _selectedIndex=indexPath.row;
    
    [self.container setPlayerViewHidden:YES];
    
    [self.navigationController pushViewController:commentsVC animated:YES];
}

- (void)didShare:(NSIndexPath *)indexPath
{
    self.trackItem=self.tracks[indexPath.row];
    
    [self showSharing];
}

- (void)didPlayVideo:(NSIndexPath *)indexPath
{
    
    NSInteger index=[self.statusManager activeIndex];
    
    if(index!=NSNotFound){
        NSIndexPath *videoIndexPath=[NSIndexPath indexPathForItem:index inSection:0];
        TrackCell *cell=(TrackCell*)[self.tableView cellForRowAtIndexPath:videoIndexPath];
        
        [cell.activityView stopAnimating];
        [cell.playVideoButton setHidden:NO];
        //[cell.playerView clearVideo];
    }
    
    MFStatus *status=self.statusManager.statusArray[indexPath.row];
    [status addStatus:StatusVideoPlaying];
    [self.statusManager.statusArray replaceObjectAtIndex:indexPath.row withObject:status];
}

- (void)didOpenDelete:(NSIndexPath *)indexPath
{
    
    NSInteger index=[self.statusManager deletingIndex];
    
    if(index!=NSNotFound){
        NSIndexPath *deleteIndexPath=[NSIndexPath indexPathForItem:index inSection:0];
        TrackCell *cell=(TrackCell*)[self.tableView cellForRowAtIndexPath:deleteIndexPath];
        
        [cell.sliderView closeSliderAnimated:YES];
    }
    
    TrackCell *cell=(TrackCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.sliderView closeSliderAnimated:YES];
    
    [self.statusManager setDeletingIndex:indexPath.row];
}

- (void)didDelete:(NSIndexPath *)indexPath
{
    MFTrackItem *trackItem=self.tracks[indexPath.row];
    
    [self.tracks removeObjectAtIndex:indexPath.row];
    
    [self refreshCountLabels];
    
    [self.tableView reloadData];
    self.trackItem=trackItem;
    [self removeFromFavorites];
}

- (void)didSelectShowFriend:(NSIndexPath *)indexPath
{
    MFTrackItem *trackItem=self.tracks[indexPath.row];
    
    if(![self.userInfo.username isEqualToString:trackItem.username]){
        
        [self openAnotherUserProfileWith:trackItem.username];
    }
}

#pragma mark - CommentDelegate methods

- (void)didAddComment
{
    MFTrackItem *trackItem=self.tracks[_selectedIndex];
    [trackItem addComment];
    
    [self.tableView reloadData];
}

- (void)didRemoveComment
{
    MFTrackItem *trackItem=self.tracks[_selectedIndex];
    [trackItem removeComment];
    
    [self.tableView reloadData];
}

- (void)willCloseCommentController
{
    if([playerManager currentTrack])
    {
        [self.container setPlayerViewHidden:NO];
    }
}


- (void)didShareTrackItem
{
    NSInteger index=[self.tracks indexOfObject:self.trackItem];
    [self.tracks replaceObjectAtIndex:index withObject:self.trackItem];
    [self.tableView reloadData];
}


#pragma mark - Pull and Drag triggers

- (void)pullTriggered
{
    NSLogExt(@"segmentedControl.selectedIndexes lastIndex == %lu", (unsigned long)self.currentIndex);
    
    switch (self.currentIndex)
    {
        case 0:
            //TODO it's strange to update whole profile but it have different results with tracks update
            [self profileRequest];
            //[self tracksRequest];
            break;
        case 1:
            [self.tableView reloadData];
            break;
        case 2:
            [self.tableView reloadData];
            break;
        case 3:
            break;
        default:
            break;
    }
    
}

- (void)pullToRefreshTriggered
{
    if (self.isNotMyProfile) {
        [self userProfileRequest];
    }
    else {
        [self profileRequest];
    }
    
    if (!self.isNotMyProfile) {
        [[IRNetworkClient sharedInstance] refreshProfileWithSuccessBlock:^(NSDictionary *dictionary) {

        } failureBlock:^(NSString *errorMessage) {

        }];
    }
}

#pragma mark - Follow Cells delegate

- (void)changeFollowing:(FollowCell *)sender
{
    if (sender.indexPath.row < self.friendsFollowItems.count) {
        MFFollowItem *followItem = self.friendsFollowItems[sender.indexPath.row];
        
        if (followItem) {
            followItem.isFollowed = !followItem.isFollowed;
            
            [sender stopProcessing];
            [self refreshCountLabels];
            
            [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                              token:[userManager fbToken]
                                                          proposals:[MFFollowItem idsFromFollowItems:@[followItem]]
                                                       successBlock:^
             {
                 
             }
                                                       failureBlock:^(NSString* errorMessage)
             {
//                 followItem.isFollowed = !followItem.isFollowed;
//                 [sender stopProcessing];
//                 [self refreshCountLabels];
             }];
        }
    }
}

- (BOOL)following:(FollowCell *)sender
{
    if (sender.indexPath.row < self.friendsFollowItems.count) {
        MFFollowItem *followItem = self.friendsFollowItems[sender.indexPath.row];
        
        if (followItem) {
            return followItem.isFollowed;
        }
    }
    
    return NO;
}

#pragma mark - Follow Cells

- (UITableViewCell*)cellForPeopleSectionInTableView:(UITableView *)tableView indexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"FollowCell";
    
    FollowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    if (self.artistsButton.isSelected) {
        if (self.combinedFollowItems.count>indexPath.row) {
            [cell setFollowItem:self.combinedFollowItems[indexPath.row] buttonHidden:NO];
            [cell.followButton setHidden:self.isNotMyProfile];
        }
    }
    else {
        if (self.friendsFollowItems.count>indexPath.row) {
            [cell setFollowItem:self.friendsFollowItems[indexPath.row] buttonHidden:NO];
            [cell.followButton setHidden:self.isNotMyProfile];
        }
    }
    cell.indexPath = indexPath;
    
    return cell;
}

- (UITableViewCell*)cellForArtistSectionInTableView:(UITableView *)tableView indexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"FollowCell";
    
    FollowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate = self;
    
    if(self.artistsFollowItems.count>indexPath.row){
        [cell setFollowItem:self.artistsFollowItems[indexPath.row] buttonHidden:NO];
        [cell.followButton setHidden:self.isNotMyProfile];
    }
    cell.indexPath = indexPath;
    
    return cell;
}

#pragma mark - Network
//TODO remove as profile dublicate?
- (void)tracksRequest
{
    [[IRNetworkClient sharedInstance] tracksWithEmail:userManager.userInfo.email
                                                token:[userManager fbToken]
                                         successBlock:^(NSArray* tracksArrayData)
     {
         NSArray *tracks=[dataManager convertAndAddTracksToDatabase:tracksArrayData];
         [self.userInfo setTracks:tracks];
         self.tracks=[tracks mutableCopy];
         
          self.statusManager=[[MFStatusManager alloc]initWithNumber:self.tracks.count];
         
         [self refreshCountLabels];
         
         if(self.currentIndex==0){
             [self.tableView reloadData];
             
             [self setDefalutSettings];
             [self setTableViewHeight];
         }
         
         [self hideTopErrorViewWithMessage:self.kConnectedMessage];
     }
     failureBlock:^(NSString* errorMessage)
     {
         [self showAndKeepTopErrorViewWithMessage:self.kErrorMessage autohide:YES];
         
         [self refreshCountLabels];
     }];
}

- (void)profileRequest
{
    [[IRNetworkClient sharedInstance] profileWithEmail:userManager.userInfo.email
                                                 token:[userManager fbToken]
                                          successBlock:^(NSDictionary* userData)
     {
         [self.scrollView.pullToRefreshView stopAnimating];
         
         //update UserInfo
         MFUserInfo *userInfo = [[dataManager getMyUserInfoInContext] configureWithDictionary:userData anotherUser:NO];
         userManager.userInfo = userInfo;
         
         self.userInfo = userInfo;
         
         self.friendsFollowItems=[self.userInfo.followingFriends mutableCopy];
         self.artistsFollowItems=[self.userInfo.followingArtists mutableCopy];
         self.followers=[self.userInfo.followed mutableCopy];
         
         [self refreshCountLabels];
         
         [self setProfile];
         [self hideTopErrorViewWithMessage:self.kConnectedMessage];
     }
    failureBlock:^(NSString* errorString)
     {
         [self.scrollView.pullToRefreshView stopAnimating];
         
         [self refreshCountLabels];
         [self showAndKeepTopErrorViewWithMessage:self.kErrorMessage autohide:YES];
     }];
}

- (void)userProfileRequest
{
    
}
//{
//    [[IRNetworkClient sharedInstance]userProfileWithUsername:self.userInfo.username
//                                                successBlock:^(NSDictionary *dictionary)
//    {
//        [self.scrollView.pullToRefreshView stopAnimating];
//         
//         MFUserInfo *userInfo=[[MFUserInfo alloc]initWithDictionary:dictionary anotherUser:YES];
//         
//         self.userInfo=userInfo;
//         
//         self.friendsFollowItems=[self.userInfo.followingFriends mutableCopy];
//         self.artistsFollowItems=[self.userInfo.followingArtists mutableCopy];
//         self.followers=[self.userInfo.followed mutableCopy];
//         
//         [self refreshCountLabels];
//         
//         [self setProfile];
//         [self hideErrorWithMessage:kConnectedMessage];
//     }
//                                                failureBlock:^(NSString *errorMessage)
//     {
//         [self.scrollView.pullToRefreshView stopAnimating];
//         
//         [self refreshCountLabels];
//         [self showAndKeepErrorWithMessage:kErrorMessage];
//     }];
//}

#pragma mark - PlayerTracksViewController - SourceDelegate

- (void)loginSpotify:(UIViewController*)loginController
{
    loginController.view.center = self.view.center;
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)loginSoundcloud:(UIViewController*)loginController
{
    [self presentViewController:loginController animated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)didTouchUpFollowButton:(id)sender
{
    self.userInfo.isFollowed=!self.userInfo.isFollowed;
    NSDictionary *proposalsDictionary=@{@"ext_id":self.userInfo.extId,@"followed":self.userInfo.isFollowed?@"true" : @"false"};
    
    [[IRNetworkClient sharedInstance]putProposalsWithEmail:userManager.userInfo.email
                                                     token:[userManager fbToken]
                                                 proposals:@[proposalsDictionary]
                                              successBlock:^{}
                                              failureBlock:^(NSString *errorMessage){
//                                                  [self showErrorMessage:errorMessage];
                                              }];
    
    
    [self.followButton setSelected:self.userInfo.isFollowed];
}

- (IBAction)didTouchUpFriendsButton:(id)sender
{
    if (!self.artistsButton.isSelected && self.friendsButton.isSelected) {
        return;
    }
    else if (self.artistsButton.isSelected && self.friendsButton.isSelected) {
        [self.friendsButton setSelected:NO];
    }
    else if (self.artistsButton.isSelected && !self.friendsButton.isSelected) {
        [self.friendsButton setSelected:YES];
    }
    else {
        [self.friendsButton setSelected:YES];
    }
    
    [self didTouchUpCancelButton:nil];
    
    if (self.friendsButton.isSelected) {
        [self setFollowingsTableView];
    }
    else {
        [self setFollowingsCollectionView];
    }
}

- (IBAction)didTouchUpArtistsButton:(id)sender
{
    if (!self.friendsButton.isSelected && self.artistsButton.isSelected) {
        return;
    }
    else if (self.friendsButton.isSelected && self.artistsButton.isSelected) {
        [self.artistsButton setSelected:NO];
    }
    else if (self.friendsButton.isSelected && !self.artistsButton.isSelected) {
        [self.artistsButton setSelected:YES];
    }
    else {
        [self.artistsButton setSelected:YES];
    }
    
    [self didTouchUpCancelButton:nil];
    
    if (self.friendsButton.isSelected) {
        [self setFollowingsTableView];
    }
    else {
        [self setFollowingsCollectionView];
    }
}

- (void)setFollowingsTableView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 219)];
    [view addSubview:self.headerView];
    [view addSubview:self.followedButtonsView];
    [self.tableView setTableHeaderView:view];
    
    [self setTabTitleLabelText];
    
    [self setTableViewHeight];
}

- (void)setFollowingsCollectionView
{
    [self.scrollView addSubview:self.headerView];
    [self.scrollView addSubview:self.followedButtonsView];
    
    [self setTabTitleLabelText];
    
    [self setCollectionViewHeight];
}

- (void)setTabTitleLabelText
{
    if (self.friendsButton.isSelected && self.artistsButton.isSelected) {
        [self.tabTitleLabel setText:[NSString stringWithFormat:@"%@ %lu",COMBINED_TITLE,(unsigned long)self.combinedFollowItems.count]];
    }
    else if (self.friendsButton.isSelected) {
        [self.tabTitleLabel setText:[NSString stringWithFormat:@"%@ %lu",FRIENDS_TITLE,(unsigned long)self.friendsFollowItems.count]];
    }
    else {
        [self.tabTitleLabel setText:[NSString stringWithFormat:@"%@ %lu",ARTISTS_TITLE,(unsigned long)self.artistsFollowItems.count]];
    }
}

#pragma mark - Search methods

- (IBAction)didTextFieldBeginEditting:(id)sender{
    
    [self.startTypingLabel setHidden:NO];
    self.isSearchMode=YES;
    self.searchResultArray=nil;
    [self.view bringSubviewToFront:self.searchingTableView];
    
    NSArray *targetArray;
    switch (self.currentIndex) {
        case 0:
            targetArray = self.tracks;
            break;
        case 1:
            if (self.friendsButton.isSelected && self.artistsButton.isSelected) {
                targetArray = self.combinedFollowItems;
            }
            else if (self.artistsButton.isSelected) {
                targetArray = self.artistsFollowItems;
            }
            else {
                targetArray = self.friendsFollowItems;
            }
            break;
        case 2:
            targetArray = self.followers;
            break;
        default:
            targetArray = [[NSArray alloc] init];
            break;
    }
    
    self.searchResultArray = targetArray;
}

- (IBAction)didTextFieldEditingChanged:(id)sender
{
    [self.startTypingLabel setHidden:YES];
    
    NSArray *targetArray;
    
    switch (self.currentIndex) {
        case 0:
            targetArray = self.tracks;
            break;
        case 1:
            if (self.friendsButton.isSelected && self.artistsButton.isSelected) {
                targetArray = self.combinedFollowItems;
            }
            else if (self.artistsButton.isSelected) {
                targetArray = self.artistsFollowItems;
            }
            else {
                targetArray = self.friendsFollowItems;
            }
            break;
        case 2:
            targetArray = self.followers;
            break;
        default:
            targetArray = [[NSArray alloc] init];
            break;
    }
    
    NSString *keywords=[self.searchTextField text];
    
    self.searchResultArray = targetArray;
    if (!self.tableView.hidden) {
        [self.tableView reloadData];
        [self setTableViewHeight];
    }
    else {
        [self.collectionView reloadData];
    }
    
    if (keywords == nil) {
        keywords = @"";
    }
    
    if ((![keywords isEqualToString:@""]) && (self.currentIndex != 0)) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", keywords];
        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[targetArray filteredArrayUsingPredicate:predicate]];

        self.searchResultArray = filteredArray;
        
        if (!self.tableView.hidden) {
            [self.tableView reloadData];
            [self setTableViewHeight];
        }
        else {
            [self.collectionView reloadData];
            [self setCollectionViewHeight];
        }
    }
    else if (![keywords isEqualToString:@""] && (self.currentIndex == 0)) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"trackName CONTAINS[c] %@", keywords];
        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[targetArray filteredArrayUsingPredicate:predicate]];
        
        self.searchResultArray = filteredArray;
        
        [self.tableView reloadData];
        [self setTableViewHeight];
    }
}

- (IBAction)didTextFieldSelectDone:(id)sender
{
    [self.searchTextField resignFirstResponder];
}

- (IBAction)didTouchUpCancelButton:(id)sender
{
    [self hideSearch];
    if (!self.tableView.hidden) {
        [self.tableView reloadData];
        [self setTableViewHeight];
    }
    else {
        [self.collectionView reloadData];
        [self setCollectionViewHeight];
    }
}

#pragma mark - UIInterfaceOrientation Methods

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if(appDelegate.isShowVideo)
    {
        return self.interfaceOrientation;
    }
    else
    {
        return UIInterfaceOrientationPortrait;
    }
}

#pragma mark - Helpers

- (void)openAnotherUserProfileWith:(NSString*)username
{
    //[self showUserProfileWithUsername:username];
}

- (void)setSize:(CGSize)size ofCollectionCell:(UICollectionViewCell*)cell
{
    CGRect frame = cell.frame;
    frame.size =size;
    cell.frame = frame;
    
    ArtistCell *artistCell=[cell.contentView.subviews lastObject];
    frame = artistCell.frame;
    frame.size =size;
    artistCell.frame = frame;
}

- (void)setFollowingsSettings
{
    [self.followedButtonsView setHidden:NO];
}

- (void)setDefalutSettings
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 179)];
    [view addSubview:self.headerView];
    [view addSubview:self.followedButtonsView];
    
    [self.tableView setTableHeaderView:view];
    
    [self.followedButtonsView setHidden:YES];
    [self.collectionView setHidden:YES];
}

- (void)setTableViewHeight
{
    [self.tableView setHidden:NO];
    [self.collectionView setHidden:YES];
    
    NSInteger itemsCount=[self tableView:nil numberOfRowsInSection:0];
    CGFloat cellHeight=[self tableView:nil heightForRowAtIndexPath:nil];

    CGRect frame=self.tableView.frame;
    frame.size.height=itemsCount*cellHeight;
    frame.size.height=self.currentIndex == 1 ? frame.size.height + 219 : frame.size.height + 179;
    
    if (((frame.size.height < CGRectGetHeight([[UIScreen mainScreen]bounds]) - 59 - (self.errorView.frame.origin.y - 9)) && (self.container.isPlayerViewHidden)) ||
        ((frame.size.height < CGRectGetHeight([[UIScreen mainScreen]bounds]) - 59 - (self.errorView.frame.origin.y - 9) - PLAYER_VIEW_HEIGHT) && (!self.container.isPlayerViewHidden))) {
        CGFloat offset = self.keyboardHeight - (CGRectGetHeight([[UIScreen mainScreen] bounds]) - 59 - frame.size.height - (self.errorView.frame.origin.y - 9));
        if (offset > 0) {
            frame.size.height = frame.size.height - offset;
        }
        [self.tableView setFrame:frame];
    }
    else {
        [self.tableView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame) - self.keyboardHeight)];
    }

    CGSize contentSize = CGSizeMake(CGRectGetWidth([[UIScreen mainScreen]bounds]),self.scrollView.frame.size.height + 1.0f);
    
    [self.scrollView setContentSize:contentSize];
}

- (void)setCollectionViewHeight
{
    
    [self.tableView setHidden:YES];
    [self.collectionView setHidden:NO];
    
    NSInteger itemsCount=[self collectionView:nil numberOfItemsInSection:0];
    itemsCount=(itemsCount/3 + (itemsCount%3 == 0 ? 0 : 1));
    
    CGRect frame=self.collectionView.frame;
    frame.size.height=itemsCount*[ArtistCell sizeOfArtistCell];
    [self.collectionView setFrame:frame];
    
    CGSize contentSize = CGSizeMake(CGRectGetWidth([[UIScreen mainScreen]bounds]),frame.origin.y+CGRectGetHeight(frame)).height > self.scrollView.frame.size.height ?
        CGSizeMake(CGRectGetWidth([[UIScreen mainScreen]bounds]),frame.origin.y+CGRectGetHeight(frame)) :
        CGSizeMake(CGRectGetWidth([[UIScreen mainScreen]bounds]),self.scrollView.frame.size.height + 1.0f);
    
    [self.scrollView setContentSize:contentSize];
}

#pragma mark - Properties Setters

- (void)setFriendsFollowItems:(NSMutableArray *)friendsFollowItems
{
    _friendsFollowItems = [friendsFollowItems mutableCopy];
}

- (void)setArtistsFollowItems:(NSMutableArray *)artistsFollowItems
{
    _artistsFollowItems = [artistsFollowItems mutableCopy];
    
    [self.collectionView reloadData];
}

- (void)setCombinedFollowItems:(NSMutableArray *)combinedFollowItems
{
    _combinedFollowItems = [combinedFollowItems mutableCopy];
    NSSortDescriptor *timelineSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timelineCount" ascending:NO];
    NSSortDescriptor *alphabetSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:timelineSortDescriptor, alphabetSortDescriptor, nil];
    _combinedFollowItems = [NSMutableArray arrayWithArray:[_combinedFollowItems sortedArrayUsingDescriptors:sortDescriptors]];
}

- (void)setUserInfo:(MFUserInfo *)userInfo
{
    _userInfo = userInfo;
    
    _friendsFollowItems = [self.userInfo.followingFriends mutableCopy];
    _artistsFollowItems = [self.userInfo.followingArtists mutableCopy];
    _followers = [self.userInfo.followed mutableCopy];
    _tracks = [self.userInfo.tracks mutableCopy];
    
    [self refreshCountLabels];
}

- (void)showShareActionSheet
{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"FB Timeline",@"FB Messenger", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self openFBTimeline];
            break;
        case 1:
            [self openFBMessenger];
            break;
        default:
            return;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    UIColor *customTitleColor = [UIColor redColor];
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            
            if(button.tag==6)
            {
                [button setTitleColor:customTitleColor forState:UIControlStateHighlighted];
                [button setTitleColor:customTitleColor forState:UIControlStateNormal];
                [button setTitleColor:customTitleColor forState:UIControlStateSelected];
            }
        }
    }
}

- (void)openFBTimeline
{
    NSURL *url = [NSURL URLWithString:self.userInfo.facebookLink];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot open facebook timeline" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openFBMessenger
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb-messenger://user-thread/%@", self.userInfo.facebookID]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot open facebook messenger" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Tap

- (IBAction)didTapAtView:(id)sender
{
    [self showShareActionSheet];
}

- (IBAction)didTapAtHeader:(id)sender
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];

    CGRect sectionRect = [self.tableView rectForHeaderInSection:0];
    sectionRect.origin.y = 0;
    sectionRect.size.height = self.tableView.frame.size.height;
    [self.tableView scrollRectToVisible:sectionRect animated:YES];
}

#pragma mark - Notifications

- (void)reachabilityChanged:(NSNotification *) notification
{
    Reachability *reachability = [notification object];
    if ([reachability isReachable]) {
        [self hideTopErrorViewWithMessage:self.kConnectedMessage];
    }
    else {
        [self showAndKeepTopErrorViewWithMessage:self.kErrorMessage  autohide:NO];
    }
}

#pragma mark - Set Reachability notifications

- (void)setReachabilityNotifications
{
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self showAndKeepTopErrorViewWithMessage:self.kErrorMessage autohide:NO];
    } else {
        [self hideTopErrorViewAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [networkReachability startNotifier];
}

#pragma mark - Observer Methods

- (void)didKeyboardShow:(NSNotification*)notification
{
    
}

- (void)willKeyboardHide:(NSNotification*)notification
{
    self.keyboardHeight = 0;
    [self setTableViewHeight];
}

- (void)willKeyboardChange:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect keyRect;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyRect];
    self.keyboardHeight = keyRect.size.height;
    [self setTableViewHeight];
}

#pragma mark - Error message methods



@end