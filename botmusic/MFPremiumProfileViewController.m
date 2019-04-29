//
//  MFPremiumProfileViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/12/16.
//
//

#import "MFPremiumProfileViewController.h"
#import "MFNotificationManager.h"
#import "UIImageView+WebCache_FadeIn.h"
#import "UIColor+Expanded.h"
#import "MFProfilePartViewController.h"
#import "MFTracksProfilePartViewController.h"
#import "MFFollowersProfilePartViewController.h"
#import "MFFollowingProfilePartViewController.h"
#import "MFPlaylistsProfilePartViewController.h"
#import "PlaylistTracksViewController.h"
#import "PlaylistsViewController.h"
#import "MFFollowersViewController.h"
#import "MFFollowingViewController.h"
#import "MFNotificationsViewController.h"
#import "SettingsViewController.h"
#import "UIImage+GPUBlur.h"
#import "MFOnBoardingViewController.h"
#import "MFEditProfileViewController.h"
#import "RemovedTracksViewController.h"
#import "MFAboutViewController.h"

@interface MFPremiumProfileViewController () <MFProfilePartViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIView *verifiedMark;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIView *tracksContainer;
@property (weak, nonatomic) IBOutlet UIView *playlistsContainer;
@property (weak, nonatomic) IBOutlet UIView *followersContainer;
@property (weak, nonatomic) IBOutlet UIView *followingContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tracksHeigth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playlistsHeigth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followersHeigth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followingHeigth;
@property (weak, nonatomic) IBOutlet UILabel *notificationsBadgeNumberLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeigth;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarCenterAlignment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarWidth;

@property (strong, nonatomic) MFTracksProfilePartViewController* tracksController;
@property (strong, nonatomic) MFPlaylistsProfilePartViewController* playlistsController;
@property (strong, nonatomic) MFFollowersProfilePartViewController* followersController;
@property (strong, nonatomic) MFFollowingProfilePartViewController* followingController;
@property (nonatomic, assign) BOOL followStateChanged;
@property (strong, nonatomic) MFProfilePartViewController* currentOpenedPartController;
@property (nonatomic) BOOL layoutConfigured;
@property (nonatomic) CGFloat defaultHeaderHeigth;

@property (nonatomic) BOOL isWaitingForDataToOpenTab;
@property (nonatomic, strong) MFProfilePartViewController* waitingForDataViewController;

@end

@implementation MFPremiumProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateUserFollowing];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateFollowing:)
                                                 name:notificationName
                                               object:nil];
    if ([self.userInfo isMyUserInfo]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(updatePlaylistsCount)
//                                                     name:@"MFPlaylistsCountDidUpdated"
//                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberOfUnreadMessagesChanged) name:@"MFNumberOfUnfeadNotificationsChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated:) name:@"MFUserProfileUpdated" object:nil];
        
//
    }
    _defaultHeaderHeigth = [UIScreen mainScreen].bounds.size.height - 224 - 43 - 43 - 43 - 20 - self.tabBarController.tabBar.frame.size.height;
    CGFloat i6headerHeight = 667 - 224 - 43 - 43 - 43 - 20 - self.tabBarController.tabBar.frame.size.height;
    if (_defaultHeaderHeigth<114.0) {
        _defaultHeaderHeigth = 114.0;
    }

    if (_defaultHeaderHeigth>i6headerHeight) {
        _defaultHeaderHeigth = i6headerHeight;
    }

    [self setUpParts];
    [self updateUserViewWithCustomAvatar:nil];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width/2.0;
    [self.view addGestureRecognizer:self.scrollView.panGestureRecognizer];

    self.scrollView.delegate = self;

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!_layoutConfigured) {
        _layoutConfigured = YES;

        self.headerHeigth.constant = _defaultHeaderHeigth;
        self.scrollView.contentInset = UIEdgeInsetsMake(20.0+_defaultHeaderHeigth, 0, self.tabBarController.tabBar.frame.size.height, 0);
        self.scrollView.contentOffset = CGPointMake(0, -self.scrollView.contentInset.top);
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)setUpParts{
    self.tracksController = [[MFTracksProfilePartViewController alloc] initWithNibName:@"MFProfilePartViewController" bundle:nil];
    self.tracksController.userInfo = self.userInfo;
    self.tracksController.title = NSLocalizedString(@"Posts", nil);
    [self.tracksContainer addSubview:self.tracksController.view];
    [self.tracksContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"view" : self.tracksController.view}]];
    [self.tracksContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"view" : self.tracksController.view}]];
    self.tracksController.view.translatesAutoresizingMaskIntoConstraints = NO;


    self.playlistsController = [[MFPlaylistsProfilePartViewController alloc] initWithNibName:@"MFProfilePartViewController" bundle:nil];
    self.playlistsController.userInfo = self.userInfo;
    self.playlistsController.title = NSLocalizedString(@"Playlists", nil);
    [self.playlistsContainer addSubview:self.playlistsController.view];
    [self.playlistsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"view" : self.playlistsController.view}]];
    [self.playlistsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"view" : self.playlistsController.view}]];
    self.playlistsController.view.translatesAutoresizingMaskIntoConstraints = NO;


    self.followersController = [[MFFollowersProfilePartViewController alloc] initWithNibName:@"MFProfilePartViewController" bundle:nil];
    self.followersController.userInfo = self.userInfo;
    self.followersController.title = NSLocalizedString(@"Followers", nil);
    [self.followersContainer addSubview:self.followersController.view];
    [self.followersContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"view" : self.followersController.view}]];
    [self.followersContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"view" : self.followersController.view}]];
    self.followersController.view.translatesAutoresizingMaskIntoConstraints = NO;


    self.followingController = [[MFFollowingProfilePartViewController alloc] initWithNibName:@"MFProfilePartViewController" bundle:nil];
    self.followingController.userInfo = self.userInfo;
    self.followingController.title = NSLocalizedString(@"Following", nil);
    [self.followingContainer addSubview:self.followingController.view];
    [self.followingContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"view" : self.followingController.view}]];
    [self.followingContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"view" : self.followingController.view}]];
    self.followingController.view.translatesAutoresizingMaskIntoConstraints = NO;


    self.tracksController.delegate = self;
    self.playlistsController.delegate = self;
    self.followersController.delegate = self;
    self.followingController.delegate = self;

    [self.tracksController applyClosedState];
    [self.playlistsController applyClosedState];
    [self.followersController applyClosedState];
    [self.followingController applyClosedState];

    self.isWaitingForDataToOpenTab = YES;
    self.waitingForDataViewController = nil;
    [self checkControllerWithNextWaitProirityAnimated:NO];

}

- (void) checkControllerWithNextWaitProirityAnimated:(BOOL)animated{
    if (_userInfo.isMyUserInfo) {

        if(!self.waitingForDataViewController){
            self.waitingForDataViewController = self.followingController;
        } else if (self.waitingForDataViewController == self.followingController){
            self.waitingForDataViewController = self.tracksController;
        } else if (self.waitingForDataViewController == self.tracksController){
            self.waitingForDataViewController = self.followersController;
        } else if(self.waitingForDataViewController == self.followersController){
            self.waitingForDataViewController = self.playlistsController;
        } else {
            self.waitingForDataViewController = nil;
            return;
        }

    } else {

        if(!self.waitingForDataViewController){
            self.waitingForDataViewController = self.tracksController;
        } else if (self.waitingForDataViewController == self.tracksController){
            self.waitingForDataViewController = self.followingController;
        } else if (self.waitingForDataViewController == self.followingController){
            self.waitingForDataViewController = self.followersController;
        } else if(self.waitingForDataViewController == self.followersController){
            self.waitingForDataViewController = self.playlistsController;
        } else {
            self.waitingForDataViewController = nil;
            return;
        }

    }

    if (self.waitingForDataViewController.objects.count > 0) {
        [self showTabWithController:self.waitingForDataViewController animated:animated];
        self.isWaitingForDataToOpenTab = NO;
    } else {
        if (_waitingForDataViewController.isLoadedObjects) {
            [self checkControllerWithNextWaitProirityAnimated:animated];
        } else {

        }
    }
}

- (void) profilePartViewControllerLoadedObjects:(MFProfilePartViewController *)controller{
    if (controller == _waitingForDataViewController && self.isWaitingForDataToOpenTab) {

        if (self.waitingForDataViewController.objects.count > 0) {
            [self showTabWithController:self.waitingForDataViewController animated:YES];
            self.isWaitingForDataToOpenTab = NO;
        } else {
            [self checkControllerWithNextWaitProirityAnimated:YES];
        }

    }
}

- (void)profilePartViewControllerDidTapAtHeader:(MFProfilePartViewController *)controller{
    self.isWaitingForDataToOpenTab = NO;

    if (controller == self.currentOpenedPartController) {
        [self profilePartViewControllerDidTapAtMore:controller];
    } else {
        [self showTabWithController:controller animated:YES];
    }

}

- (void) showTabWithController:(MFProfilePartViewController *)controller animated:(BOOL)animated{


    if (animated) {
        [self.view layoutIfNeeded];
        self.tracksHeigth.constant = 43;
        self.playlistsHeigth.constant = 43;
        self.followersHeigth.constant = 43;
        self.followingHeigth.constant = 43;
        [UIView animateWithDuration:0.3 animations:^{
            [self.currentOpenedPartController applyClosedState];

            if (controller == self.tracksController) {
                [self.tracksController applyOpenedState];
                self.tracksHeigth.constant = 224;
            } else if (controller == self.playlistsController) {
                [self.playlistsController applyOpenedState];
                self.playlistsHeigth.constant = 224;
            } else if (controller == self.followersController) {
                [self.followersController applyOpenedState];
                self.followersHeigth.constant = 224;
            } else if (controller == self.followingController) {
                [self.followingController applyOpenedState];
                self.followingHeigth.constant = 224;
            }

            [self.view layoutIfNeeded];
            
        }];
    } else {
        self.tracksHeigth.constant = 43;
        self.playlistsHeigth.constant = 43;
        self.followersHeigth.constant = 43;
        self.followingHeigth.constant = 43;
        [self.currentOpenedPartController applyClosedState];

        if (controller == self.tracksController) {
            [self.tracksController applyOpenedState];
            self.tracksHeigth.constant = 224;
        } else if (controller == self.playlistsController) {
            [self.playlistsController applyOpenedState];
            self.playlistsHeigth.constant = 224;
        } else if (controller == self.followersController) {
            [self.followersController applyOpenedState];
            self.followersHeigth.constant = 224;
        } else if (controller == self.followingController) {
            [self.followingController applyOpenedState];
            self.followingHeigth.constant = 224;
        }


    }

    self.currentOpenedPartController = controller;
}

- (void) profilePartViewController:(MFProfilePartViewController *)controller didSelectItem:(id)object{
    if ([object isKindOfClass:[MFTrackItem class]]) {
        [self shouldOpenTrackInfo:object];
    } else if ([object isKindOfClass:[MFFollowItem class]]){
        MFFollowItem *followItem = object;
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:followItem.extId];
        userInfo.username = followItem.username;
        userInfo.profileImage = [followItem.picture stringByReplacingOccurrencesOfString:@" " withString:@""];
        userInfo.facebookID = followItem.facebookID;
        userInfo.extId = followItem.extId;
        userInfo.name = followItem.name;
        [self showUserProfileWithUserInfo:userInfo];
    } else if ([object isKindOfClass:[MFPlaylistItem class]]){
        PlaylistTracksViewController *playlistTracksVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
        playlistTracksVC.playlist = object;
        if (!self.userInfo.isMyUserInfo) {
            playlistTracksVC.shouldShowOwnerAvatar = YES;
        }
        playlistTracksVC.isDefaultPlaylist = NO;
        playlistTracksVC.userExtId = self.userInfo.extId;
        playlistTracksVC.isMyMusic = self.userInfo.isMyUserInfo;

        [self.navControllerToPush pushViewController:playlistTracksVC animated:YES];
    }
}

- (void)userInfoUpdated:(NSNotification*)notification{

    [self updateUserViewWithCustomAvatar:notification.userInfo[@"avatar"]];

}

- (void)updateUserViewWithCustomAvatar:(UIImage*)image
{
    if (image) {

        _avatarImageView.image = image;
        _backgroundImageView.image = [image gpuBlurApplyLightEffect];
        [_avatarImageView hideInitialsLabel];

    } else {

        [_avatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:_userInfo.profileImage] name:_userInfo.name];

        [_backgroundImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:_userInfo.profileImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            UIImage* imageBlurred;
            if (image) {
                imageBlurred = [image gpuBlurApplyLightEffect];
            } else {
                imageBlurred = [[UIImage imageNamed:@"defaultAvatar.jpg"] gpuBlurApplyLightEffect];
            }
            _backgroundImageView.image = imageBlurred;
        }];

    }

    _nameLabel.text = _userInfo.name;
    _verifiedMark.hidden = !_userInfo.isVerified;

    _followButton.hidden = _userInfo.isMyUserInfo || !_userInfo.isUserInfoFullyLoaded;
    _settingsButton.hidden = !_userInfo.isMyUserInfo;

    if (_userInfo.isUserInfoFullyLoaded && _userInfo.isFollowed) {
        [self selectFollowButtonAnimated:NO];
    } else if (_userInfo.isUserInfoFullyLoaded && !_userInfo.isFollowed){
        [self deselectFollowButtonAnimated:NO];
    }
    if (self.navigationController.viewControllers[0] == self) {
        self.backButton.hidden = YES;
        if (_userInfo.isMyUserInfo) {
            self.notificationView.hidden = NO;
            [self numberOfUnreadMessagesChanged];
        } else {
            self.notificationView.hidden = YES;
        }
    } else {
        self.backButton.hidden = NO;
        self.notificationView.hidden = YES;
    }

}

- (void) selectFollowButtonAnimated:(BOOL)animated{
    if (animated){
        [_followButton setTitle:NSLocalizedString(@"UNFOLLOW", nil) forState:UIControlStateNormal];
    } else {
        [UIView setAnimationsEnabled:NO];
        [_followButton layoutIfNeeded];
        [_followButton setTitle:NSLocalizedString(@"UNFOLLOW", nil) forState:UIControlStateNormal];
        [_followButton layoutIfNeeded];
        [UIView setAnimationsEnabled:YES];
    }
    _followButton.backgroundColor = [UIColor colorWithRGBHex:0x85858C];
}

- (void) deselectFollowButtonAnimated:(BOOL)animated{
    if (animated){
        [_followButton setTitle:NSLocalizedString(@"FOLLOW", nil) forState:UIControlStateNormal];
    } else {
        [UIView setAnimationsEnabled:NO];
        [_followButton layoutIfNeeded];
        [_followButton setTitle:NSLocalizedString(@"FOLLOW", nil) forState:UIControlStateNormal];
        [_followButton layoutIfNeeded];
        [UIView setAnimationsEnabled:YES];
    }
    _followButton.backgroundColor = [UIColor colorWithRGBHex:0x0077FF];
}

- (void)setUserInfo:(MFUserInfo *)userInfo {
    _userInfo = userInfo;

    [self updateUserViewWithCustomAvatar:nil];

    [self reloadProfileData];

}

- (void) reloadProfileData{
    [self userProfileRequest];
    [self.tracksController reloadData];
    [self.playlistsController reloadData];
    [self.followersController reloadData];
    [self.followingController reloadData];
}

- (void)userProfileRequest
{
    if (_userInfo.isMyUserInfo) {
        [[IRNetworkClient sharedInstance] profileWithEmail:userManager.userInfo.email token:[userManager fbToken] successBlock:^(NSDictionary *userData) {
            if ([userData[@"is_facebook_expired"] boolValue]) {
                [self refreshAccessToken];
            }
            MFUserInfo *userInfo=[[dataManager getMyUserInfoInContext] configureWithDictionary:userData
                                                                                   anotherUser:NO];


            _userInfo = userInfo;
            [self updateUserViewWithCustomAvatar:nil];
        } failureBlock:^(NSString *errorMessage) {
            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

        }];
    } else {

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

                 [self updateUserViewWithCustomAvatar:nil];
             }
                                                         failureBlock:^(NSString *errorMessage)
             {
                 [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

             }];
            
        }
    }
}

- (IBAction)followButtonTapped:(id)sender {
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (!(networkStatus == NotReachable)) {
        self.followStateChanged = YES;

        BOOL followed = !_userInfo.isFollowed;

        _userInfo.isFollowed = followed;
        if (_userInfo.isUserInfoFullyLoaded && _userInfo.isFollowed) {
            [self selectFollowButtonAnimated:NO];
        } else if (_userInfo.isUserInfoFullyLoaded && !_userInfo.isFollowed){
            [self deselectFollowButtonAnimated:NO];
        }

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
                                                   failureBlock:^(NSString *errorMessage){
                                                       [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

                                                       _userInfo.isFollowed = !followed;
                                                       if (_userInfo.isUserInfoFullyLoaded && _userInfo.isFollowed) {
                                                           [self selectFollowButtonAnimated:NO];
                                                       } else if (_userInfo.isUserInfoFullyLoaded && !_userInfo.isFollowed){
                                                           [self deselectFollowButtonAnimated:NO];
                                                       }
                                                   }];
    }
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didUpdateFollowing:(NSNotification *)notification
{
    MFUserInfo* ui = notification.userInfo[@"user_info"];
    if (self.userInfo == ui) {
        if (ui.isFollowed) {
            [self selectFollowButtonAnimated:NO];
        } else {
            [self deselectFollowButtonAnimated:YES];
        }
    }
}

- (void) profilePartViewControllerDidTapAtMore:(MFProfilePartViewController *)controller{
    if (controller == self.tracksController) {
        if (self.userInfo.playlists.count>1) {
            UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PlaylistTracksViewController* postsVC = [storyboard instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
            postsVC.playlist = [self.userInfo.playlists objectAtIndex:0];
            postsVC.isMyMusic = self.userInfo.isMyUserInfo;
            postsVC.isDefaultPlaylist = YES;
            postsVC.userExtId = self.userInfo.extId;
            [self.navigationController pushViewController:postsVC animated:YES];
        }
    } else if (controller == self.playlistsController){
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PlaylistsViewController* playlistsVC = [storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
        playlistsVC.userInfo = self.userInfo;
        [self.navigationController pushViewController:playlistsVC animated:YES];
    } else if (controller == self.followersController){
        MFFollowersViewController* folloversVC = [self.storyboard instantiateViewControllerWithIdentifier:@"followersViewController"];
        folloversVC.userInfo = self.userInfo;
        folloversVC.isMyFollowItems = self.userInfo.isMyUserInfo;
        [self.navigationController pushViewController:folloversVC animated:YES];
    } else if (controller == self.followingController){
        MFFollowingViewController* followingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"followingViewController"];
        followingsVC.userInfo = self.userInfo;
        followingsVC.isMyFollowItems = self.userInfo.isMyUserInfo;

        [self.navigationController pushViewController:followingsVC animated:YES];
    }
}

- (IBAction)settingsButtonTapped:(id)sender {

    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Find Friends" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showFindFriends];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Edit Profile" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showEditProfile];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"More..." style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showSettings];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }]];

    [self presentViewController:alertController animated:YES completion:nil];

}

- (void) showSettings{
//    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *settingsVC=[storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"];
//
//    CATransition* transition = [CATransition animation];
//    transition.duration = 0.25;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//    transition.type = kCATransitionMoveIn; //kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade
//    transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
//
//    [[self navigationController] pushViewController:settingsVC animated:NO];

    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Genres" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showGenres];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Removed Tracks" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self goToRemovedTracks];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"About" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showAbout];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Sign Out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self logout];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (IBAction)notifButtonTapped:(id)sender {
    MFNotificationsViewController* notifVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFNotificationsViewController"];

    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionMoveIn; //kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];

    [self.navigationController pushViewController:notifVC animated:NO];
}

- (void) numberOfUnreadMessagesChanged{
    if (userManager.numberOfUnreadNotifications) {
        [self.notificationsButton setTitle:@"" forState:UIControlStateNormal];
        [self.notificationsButton setTitleColor:[UIColor colorWithRGBHex:0xFF1A57] forState:UIControlStateNormal];
        self.notificationsBadgeNumberLabel.hidden = NO;
        self.notificationsBadgeNumberLabel.text = [NSString stringWithFormat:@"%li", userManager.numberOfUnreadNotifications];
    } else {
        [self.notificationsButton setTitle:@"" forState:UIControlStateNormal];
        [self.notificationsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.notificationsBadgeNumberLabel.hidden = YES;
        self.notificationsBadgeNumberLabel.text = @"";
    }
}

- (IBAction)avatarTapped:(id)sender {
    if (self.userInfo.isMyUserInfo) {
        [self editPhoto];
    } else {
        if (self.userInfo.facebookLink.length){
            UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"FB Timeline",@"FB Messenger", nil];
            [actionSheet showInView:self.view];
        }
    }
}

- (void)editPhoto {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Update profile picture" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takePhoto];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectPhoto];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Import from Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self removeAvatar];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)takePhoto {

    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self presentViewController:picker animated:YES completion:^{
    }];
}

- (void)selectPhoto {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage* avatar = nil;
    avatar = image;
    CGFloat scale = 200.0/MIN(avatar.size.width, avatar.size.height);
    CGSize newsize = CGSizeMake(avatar.size.width*scale, avatar.size.height*scale);
    avatar = [self imageWithImage:avatar scaledToSize:newsize];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFUserProfileUpdated" object:nil userInfo:@{@"avatar":avatar, @"avatarInstaChanging":@(YES) }];

    [[IRNetworkClient sharedInstance] updateProfile:@{} avatar:avatar successBlock:^(NSDictionary *dictionary) {

        self.userInfo.profileImage = [dictionary objectForKey:@"profile_image"];
        UIImageView* dummy = [[UIImageView alloc] init];
        [dummy sd_setImageWithURL:[NSURL URLWithString:self.userInfo.profileImage]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MFUserProfileUpdated" object:nil userInfo:@{@"avatar":avatar}];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

        //[[[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }];
}

- (void)removeAvatar{
    NSMutableDictionary* dictionary = [@{ @"remove_avatar": @(YES),} mutableCopy];

    [[IRNetworkClient sharedInstance] updateProfile:dictionary avatar:nil successBlock:^(NSDictionary *dictionary) {
        if ([[dictionary objectForKey:@"profile_image"] isKindOfClass:[NSString class]]) {
            self.userInfo.profileImage = [dictionary objectForKey:@"profile_image"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MFUserProfileUpdated" object:nil];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
        //[[[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

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

- (void)openFBTimeline
{
    NSURL *urlApp = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", self.userInfo.facebookID]];
    //NSURL *urlApp = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", self.userInfo.facebookID]];
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

- (void) showFindFriends{
    UIStoryboard* st = [UIStoryboard storyboardWithName:@"OnBoarding" bundle:nil];
    MFOnBoardingViewController* vc = [st instantiateViewControllerWithIdentifier:@"MFOnBoardingViewController"];
    vc.presentationMode = MFOnBoardingViewControllerPresentationModeFollow;
    vc.isShownFromBottom = YES;

    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionMoveIn; //kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];

    [self.navigationController pushViewController:vc animated:NO];
}

- (void) showEditProfile{
    UIStoryboard* st = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    MFEditProfileViewController *nvc = [st instantiateViewControllerWithIdentifier:@"MFEditProfileViewController"];
    nvc.isShownFromBottom = YES;

    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionMoveIn; //kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];

    [self.navigationController pushViewController:nvc animated:NO];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat heigth = - scrollView.contentOffset.y - 20.0;

    if (heigth < 50) {
        heigth = 50;
    }
    CGFloat alpha = (heigth - 90.0)/(_defaultHeaderHeigth - 90.0);
    CGFloat phase = heigth/_defaultHeaderHeigth;

    CGFloat avatarSpeed = 40.0*_defaultHeaderHeigth/146.0;
    _avatarCenterAlignment.constant = - 18 + avatarSpeed*(phase-1.0);
    _avatarImageView.alpha = alpha;
    _nameLabel.alpha = alpha;
    _verifiedMark.alpha = alpha;

//    CGFloat imageScale = 1.0 + 0.5*(heigth/_defaultHeaderHeigth - 1.0);
//    if (imageScale<1.0) {
//        imageScale = 1.0;
//    }
//    if (imageScale>2.0) {
//        imageScale = 2.0;
//    }
//    _avatarWidth.constant = imageScale*64.0;
//    _avatarImageView.layer.cornerRadius = imageScale*64.0/2.0;

    _headerHeigth.constant = heigth;

}

- (void)showGenres{

    UIStoryboard* st = [UIStoryboard storyboardWithName:@"OnBoarding" bundle:nil];
    MFOnBoardingViewController* vc = [st instantiateViewControllerWithIdentifier:@"MFOnBoardingViewController"];
    vc.presentationMode = MFOnBoardingViewControllerPresentationModeSelectingGenres;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) goToRemovedTracks{
    UIStoryboard* st = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    RemovedTracksViewController *removedTracksVC = [st instantiateViewControllerWithIdentifier:@"removedTracksViewController"];
    [self.navigationController pushViewController:removedTracksVC animated:YES];
}

- (void) showAbout{
    UIStoryboard* st = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    MFAboutViewController *aboutVC = [st instantiateViewControllerWithIdentifier:@"MFAboutViewController"];
    [self.navigationController pushViewController:aboutVC animated:YES];
}

- (void)logout
{
    [userManager logout];
    UIStoryboard* st = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UINavigationController *navigation= [st instantiateViewControllerWithIdentifier:@"loginNavigationController"];
    [[[[UIApplication sharedApplication] delegate] window].rootViewController dismissViewControllerAnimated:NO completion:^{
    }];
    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:navigation];

}

- (void) refreshAccessToken{
    if ([FBSDKAccessToken currentAccessToken]) {
        [[IRNetworkClient sharedInstance] refreshFacebookToken:[FBSDKAccessToken currentAccessToken].tokenString
                                                expirationDate:[FBSDKAccessToken currentAccessToken].expirationDate
                                                  successBlock:^(NSDictionary *dictionary) {
        } failureBlock:^(NSString *errorMessage) {
                    NSLog(errorMessage);
        }];
    }
}
@end
