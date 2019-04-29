//
//  AppDelegate.m
//  botmusic
//

#import <AFHTTPRequestOperationLogger/AFHTTPRequestOperationLogger.h>
#import <DCIntrospect-ARC/DCIntrospect.h>
#import "MFNotificationManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Mixpanel/Mixpanel.h>
#import <Parse/Parse.h>
#import "MFMigrationManager.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MFDeepLinkingManager.h"
#import "JLNotificationPermission.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PSRateManager.h"


NSString * const SoundCloudID = @"7c8ddbf46678a7f03b1c064e257e9632";
NSString * const SoundCloudSecret = @"c54fe000da6bcc731cc658d78704c783";


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
    ];
    // Add any custom logic here.
    return handled;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [MagicalRecord setupAutoMigratingCoreDataStack];

    // Override point for customization after application launch.
    NSLogExt(@"Testflight session started");

    //start crashlitycs
    [Fabric with:@[[Crashlytics class]]];


    [SCSoundCloud  setClientID:SoundCloudID
                        secret:SoundCloudSecret
                   redirectURL:[NSURL URLWithString:@"botmusic://oauth2"]];
    

    [[AFHTTPRequestOperationLogger sharedLogger] startLogging];

    // AFNetworking activity indicator on the status bar
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    playerManager;
    [MFMessageManager sharedInstance];


    [self renumberBadgesOfPendingNotifications:0];
    
    [Mixpanel sharedInstanceWithToken:@"7b4469cacf7c14a45ca12e15ec19158e"];
    
    [[Mixpanel sharedInstance] track:@"Application started"];
    
    [[Mixpanel sharedInstance] timeEvent:@"Time spent in app"];
    
    [MFMigrationManager performMigration];
    
    //TODO: Change bundle ID
    [PSRateManager sharedInstance].appStoreID = @"953895783";
    

    // Setup Parse
    [Parse setApplicationId:@"myBFEJGswnzSaJRwLkAzhAf3FinZmNURf5BnOFd7"
                  clientKey:@"ZNMn7Oh59sLuLJIwwdIFYtreMlE8CIT1NdV94uk7"];
    // Register for Push Notitications
    
    [[JLNotificationPermission sharedInstance] authorizeWithTitle:nil message:NSLocalizedString(@"Would you like to be notified when your friends join?", nil) cancelTitle:NSLocalizedString(@"No Thanks", nil) grantTitle:NSLocalizedString(@"Notify Me", nil) completion:^(NSString *deviceID, NSError *error) {
    }];
    
    //TODO remove this needed to temp fix for spotify internal crash
    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"spotifyLoginErrorNotPremium"];
    
    NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
    NSNumber* number = [userDefauls objectForKey:@"showUnfollowPromps"];
    
    if (!number) {
        [userDefauls setObject:@1 forKey:@"showUnfollowPromps"];
        [userDefauls synchronize];
    }
    
    [MFDeepLinkingManager setPushNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    
    NSString* currVersion = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString* oldVersion = [userDefauls objectForKey:@"MFOldVersionString"];
    if (![oldVersion isEqualToString:currVersion]) {
        [userDefauls setObject:currVersion forKey:@"MFOldVersionString"];
        [userDefauls setObject:@1 forKey:@"showUnfollowPromps"];
        [userDefauls synchronize];
    }

    [[MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand addTarget:self action:@selector(remoteNextTrackCommandReceived)];
    [[MPRemoteCommandCenter sharedCommandCenter].previousTrackCommand addTarget:self action:@selector(remotePrevTrackCommandReceived)];
    [[MPRemoteCommandCenter sharedCommandCenter].togglePlayPauseCommand addTarget:self action:@selector(remotePrevTrackCommandReceived)];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[Mixpanel sharedInstance] track:@"Time spent in app"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
    [settingsManager saveSettings];
    
    if (playerManager.playing) {
        [playerManager performSelector:@selector(resumeTrack) withObject:nil afterDelay:0.1];
        [playerManager performSelector:@selector(resumeTrack) withObject:nil afterDelay:0.2];
        [playerManager performSelector:@selector(resumeTrack) withObject:nil afterDelay:0.4];
        [playerManager performSelector:@selector(resumeTrack) withObject:nil afterDelay:0.6];

    }

    // Stop to observe user info changing
    NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUserInfoUpdated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:notificationName
                                                  object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[Mixpanel sharedInstance] timeEvent:@"Time spent in app"];
    
    [FBSDKAppEvents activateApp];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    // Observe user info changing
    NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUserInfoUpdated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateUserInfo:)
                                                 name:notificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFRefreshUnreadMessagesNumber" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFRefreshFeedBadgeNumber" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[Mixpanel sharedInstance] track:@"Time spent in app"];

    [MagicalRecord cleanUp];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)remoteNextTrackCommandReceived{
//    [playerManager setIsManualTrackSwitching:YES];
//    [playerManager nextTrack];
}

- (void)remotePrevTrackCommandReceived{
//    [playerManager setIsManualTrackSwitching:YES];
//    [playerManager prevTrack];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype)
    {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            if (playerManager.currentTrack.trackState == IRTrackItemStatePaused)
            {
                [playerManager resumeTrack];
            }
            else
            {
                [playerManager pauseTrack];
            }
            break;
        case UIEventSubtypeRemoteControlPlay:
            [playerManager resumeTrack];
            break;
        case UIEventSubtypeRemoteControlPause:
            [playerManager pauseTrack];
            break;
        case UIEventSubtypeRemoteControlStop:
            [playerManager stopTrack];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [playerManager setIsManualTrackSwitching:YES];
            [playerManager prevTrack];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [playerManager setIsManualTrackSwitching:YES];
            [playerManager nextTrack];
            break;
        default:
            break;
    }
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.isShowVideo)
    {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
        //return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - EBNotifierDelegate methods

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}
#endif

- (void)renumberBadgesOfPendingNotifications:(NSUInteger)number
{
    [MFNotificationManager postUpdateBadgeNumberNotification:[NSNumber numberWithUnsignedInteger:number]];
    // clear the badge on the icon
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
    
    // first get a copy of all pending notifications (unfortunately you cannot 'modify' a pending notification)
    NSArray *pendingNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    // if there are any pending notifications -> adjust their badge number
    if (pendingNotifications.count != 0)
    {
        // clear all pending notifications
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        for (UILocalNotification *notification in pendingNotifications)
        {
            // modify the badgeNumber
            notification.applicationIconBadgeNumber = number;
            
            // schedule 'again'
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
    else {
        // Create the UILocalNotification
        UILocalNotification *myNotification = [[UILocalNotification alloc] init];
        myNotification.applicationIconBadgeNumber = 1;
        myNotification.timeZone = [NSTimeZone defaultTimeZone];
        myNotification.repeatInterval = NSMinuteCalendarUnit;
        myNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:30];
        [[UIApplication sharedApplication] scheduleLocalNotification:myNotification];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
}

#pragma mark - Status bar tap tracking

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    if (CGRectContainsPoint(statusBarFrame, location)) {
        [self statusBarTouchedAction];
    }
}

- (void)statusBarTouchedAction {
    [MFNotificationManager postStatusBarTappedNotification];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (userInfo[@"count"]) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[userInfo[@"count"] integerValue]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFRefreshUnreadMessagesNumber" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFRefreshFeedBadgeNumber" object:nil];

    UIApplicationState astate = application.applicationState;
    if (astate != UIApplicationStateActive) {
        [MFDeepLinkingManager setPushNotification:userInfo];
        [MFDeepLinkingManager performDeepLinking];
    }
    
}

#pragma mark - Notification Center

- (void)didUpdateUserInfo:(NSNotification *)notification {
    MFUserInfo *userInfo = notification.userInfo[@"user_info"];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:userInfo.extId forKey:@"userExtId"];
    [currentInstallation saveInBackground];
}

- (UIViewController *)topViewController{
    return [self topViewController:[[[UIApplication sharedApplication] delegate] window].rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {

        if ([rootViewController isKindOfClass:[UITabBarController class]]) {
            return [self topViewController:((UITabBarController*)rootViewController).selectedViewController];
        }

        if ([rootViewController isKindOfClass:[UINavigationController class]]) {
            return [self topViewController:((UINavigationController*)rootViewController).topViewController];
        }

        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}
@end
