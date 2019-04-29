//
//  MFTabBarViewController.m
//  botmusic
//
//  Created by Panda Systems on 11/13/15.
//
//

#import "MFTabBarViewController.h"
#import "MFNotificationManager.h"
#import "MFPremiumProfileViewController.h"
#import "MusicLibary.h"
#import "LoginViewController.h"
#import "MFAddTrackViewController.h"
#import "MFPlayerAnimationView.h"
#import "NDMusicControl.h"
#import "NewSearchViewController.h"
#import "MFSingleTrackViewController.h"

static NSString * const kTrackStateKeyPath = @"trackItem.trackState";

@interface MFTabBarViewController () <UITabBarControllerDelegate, MFPlayerNewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) PlayerViewController* playerViewController;
@property (nonatomic, strong) NSLayoutConstraint* playerBotConstraint;
@property (nonatomic) UIStatusBarStyle prevStatusBarStyle;
@property (nonatomic) BOOL playerShown;
@property (strong, nonatomic) MFPlayerAnimationView* playingIndicator;

@end

@implementation MFTabBarViewController{
    CGFloat _anchorPoint;
    BOOL _isDragging;
    CGFloat _lastHeight;
    CFTimeInterval _lastTime;
    double _velocity;
    CGFloat _maxSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    self.playerViewController = [storyboard instantiateViewControllerWithIdentifier:@"playerViewController"];
    self.playerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.playerViewController.pannableDelegate = self;
    [self.view addSubview:_playerViewController.view];
    [self addChildViewController:_playerViewController];
    _maxSize = MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width);
    self.playerBotConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.playerViewController.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerViewController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:_maxSize]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"view" : self.playerViewController.view}]];
    [self.view addConstraint:_playerBotConstraint];
    self.playerBotConstraint.constant = 0;
    [self.playerViewController didMoveToParentViewController:self];
    self.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePlayer) name:@"MFHidePlayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPlayer) name:@"MFShowPlayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPlayerTab) name:@"playerFirstTimeAppears" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberOfUnreadMessagesChanged) name:@"MFNumberOfUnfeadNotificationsChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUnreadMessagesNumber) name:@"MFRefreshUnreadMessagesNumber" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeedBadgeNumber) name:@"MFRefreshFeedBadgeNumber" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingTooLong)
                                                 name:[MFNotificationManager nameForNotification:MFNotificationTypeTrackLoagingTooLong] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyError)
                                                 name:@"spotifyNotPremiumError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdated:) name:@"MFUserProfileUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noInternetConnection) name:@"MFNoInternetConnection" object:nil];
    [[MFMessageManager sharedInstance] checkReachability:self];

    NSString* notificationLoadName = [MFNotificationManager nameForNotification:MFNotificationTypeCantLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cantLoadNotification)
                                                 name:notificationLoadName
                                               object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToAnonymousState) name:@"MFUserLoggedOut" object:nil];
    
    NSString *notificationUserUnauthorizedName = [MFNotificationManager nameForNotification:MFNotificationTypeUserUnauthorized];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUserUnathorizedNotification:)
                                                 name:notificationUserUnauthorizedName
                                               object:nil];
    [_playerViewController addObserver:self forKeyPath:kTrackStateKeyPath
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:nil];
    playerManager.startedPlayingFirstTime = NO;
    [MusicLibary sendArtistsToServer];
    [self refreshUnreadMessagesNumber];
    [self refreshFeedBadgeNumber];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigateToSuggestions{
#ifdef BASIC
    self.selectedIndex = 2;
#else
    self.selectedIndex = 3;
#endif
    ((NewSearchViewController*)((UINavigationController*)self.selectedViewController).viewControllers[0]).shouldNavigateToSuggestionsAfterViewLoaded = YES;
    [(UINavigationController*)self.selectedViewController popToRootViewControllerAnimated:NO];

}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    if (viewController.tabBarItem.tag == 4) {
        [(MFPremiumProfileViewController*)((UINavigationController*)viewController).viewControllers[0] reloadProfileData];
        [self refreshUnreadMessagesNumber];
        return YES;
    }

    if (viewController.tabBarItem.tag == 6) {
        [self showLogInPrompt];
        return NO;
    }

    if (viewController.tabBarItem.tag == 2) {
        [(NewSearchViewController*)((UINavigationController*)viewController).viewControllers[0] reloadData];
        return YES;
    }
    if (viewController.tabBarItem.tag == 1) {
        if (self.selectedIndex == 2) {
            [(MFAddTrackViewController*)((UINavigationController*)viewController).viewControllers[0] startRecognitionImediately];
        } else {
            [(MFAddTrackViewController*)((UINavigationController*)viewController).viewControllers[0] setShouldStartRecognizeImmediatelyAfterViewAppeared:YES];
        }
        [(UINavigationController*)viewController popToRootViewControllerAnimated:NO];
        return YES;
    }
    if (!playerManager.currentTrack && viewController.tabBarItem.tag == 3) {
        return NO;
    }
    if (viewController.tabBarItem.tag == 3) {
        [self showPlayer:0.3];
        return NO;
    }
    return YES;
}

- (void) showPlayer{
    [self showPlayer:0.3 options:UIViewAnimationOptionCurveEaseInOut];
}

- (void) hidePlayer{
    [self hidePlayer:0.3 options:UIViewAnimationOptionCurveEaseInOut];
}

- (void) showPlayer:(CGFloat)time{
    [self showPlayer:time options:UIViewAnimationOptionCurveEaseOut];
}

- (void) hidePlayer:(CGFloat)time{
    [self hidePlayer:time options:UIViewAnimationOptionCurveEaseOut];
}

- (void) showPlayer:(CGFloat)time options:(UIViewAnimationOptions)options{
    if (!_playerShown) {
        self.prevStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    }
    [self addChildViewController:_playerViewController];
    _playerShown = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollFeedToPlayingTrack" object:nil];
    AppDelegate *delegate = [NSObject appDelegate];
    [self.playerViewController configureForState:NO];
    [delegate setIsShowVideo:YES];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.view layoutIfNeeded];
    self.playerBotConstraint.constant = _maxSize;
    [UIView animateWithDuration:time delay:0.0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

- (void) hidePlayer:(CGFloat)time options:(UIViewAnimationOptions)options{
    _playerShown = NO;
    [_playerViewController removeFromParentViewController];
    AppDelegate *delegate = [NSObject appDelegate];
    [delegate setIsShowVideo:NO];
    [self.playerViewController configureForState:YES];
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:0];
    [[UIApplication sharedApplication] setStatusBarStyle:self.prevStatusBarStyle animated:YES];
    [MFNotificationManager postHidePlayerNotification];
    [self.view layoutIfNeeded];
    self.playerBotConstraint.constant = 0;
    [UIView animateWithDuration:time delay:0.0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

- (void) showPlayerTab{

//    UIFont* musicfeedFont = [UIFont fontWithName:@"Musicfeed Icons 3.0" size:34];

//    UITabBarItem* playerBarButtonItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:3];
//    [playerBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: musicfeedFont} forState:UIControlStateNormal];
//    //    [playerBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: musicfeedFont, NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateSelected];
//    playerBarButtonItem.titlePositionAdjustment = UIOffsetMake(0, -6);

//    UITabBarItem* playerBarButtonItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"player"] selectedImage:[UIImage imageNamed:@"player"]];

    UITabBarItem* playerBarButtonItem = [[UITabBarItem alloc] initWithTitle:nil image:nil selectedImage:nil];
    playerBarButtonItem.tag = 3;
    playerBarButtonItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

    UIViewController* fakePlayerVC = [[UIViewController alloc] init];
    fakePlayerVC.tabBarItem = playerBarButtonItem;
    [self setViewControllers:[self.viewControllers arrayByAddingObject:fakePlayerVC] animated:YES];
#ifdef BASIC
    self.playingIndicator = [MFPlayerAnimationView playerAnimationViewWithFrame:CGRectMake(self.view.frame.size.width*7.0/8.0 - 25.0/2.0, self.view.frame.size.height - 39, 25, 25) color:[UIColor colorWithRGBHex:0x949499]];
#else
    self.playingIndicator = [MFPlayerAnimationView playerAnimationViewWithFrame:CGRectMake(self.view.frame.size.width*9.0/10.0 - 25.0/2.0, self.view.frame.size.height - 39, 25, 25) color:[UIColor colorWithRGBHex:0x949499]];
#endif
    [self.view insertSubview:_playingIndicator belowSubview:self.playerViewController.view];

    _playingIndicator.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        _playingIndicator.alpha = 1.0;
    }];
}

//- (void)createPlayingIndicator{
//    self.playingIndicator = [MFPlayerAnimationView playerAnimationViewWithFrame:CGRectMake(self.view.frame.size.width*7.0/8.0 - 25.0/2.0, self.view.frame.size.height - 39, 25, 25) color:[UIColor colorWithRGBHex:0x949499]];
//    [self.view insertSubview:_playingIndicator belowSubview:self.playerViewController.view];
//    CGFloat spaceToLeft;
//
//#ifdef BASIC
//    spaceToLeft = self.view.frame.size.width/8.0 - 25.0/2.0;
//
//#else
//    spaceToLeft = self.view.frame.size.width/10.0 - 25.0/2.0;
//
//#endif
//
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[playingIndicator(25.0)]-spaceToLeft-|" options:0 metrics:@{@"spaceToLeft" : @(spaceToLeft)} views:@{@"playingIndicator": _playingIndicator}]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[playingIndicator(25.0)]-14-|" options:0 metrics:nil views:@{@"playingIndicator": _playingIndicator}]];
//    _playingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
//}

- (void)viewDidLayoutSubviews{
#ifdef BASIC
    self.playingIndicator.frame = CGRectMake(self.view.frame.size.width*7.0/8.0 - 25.0/2.0, self.view.frame.size.height - 39, 25, 25);
#else
    self.playingIndicator.frame = CGRectMake(self.view.frame.size.width*9.0/10.0 - 25.0/2.0, self.view.frame.size.height - 39, 25, 25);
#endif

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewPanned:(UIPanGestureRecognizer *)sender{
    CGPoint loc1 = [sender locationInView:_playerViewController.view];

    if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled) {

        CGFloat phase = _playerBotConstraint.constant/_maxSize;

        if (_playerShown) {
            if (_velocity>-150 && phase<0.95) {
                CGFloat time = ABS(phase*_maxSize/((CGFloat)_velocity));
                if (time>0.5) time = 0.5f;
                [self hidePlayer:time];
            } else {
                CGFloat time = ABS((1.0 - phase)*_maxSize/(CGFloat)_velocity);
                if (time>0.5) time = 0.5f;
                [self showPlayer:time];
            }
        } else {
            if (_velocity<150) {
                CGFloat time = ABS((1.0 - phase)*_maxSize/((CGFloat)_velocity));
                if (time>0.5) time = 0.5f;
                [self showPlayer:time];
            } else {
                CGFloat time = ABS(phase*_maxSize/(CGFloat)_velocity);
                if (time>0.5) time = 0.5f;
                [self hidePlayer:time];
            }
        }
        _velocity=0;
        _isDragging = NO;

    } else {
        CGPoint loc2 = [sender locationInView:self.view];
        if (!_isDragging) {
            _isDragging = YES;
            _anchorPoint = loc1.y;
        }
        CGFloat currentHeight = loc2.y - _anchorPoint;
        if (currentHeight<0) {
            currentHeight=0;
        }
        CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
        _velocity = (currentHeight - _lastHeight)/(currentTime - _lastTime);
        _lastTime = currentTime;
        _lastHeight = currentHeight;
        _playerBotConstraint.constant = _maxSize - currentHeight;
    }
}

- (void)refreshFeedBadgeNumber{
    if (self.viewControllers.count>1) {
        NSInteger badge = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        if (badge) {
            self.viewControllers[0].tabBarItem.badgeValue = [NSString stringWithFormat:@"%li", badge];
        } else {
            self.viewControllers[0].tabBarItem.badgeValue = nil;
        }
    }
}

- (void)refreshUnreadMessagesNumber{
    [[IRNetworkClient sharedInstance] getNumberOfUnseenNotificationsSuccessBlock:^(NSArray *array) {
        NSInteger number = [array[0] integerValue];

        //if (userManager.numberOfUnreadNotifications != number) {

            userManager.numberOfUnreadNotifications = number;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MFNumberOfUnfeadNotificationsChanged" object:nil];
        //}
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self];

    }];
}

- (void) numberOfUnreadMessagesChanged{
    if (self.viewControllers.count>1) {
        if (userManager.numberOfUnreadNotifications) {
            self.viewControllers[1].tabBarItem.badgeValue = [NSString stringWithFormat:@"%li", userManager.numberOfUnreadNotifications];
        } else {
            self.viewControllers[1].tabBarItem.badgeValue = nil;
        }
    }
}

- (void) switchToLoggedInState{
    UIStoryboard *storyboardProfile=[UIStoryboard storyboardWithName:@"Profile" bundle:nil];
    MFPremiumProfileViewController *profileVC=[storyboardProfile instantiateViewControllerWithIdentifier:@"MFPremiumProfileViewController"];
    profileVC.userInfo=userManager.userInfo;
    profileVC.container=nil;
    UINavigationController *profilenavigationVC=[[UINavigationController alloc] initWithRootViewController:profileVC];
    [profilenavigationVC setNavigationBarHidden:YES];
    profilenavigationVC.tabBarItem = self.viewControllers[1].tabBarItem;
    profilenavigationVC.tabBarItem.tag = 4;
    NSMutableArray* viewControllers = [self.viewControllers mutableCopy];
    [viewControllers replaceObjectAtIndex:1 withObject:profilenavigationVC];
    [self setViewControllers:[viewControllers copy] animated:NO];
}

- (void) switchToAnonymousState{
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginController=[storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    loginController.shownInAnonymousMode = YES;
    loginController.tabBarItem = self.viewControllers[1].tabBarItem;
    loginController.tabBarItem.tag = 6;

    NSMutableArray* viewControllers = [self.viewControllers mutableCopy];
    [viewControllers replaceObjectAtIndex:1 withObject:loginController];
    [self setViewControllers:[viewControllers copy] animated:NO];
}

- (void)didReceiveUserUnathorizedNotification:(NSNotification *)notification {
    [self showLogInPrompt];
}

- (void)showLogInPrompt{
    [[[UIAlertView alloc] initWithTitle:@"You are not logged in" message:@"Please log in to make this action" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log in", nil] show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        if (self.playerShown) {
            [self hidePlayer];
        }
        UINavigationController *navigation=(UINavigationController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginNavigationController"];
        [[[[UIApplication sharedApplication] delegate] window].rootViewController dismissViewControllerAnimated:NO completion:^{
        }];
        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:navigation];
        //[self presentViewController:navigation animated:YES completion:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    id newObject = [change objectForKey:NSKeyValueChangeNewKey];

    if ([NSNull null] == (NSNull*)newObject)
        newObject = nil;

    if ([kTrackStateKeyPath isEqualToString:keyPath]) {
        [self trackStateChanged:[newObject integerValue]];
    }
}

- (void)trackStateChanged:(NDMusicConrolStateType)state {
    switch (state) {
        case NDMusicConrolStateTypeNotStarted:
            [_playingIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypeLoading:
            [_playingIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypeFailed:
            [_playingIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypePaused:
            [_playingIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypePlaying:
            [_playingIndicator startAnimating];
            break;
        default:
            break;
    }
}

- (void)dealloc
{
    if (self.isViewLoaded) {
        [_playerViewController removeObserver:self
                                   forKeyPath:kTrackStateKeyPath
                                      context:nil];
    }
    [self.playingIndicator stopAnimating];
}

- (void) didTapAtTrackNameForTrack:(MFTrackItem *)track{
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MFSingleTrackViewController *trackInfoVC = [storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = track;
    [self hidePlayer];
    [(UINavigationController*)self.selectedViewController pushViewController:trackInfoVC animated:YES];
}

- (void)loadingTooLong{
    [[MFMessageManager sharedInstance] showProblemWithNetworkMessageInViewController:self];
}

- (void)cantLoadNotification{
    [[MFMessageManager sharedInstance] showCantLoadTrackMessageInViewController:self];
}

- (void) spotifyError{
    [[MFMessageManager sharedInstance] showSpotifyUpgradeMessageInViewController:self];
}

- (void) profileUpdated:(NSNotification*)notification{
    if (![notification.userInfo[@"avatarInstaChanging"] boolValue]) {
        [[MFMessageManager sharedInstance] showProfileUpdatedMessageInViewController:self];
    }
}

- (void) noInternetConnection{
    [[MFMessageManager sharedInstance] showNoInternetConnectionInViewController:self];
}

@end
