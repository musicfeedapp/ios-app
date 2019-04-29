//
//  MFNewProfileViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/29/15.
//
//

#import "MFNewProfileViewController.h"
#import "MFUserInfoView.h"
#import "MFProfileTabsView.h"
#import "PlaylistsViewController.h"
#import "MFFollowingViewController.h"
#import "MFFollowersViewController.h"
#import "PlaylistTracksViewController.h"
#import "MFNotificationManager.h"
#import "TrackInfoViewController.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MFNotificationsViewController.h"
#import "MFSingleTrackViewController.h"

@interface MFNewProfileViewController () <MFProfileTabsViewDelegate, MFUserInfoViewDelegate, PLaylistsViewControllerDelegate, MFScrollingChildDelegate, TrackInfoPlayDelegate>

@property (weak, nonatomic) IBOutlet UIView *mainHeaderView;

@property (nonatomic, weak) IBOutlet MFProfileTabsView* segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet MFUserInfoView *userInfoView;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underlineHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *contentContainer;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *userInfoIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileTabsHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *notificationsBadgeNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *notificationsBadgeNumberView;
@property (weak, nonatomic) IBOutlet UIView *notifView;

@property (weak, nonatomic) IBOutlet UIButton *playlistsButton;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;

@property (strong, nonatomic) PlaylistsViewController *playlistsVC;
@property (strong, nonatomic) PlaylistTracksViewController *lovedVC;
@property (strong, nonatomic) PlaylistTracksViewController *postsVC;
@property (nonatomic, assign) BOOL followStateChanged;
@property (nonatomic, assign) BOOL isMyProfile;

@property (nonatomic, assign) MFProfileTabsItem selectedTab;
@property (nonatomic) float headerHeight;
@end

@implementation MFNewProfileViewController

BOOL _showBackButton = YES;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.settingsButton.hidden = self.navigationController.viewControllers[0] != self;
    self.backButton.hidden = !self.settingsButton.hidden;
    self.followButton.hidden = YES;

    [self.followButton.layer setCornerRadius:3.0];
    [self.followButton.layer setBorderWidth:1.0];
    _followButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.segmentedControl.delegate = self;
    self.userInfoView.delegate = self;
    
    _selectedTab = MFProfileTabsItemPosts;
    //[_userInfoIndicator startAnimating];
    //_segmentedControl.hidden = YES;
    _segmentedControl.separatorHeight.constant = 1.0/[UIScreen mainScreen].scale;
    self.underlineHeightConstraint.constant = 1.0/[UIScreen mainScreen].scale;
    NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateUserFollowing];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateFollowing:)
                                                 name:notificationName
                                               object:nil];
    if ([self.userInfo isMyUserInfo]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updatePlaylistsCount)
                                                     name:@"MFPlaylistsCountDidUpdated"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberOfUnreadMessagesChanged) name:@"MFNumberOfUnfeadNotificationsChanged" object:nil];

    }
    
    NSString *notificationStatusBarTappedName = [MFNotificationManager nameForNotification:MFNotificationTypeStatusBarTapped];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didTapOnHeader:)
                                                 name:notificationStatusBarTappedName
                                               object:nil];
//    if (_isMyProfile) {
//        [self updateContainerView];
//    } else {
//        [_segmentedControl setSelectedItem:_selectedTab];
//        [self updateUserInfoFromDatabase];
//    }
    
    [_segmentedControl setSelectedItem:_selectedTab];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    playerManager.videoPlayer.currentViewController = self;
    
    [self.navigationController setNavigationBarHidden:YES];
    //[self.view bringSubviewToFront:self.mainHeaderView];
    
    [self updateUserView];
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_lovedVC) {
        self.lovedVC.scrollDelegate = nil;
    }
    if (_postsVC) {
        self.postsVC.scrollDelegate = nil;
    }
    if (_playlistsVC) {
        self.playlistsVC.scrollDelegate = nil;
    }
}


- (void)updateUserView
{
    if (_userInfo != nil) {
        [_userInfoView setProfileImage:[NSURL URLWithString:_userInfo.profileImage]];
        [_userInfoView setHeaderTitle:_userInfo.name];
        [_userInfoView showCheckmark:_userInfo.isVerified];
//        [_userInfoView showFollowButton:!_isMyProfile withState:_userInfo.isFollowed];

        [_followButton setSelected:_userInfo.isFollowed];
        if (!_followButton.selected) {
            _followButton.backgroundColor = [UIColor clearColor];
        } else {
            _followButton.backgroundColor = [UIColor whiteColor];
        }
        self.headerHeight = _isMyProfile ? 160 : 190;
        [self updatePlaylistsCount];
        [self updateFollowingCount];
        //TODO select current type
        if (_isMyProfile) {
            [_segmentedControl setIsMyProfile:_isMyProfile];
            self.notifView.hidden = NO;
            [self numberOfUnreadMessagesChanged];
        }
        
        NSURL *url = [NSURL URLWithString:self.userInfo.facebookLink];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
        }
        else {
        }
    }
}

- (void)updatePlaylistsCount
{
    [self.playlistsButton setTitle:[NSString stringWithFormat:@"%i playlists", _userInfo.playlistsCount] forState:UIControlStateNormal];
}

- (void)updateFollowingCount
{
//    MFShowFollowingState showFollowingState = ((MFFollowingViewController *)self.followingVC).showFollowingState;
//    
//    NSUInteger followingCount;
//    if (showFollowingState == MFShowArtists) {
//        followingCount = _userInfo.followingArtists.count;
//    } else if (showFollowingState == MFShowUsers) {
//        followingCount = _userInfo.followingFriends.count;
//    } else {
//        followingCount = _userInfo.followingArtists.count + _userInfo.followingFriends.count;
//    }
    
    [self.followersButton setTitle:[NSString stringWithFormat:@"%i followers", _userInfo.followedCount] forState:UIControlStateNormal];
    [self.followingButton setTitle:[NSString stringWithFormat:@"%i following", _userInfo.followingsCount] forState:UIControlStateNormal];
//    [_segmentedControl setCountForFollowing:followingCount andFollowers:_userInfo.followed.count];
}

//- (void)updateContainerView
//{
//    [_segmentedControl setSelectedItem:_selectedTab];
//    [_userInfoIndicator stopAnimating];
//    _segmentedControl.hidden = NO;
//}

- (void)showPlaylists
{
    _selectedTab = MFProfileTabsItemPlaylist;
    if (_playlistsVC == nil) {
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.playlistsVC = [storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
        self.playlistsVC.userInfo = self.userInfo;
        self.playlistsVC.topTableInset = self.headerHeight;
        self.playlistsVC.delegate = self;
        self.playlistsVC.scrollDelegate = self;
        [self addChildViewController:self.playlistsVC];
        [self.playlistsVC didMoveToParentViewController:self];
        self.playlistsVC.container = self.container;
    }
    else {
        self.playlistsVC.userInfo = self.userInfo;
        [_playlistsVC.playlistsTableView setContentOffset:CGPointMake(0, -self.headerHeight - 45)];

        [self scrollViewDidScroll:_playlistsVC.playlistsTableView];
        //[self.view bringSubviewToFront:_userInfoView];
    }
    
    [self addChildControllerSubview:self.playlistsVC];

}

- (void)showLoved
{
    _selectedTab = MFProfileTabsItemLoved;
    if (_lovedVC == nil) {
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.lovedVC = [storyboard instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
        if (self.userInfo.playlists.count>1) {
            self.lovedVC.playlist = [self.userInfo.playlists objectAtIndex:1];
        } else {
            [[IRNetworkClient sharedInstance] getPlaylistsWithEmail:userManager.userInfo.email token:userManager.fbToken extId:_userInfo.extId successBlock:^(NSArray *array) {
                
                MFUserInfo* ui = _userInfo;
                NSArray *playlists = [dataManager convertAndAddPlaylistsToDatabase:array ofUser:ui];
                
                if(_userInfo){
                    _userInfo.playlists = [NSOrderedSet orderedSetWithArray:playlists];
                }
                
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
                self.lovedVC.playlist = [self.userInfo.playlists objectAtIndex:1];
                [self.lovedVC showTracks];
                
            } failureBlock:^(NSString *errorMessage) {
                // TODO: handle error
            }];
        }
        self.lovedVC.isMyMusic = self.userInfo.isMyUserInfo;
        self.lovedVC.topTableInset = self.headerHeight;
        self.lovedVC.isDefaultPlaylist = YES;
        self.lovedVC.scrollDelegate = self;
        self.lovedVC.userExtId = self.userInfo.extId;
        [self addChildViewController:self.lovedVC];
        [self.lovedVC didMoveToParentViewController:self];
        self.lovedVC.container = self.container;
    }
    else {
        [_lovedVC.tracksTableView setContentOffset:CGPointMake(0, -self.headerHeight - 45)];
        
        [self scrollViewDidScroll:_lovedVC.tracksTableView];
        //[self.view bringSubviewToFront:_userInfoView];
    }
    
    [self addChildControllerSubview:self.lovedVC];

}

- (void)showPosts
{
    _selectedTab = MFProfileTabsItemPosts;
    if (_postsVC == nil) {
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.postsVC = [storyboard instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
        if (self.userInfo.playlists.count>1) {
            self.postsVC.playlist = [self.userInfo.playlists objectAtIndex:0];
        } else {
            [[IRNetworkClient sharedInstance] getPlaylistsWithEmail:userManager.userInfo.email token:userManager.fbToken extId:_userInfo.extId successBlock:^(NSArray *array) {
                
                MFUserInfo* ui = _userInfo;
                NSArray *playlists = [dataManager convertAndAddPlaylistsToDatabase:array ofUser:ui];
                
                if(_userInfo){
                    _userInfo.playlists = [NSOrderedSet orderedSetWithArray:playlists];
                }
                
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
                self.postsVC.playlist = [self.userInfo.playlists objectAtIndex:0];
                [self.postsVC showTracks];
                
            } failureBlock:^(NSString *errorMessage) {
                // TODO: handle error
            }];
        }
        self.postsVC.isMyMusic = self.userInfo.isMyUserInfo;
        self.postsVC.topTableInset = self.headerHeight;
        self.postsVC.isDefaultPlaylist = YES;
        self.postsVC.scrollDelegate = self;
        self.postsVC.userExtId = self.userInfo.extId;
        [self addChildViewController:self.postsVC];
        [self.postsVC didMoveToParentViewController:self];
        self.postsVC.container = self.container;
    }
    else {
        [_postsVC.tracksTableView setContentOffset:CGPointMake(0, -self.headerHeight - 45)];
        
        [self scrollViewDidScroll:_postsVC.tracksTableView];
        //[self.view bringSubviewToFront:_userInfoView];
    }
    
    [self addChildControllerSubview:self.postsVC];
    //[self.view addGestureRecognizer:self.postsVC.tracksTableView.panGestureRecognizer];
    
}

- (void)addChildControllerSubview:(UIViewController*)childVC
{
    for (UIView* view in self.contentContainer.subviews) {
        [view removeFromSuperview];
    }

    childVC.view.frame = self.contentContainer.bounds;
    [self.contentContainer addSubview:childVC.view];
}

#pragma mark - update info request

- (void)userProfileRequest
{
    if (_isMyProfile) {
        [[IRNetworkClient sharedInstance] profileWithEmail:userManager.userInfo.email token:[userManager fbToken] successBlock:^(NSDictionary *userData) {
            
            MFUserInfo *userInfo=[[dataManager getMyUserInfoInContext] configureWithDictionary:userData
                                                           anotherUser:NO];

            
            _userInfo = userInfo;
            [self updateUserView];
            [_userInfoIndicator stopAnimating];
            _segmentedControl.hidden = NO;
        } failureBlock:^(NSString *errorMessage) {
            //[_userInfoIndicator stopAnimating];
        }];
    }
    else {
        
        if (_userInfo.extId && ![_userInfo.extId isEqualToString:@""]) {
            
            [[IRNetworkClient sharedInstance] userProfileWithUsername:_userInfo.extId
                                                         successBlock:^(NSDictionary *dictionary)
             {
                 MFUserInfo *userInfo;
                 if (self.followStateChanged) {
                     BOOL followState = _userInfo.isFollowed;
                     userInfo=[dataManager convertAndAddUserInfoToDatabase:dictionary];
                     userInfo.isFollowed = followState;
                     self.followStateChanged = NO;
                 } else {
                     userInfo=[dataManager convertAndAddUserInfoToDatabase:dictionary];
                 }
                 _userInfo = userInfo;
                 self.followButton.hidden = NO;

                 //[_userInfoIndicator stopAnimating];
                 _segmentedControl.hidden = NO;
                 [self updateUserView];
             }
                                                        failureBlock:^(NSString *errorMessage)
             {
                 //[_userInfoIndicator stopAnimating];
             }];
            
        }
    }
}

-(void) updateUserInfoFromDatabase{
    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:_userInfo.extId];
    if(userInfo.playlists.count>0){
        _userInfo = userInfo;
        self.followButton.hidden = NO;
        [self updateUserView];
        //[self updateContainerView];
    }
}

#pragma mark - public API

- (void)setUserInfo:(MFUserInfo *)userInfo {
    _userInfo = userInfo;
    _isMyProfile = userInfo.isMyUserInfo;
    
    [self updateUserView];
    if (_isMyProfile) {
        //[self updateContainerView];
    }
    [self userProfileRequest];
}

- (void) reloadProfileData{
    [self userProfileRequest];
    [self.postsVC showTracks];
    [self.lovedVC showTracks];
    [self.playlistsVC downloadPlaylists];
}

#pragma mark - actions

- (IBAction)onBackButtonTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onMenuButtonTap:(id)sender {
    //[self.delegate menuButonTapped];
}

- (IBAction)onFollowButtonTap:(id)sender {
    
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (!(networkStatus == NotReachable)) {
        self.followStateChanged = YES;
        [_followButton setSelected:!_followButton.isSelected];
        if (!_followButton.selected) {
            _followButton.backgroundColor = [UIColor clearColor];
        } else {
            _followButton.backgroundColor = [UIColor whiteColor];
        }
        
        [self changeUserFollowing];
    }
}

#pragma MARK - MFProfileTabsViewDelegate

- (void)onPlaylistsButtonTap {
    [self showPlaylists];
}

- (void)onLovedButtonTap {
    [self showLoved];
}

- (void)onPostsButtonTap {
    [self showPosts];
}

#pragma mark - MFUserInfoViewDelegate methods

- (void)didTapTwitterButton
{
    // TODO: implement open twitter page
}

- (void)didTapProfilePicture
{
    [self showShareActionSheet];
}

#pragma mark - MFFollowingViewControllerDelegate methods

- (void)didSelectUserWithUserInfo:(MFUserInfo *)userInfo
{
    [self showUserProfileWithUserInfo:userInfo];
}

- (void)didChangeFollowingUserWithUserInfo:(MFUserInfo *)userInfo
{
    [self userProfileRequest];
}

- (void)didChangeShowFollowingState
{
    [self updateFollowingCount];
}

#pragma mark - PlaylistsViewControllerDelegate methods

- (void)didSelectPlaylist:(MFPlaylistItem *)playlist isDefault:(BOOL)isDefault
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlaylistTracksViewController *playlistTracksVC = [storyboard instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
    playlistTracksVC.container = self.container;
    playlistTracksVC.playlist = playlist;
    playlistTracksVC.isDefaultPlaylist = isDefault;
    playlistTracksVC.userExtId = _userInfo.extId;
    playlistTracksVC.isMyMusic = self.isMyProfile;
    playlistTracksVC.headerImage = [self headerBlurredImage];
    [self.navControllerToPush pushViewController:playlistTracksVC animated:YES];
}

- (void)shouldShowTrackInfo:(MFTrackItem *)track
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MFSingleTrackViewController *trackInfoVC = [storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = track;
    trackInfoVC.container = self.container;
    //trackInfoVC.playDelegate = self;
    
    [self.navControllerToPush pushViewController:trackInfoVC animated:YES];
}

- (void)shouldShowComments:(MFTrackItem *)track
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    CommentsViewController *commentsVC=[storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
//    [commentsVC setTrackItem:track];
//    //    [commentsVC setDelegate:self];
//    commentsVC.container = self.container;
//    
//    [self.navControllerToPush pushViewController:commentsVC animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MFSingleTrackViewController *trackInfoVC = [storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = track;
    trackInfoVC.container = self.container;

    [self.navControllerToPush pushViewController:trackInfoVC animated:YES];
}

- (void)shouldPlayTrack:(MFTrackItem *)track
{
    [self didSelectPlay:track];
}

#pragma mark - Helpers

- (void)openFBTimeline
{
    NSURL *urlApp = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", self.userInfo.facebookID]];
    if ([[UIApplication sharedApplication] canOpenURL:urlApp]) {
        [[UIApplication sharedApplication] openURL:urlApp];
    } else {
        NSURL *url = [NSURL URLWithString:self.userInfo.facebookLink];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot open facebook timeline" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
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

- (void)changeUserFollowing
{
    self.userInfo.isFollowed = !self.userInfo.isFollowed;
    NSDictionary *proposalsDictionary = @{@"ext_id" : self.userInfo.extId,
                                          @"followed" : self.userInfo.isFollowed ? @"true" : @"false"};
    if (self.userInfo.isFollowed) {
        self.userInfo.followedCount++;
    } else {
        self.userInfo.followedCount--;
    }
    [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                      token:[userManager fbToken]
                                                  proposals:@[proposalsDictionary]
                                               successBlock:^{
                                                   
                                                   [MFNotificationManager postUpdateUserFollowingNotification:_userInfo];
                                               }
                                               failureBlock:^(NSString *errorMessage){}];
}

#pragma mark - Notification Center

- (void)didUpdateFollowing:(NSNotification *)notification
{
    [self updateFollowingCount];
//    MFUserInfo *userInfo = [notification.userInfo valueForKey:@"user_info"];
//    
//    if (_isMyProfile) {
//        NSMutableArray *artists = [[_userInfo.followingArtists array] mutableCopy];
//        NSMutableArray *friends = [[_userInfo.followingFriends array] mutableCopy];
//        NSMutableArray *followers = [[_userInfo.followed array] mutableCopy];
//        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookID == %@", userInfo.facebookID];
//        NSArray *filteredArtists = [artists filteredArrayUsingPredicate:predicate];
//        NSArray *filteredFriends = [friends filteredArrayUsingPredicate:predicate];
//        NSArray *filteredFollowers = [followers filteredArrayUsingPredicate:predicate];
//        if (!userInfo.isFollowed) {
//            if (filteredArtists.count > 0) {
//                ((MFFollowItem *)filteredArtists[0]).isFollowed = NO;
//                [artists removeObject:filteredArtists[0]];
//                [_userInfo setFollowingArtists:[NSOrderedSet orderedSetWithArray: artists]];
//                if (_followingVC != nil) {
//                    ((MFFollowingViewController *)self.followingVC).artistsFollowItems = [[self.userInfo.followingArtists array] mutableCopy];
//                }
//            }
//            else if (filteredFriends.count > 0) {
//                ((MFFollowItem *)filteredFriends[0]).isFollowed = NO;
//                [friends removeObject:filteredFriends[0]];
//                [_userInfo setFollowingFriends:[NSOrderedSet orderedSetWithArray: friends]];
//                if (_followingVC != nil) {
//                    ((MFFollowingViewController *)self.followingVC).usersFollowItems = [[self.userInfo.followingFriends array] mutableCopy];
//                }
//            }
//            
//            if (filteredFollowers.count > 0) {
//                ((MFFollowItem *)filteredFollowers[0]).isFollowed = NO;
//                [_userInfo setFollowed:[NSOrderedSet orderedSetWithArray: followers]];
//                if (_followersVC != nil) {
//                    ((MFFollowersViewController *)self.followersVC).followers = [[self.userInfo.followed array] mutableCopy];
//                }
//            }
//            [self updateUserView];
//        }
//        else {
//            MFFollowItem* followItem = [MFFollowItem MR_findFirstByAttribute:@"facebookID" withValue:userInfo.facebookID];
//            if (!followItem) {
//                followItem = [MFFollowItem MR_createEntity];
//            }
//            
//            followItem.facebookID = userInfo.facebookID;
//            followItem.extId = userInfo.extId;
//            followItem.name = userInfo.name;
//            followItem.picture = userInfo.profileImage;
//            followItem.isFollowed = userInfo.isFollowed;
//            //followItem.timelineCount=userInfo.timelineCount;
//            followItem.username=userInfo.username;
//            followItem.isVerified = userInfo.isVerified;
//            
//            if (userInfo.isArtist) {
//                
//                [artists addObject:followItem];
//                [_userInfo setFollowingArtists:[NSOrderedSet orderedSetWithArray: artists]];
//                if (_followingVC != nil) {
//                    ((MFFollowingViewController *)self.followingVC).artistsFollowItems = [[self.userInfo.followingArtists array] mutableCopy];
//                }
//                
//            } else {
//                
//                [friends addObject:followItem];
//                [_userInfo setFollowingFriends:[NSOrderedSet orderedSetWithArray: friends]];
//                if (_followingVC != nil) {
//                    ((MFFollowingViewController *)self.followingVC).usersFollowItems = [[self.userInfo.followingFriends array] mutableCopy];
//                }
//            }
//            
//            if (filteredFollowers.count > 0) {
//                ((MFFollowItem *)filteredFollowers[0]).isFollowed = YES;
//                [_userInfo setFollowed:[NSOrderedSet orderedSetWithArray: followers]];
//                if (_followersVC != nil) {
//                    ((MFFollowersViewController *)self.followersVC).followers = [[self.userInfo.followed array] mutableCopy];
//                }
//            }
//            
//            [self updateUserView];
//            [self userProfileRequest];
//        }
//    }
//    else {
//        if ([self.userInfo.facebookID isEqualToString:userInfo.facebookID]) {
//            self.userInfo.isFollowed = userInfo.isFollowed;
//            NSMutableArray *followers = [[_userInfo.followed array] mutableCopy];
//            
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookID == %@", userManager.userInfo.facebookID];
//            NSArray *filteredFollowers = [followers filteredArrayUsingPredicate:predicate];
//            
//            if (!userInfo.isFollowed) {
//                if (filteredFollowers.count > 0) {
//                    [followers removeObject:filteredFollowers[0]];
//                    [_userInfo setFollowed:[NSOrderedSet orderedSetWithArray:followers]];
//                    if (_followersVC != nil) {
//                        ((MFFollowersViewController *)self.followersVC).followers = [[self.userInfo.followed array]mutableCopy];
//                    }
//                }
//                [self updateUserView];
//            }
//            else {
//                MFUserInfo* myUserInfo = userManager.userInfo;
//                MFFollowItem* followItem = [MFFollowItem MR_findFirstByAttribute:@"facebookID" withValue:myUserInfo.facebookID];
//                if (!followItem) {
//                    followItem = [MFFollowItem MR_createEntity];
//                }
//                
//                followItem.facebookID = myUserInfo.facebookID;
//                followItem.extId = myUserInfo.extId;
//                followItem.name = myUserInfo.name;
//                followItem.picture = myUserInfo.profileImage;
//                followItem.isFollowed = myUserInfo.isFollowed;
//                //followItem.timelineCount=userInfo.timelineCount;
//                followItem.username=myUserInfo.username;
//                followItem.isVerified = myUserInfo.isVerified;
//                
//                [followers addObject:followItem];
//                [_userInfo setFollowed:[NSOrderedSet orderedSetWithArray:followers]];
//                if (_followersVC != nil) {
//                    ((MFFollowersViewController *)self.followersVC).followers = [[self.userInfo.followed array]mutableCopy];
//                }
//                
//                [self updateUserView];
//                //[self userProfileRequest];
//            }
//        }
//        else {
//            //[self userProfileRequest];
//        }
//    }
}

#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender
{
//    [((PlaylistsViewController *)_playlistsVC) didTapOnHeader:sender];
//    if ([((MFFollowingViewController *)_followingVC).tableView numberOfRowsInSection:0] > 0) {
//        [((MFFollowingViewController *)_followingVC).tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
//    if ([((MFFollowersViewController *)_followersVC).tableView numberOfRowsInSection:0] > 0) {
//        [((MFFollowersViewController *)_followersVC).tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
}

#pragma mark - MFScrollingChildDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat len = - scrollView.contentOffset.y - 45.0;
    if (len<40.0) len = 40.0;
    [self.userInfoView animate:(len -40.0)/(160.0-40.0)];
    self.headerHeightConstraint.constant = len;
    

}

#pragma mark - TrackInfoPlayDelegate methods

#pragma mark - Show Action sheet

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

- (UIImage*) headerBlurredImage{
    return self.userInfoView.profileBackground.image;
}

- (IBAction)playlistsButtonTap:(id)sender {
    _selectedTab = MFProfileTabsItemPlaylist;
    [self.segmentedControl setSelectedItem:MFProfileTabsItemPlaylist];
}

- (IBAction)followingsButtonTap:(id)sender {
    MFFollowingViewController* followingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"followingViewController"];
    followingsVC.userInfo = self.userInfo;
    followingsVC.container = self.container;
    followingsVC.headerImage = self.userInfoView.profilePicture.image;
    followingsVC.isMyFollowItems = self.userInfo.isMyUserInfo;
    followingsVC.usersFollowItems = [[self.userInfo.followingFriends array] mutableCopy];
    followingsVC.artistsFollowItems = [[self.userInfo.followingArtists array] mutableCopy];
    [self.navigationController pushViewController:followingsVC animated:YES];
}

- (IBAction)followersButtonTap:(id)sender {
    MFFollowersViewController* folloversVC = [self.storyboard instantiateViewControllerWithIdentifier:@"followersViewController"];
    folloversVC.userInfo = self.userInfo;
    folloversVC.container = self.container;
    folloversVC.isMyFollowItems = self.userInfo.isMyUserInfo;
    folloversVC.headerImage = self.userInfoView.profilePicture.image;
    folloversVC.followers = [[self.userInfo.followed array] mutableCopy];
    [self.navigationController pushViewController:folloversVC animated:YES];
}

- (IBAction)notificationsButtonTapped:(id)sender {
    MFNotificationsViewController* notifVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFNotificationsViewController"];
    notifVC.headerImage = [self headerBlurredImage];
    notifVC.container = self.container;
//    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:notifVC];
//    navVC.navigationBarHidden = YES;
//    [self presentViewController:navVC animated:YES completion:nil];
    [self.navigationController pushViewController:notifVC animated:YES];
}

- (IBAction)settingsButtonTapped:(id)sender {
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *settingsVC=[storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"];
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [navVC setNavigationBarHidden:YES];
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void) numberOfUnreadMessagesChanged{
        if (userManager.numberOfUnreadNotifications) {
            self.notificationsBadgeNumberView.hidden = NO;
            self.notificationsBadgeNumberLabel.text = [NSString stringWithFormat:@"%li", userManager.numberOfUnreadNotifications];
        } else {
            self.notificationsBadgeNumberView.hidden = YES;
            self.notificationsBadgeNumberLabel.text = @"";
        }
}

@end
