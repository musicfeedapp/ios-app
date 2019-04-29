//
//  SettingsViewController.m
//  botmusic
//
//  Created by Supervisor on 19.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "SettingsViewController.h"
#import "CBContainerVCToFixStatusBarOverlap.h"
#import <UIColor+Expanded.h>
#import "RemovedTracksViewController.h"
#import "MusicLibary.h"
#import "MFSettingsContainerViewController.h"
#import "MFFollowViewController.h"
#import "MFSelectingGenresViewController.h"
#import "MFOnBoardingViewController.h"
#import "MFAboutViewController.h"
#import "MFTabBarViewController.h"

static NSString * const kFacebookAppLink = @"fb://profile/530987620335949";
static NSString * const kFacebookAppBrowserLink = @"https://www.facebook.com/musicfeedapp";
static NSString * const kTwitterAppLink = @"https://twitter.com/musicfeedapp";

static NSString *const kFeedbackEmail=@"feedback@musicfeed.co";

@interface SettingsViewController () <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property(nonatomic,copy)NSArray *tableDataArray;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *logoutIndicator;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setContentInset:UIEdgeInsetsMake(20.0, 0.0, PLAYER_VIEW_HEIGHT, 0.0)];
    self.tableView.scrollEnabled = NO;
    //[self addFooterWithVersion];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    playerManager.videoPlayer.currentViewController = self;
    [self.tableView reloadData];

}

- (void) viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:self.preferredStatusBarStyle animated:animated];
    [super viewWillAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.parentViewController && [self.parentViewController respondsToSelector:@selector(preferredStatusBarStyle)]) {
        return self.parentViewController.preferredStatusBarStyle;
    }
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFooterWithVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 90)];
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.tableView.frame), 15)];
    [versionLabel setTextAlignment:NSTextAlignmentCenter];
    [versionLabel setTextColor:[UIColor colorWithRGBHex:0x666666]];
    [versionLabel setFont:[UIFont systemFontOfSize:10.5f]];
    [versionLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Version %@", nil), build]];
    [view addSubview:versionLabel];
    
    UILabel *followLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.tableView.frame), 20)];
    [followLabel setTextAlignment:NSTextAlignmentCenter];
    [followLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [followLabel setText:NSLocalizedString(@"Follow Us!",nil)];
    [view addSubview:followLabel];
    
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.tableView.frame)/2 - 40, 55, 30, 30)];
    [facebookButton setImage:[UIImage imageNamed:@"facebook_icon"] forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(openFacebook) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:facebookButton];
    
    UIButton *twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.tableView.frame)/2 + 10, 55, 30, 30)];
    [twitterButton setImage:[UIImage imageNamed:@"twitter_icon"] forState:UIControlStateNormal];
    [twitterButton addTarget:self action:@selector(openTwitter) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:twitterButton];
    
    [self.tableView setTableFooterView:view];
}

#pragma mark - UITableView Delegate
- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRGBHex:0xE5E5E5];
    return view;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0;
    }
    return 22;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                ((SettingCell *)cell).switcher.on = settingsManager.isConnectSoundCloud;
                break;
            case 1:
                ((SettingCell *)cell).switcher.on = settingsManager.isConnectSpotify;
                break;
                
            case 2:
            {
                NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
                NSNumber* showUnfollowPromps = [userDefauls objectForKey:@"showUnfollowPromps"];
                ((SettingCell *)cell).switcher.on = [showUnfollowPromps intValue]==1;
            }
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0:
                ((SettingCell *)cell).switcher.on = settingsManager.isSharingFacebook;
                break;
            case 1:
                ((SettingCell *)cell).switcher.on = settingsManager.isSharingTwitter;
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self showEditProfile];
        } else if (indexPath.row == 1){
            [self showFindFriends];
        }
    }
//    else if (indexPath.section == 1) {
//        if (indexPath.row == 0) {
//            [self showNotificationsSettings];
//        } else if (indexPath.row == 1){
//            [self showPrivacy];
//        } else if (indexPath.row == 2){
//            [self showServices];
//        }
//    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self showGenres];
        } else if (indexPath.row == 1){
            [self goToRemovedTracks];
        } else if (indexPath.row == 2){
            [self sendIosMusicDB];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self showAbout];
        } else if (indexPath.row == 1){
            [self logout];
        }
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.row == 0) {
//        [self showSharing];
//    }
//    else if (indexPath.row == 1) {
//        [self goToRemovedTracks];
//    }
//    else if (indexPath.row == 2) {
//        [self openSendReview];
//    }
//    else if (indexPath.row == 3) {
//        [self sendIosMusicDB];
//    }

}

- (void)openFacebook
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kFacebookAppLink]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kFacebookAppLink]];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kFacebookAppBrowserLink]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kFacebookAppBrowserLink]];
    }
}

- (void)openTwitter
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kTwitterAppLink]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTwitterAppLink]];
    }
}

- (void) goToRemovedTracks{
    RemovedTracksViewController *removedTracksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"removedTracksViewController"];
    removedTracksVC.container = ((MFSettingsContainerViewController*)self.parentViewController).container;
    
    [((MFSettingsContainerViewController*)self.parentViewController).navigationController pushViewController:removedTracksVC animated:YES];
}

- (void)showServices{

    [((MFSettingsContainerViewController*)self.parentViewController).navigationController presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"MFConnectToServicesViewController"] animated:YES completion:nil];
}


- (void) showEditProfile{
    UIViewController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MFEditProfileViewController"];
    
    [((MFSettingsContainerViewController*)self.parentViewController).navigationController pushViewController:nvc animated:YES];
}
- (void) showNotificationsSettings{
    UIViewController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MFNotificationsSettingsViewController"];
    
    [((MFSettingsContainerViewController*)self.parentViewController).navigationController pushViewController:nvc animated:YES];
}

-(void) showPrivacy{
    UIViewController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MFPrivacyViewController"];
    [((MFSettingsContainerViewController*)self.parentViewController).navigationController pushViewController:nvc animated:YES];
}

- (void)showGenres{
    
    UIStoryboard* st = [UIStoryboard storyboardWithName:@"OnBoarding" bundle:nil];
    MFOnBoardingViewController* vc = [st instantiateViewControllerWithIdentifier:@"MFOnBoardingViewController"];
    vc.presentationMode = MFOnBoardingViewControllerPresentationModeSelectingGenres;
    [((MFSettingsContainerViewController*)self.parentViewController).navigationController pushViewController:vc animated:YES];
}


- (void)showFindFriends{
    UIStoryboard* st = [UIStoryboard storyboardWithName:@"OnBoarding" bundle:nil];
    MFOnBoardingViewController* vc = [st instantiateViewControllerWithIdentifier:@"MFOnBoardingViewController"];
    vc.presentationMode = MFOnBoardingViewControllerPresentationModeFollow;
    [((MFSettingsContainerViewController*)self.parentViewController).navigationController pushViewController:vc animated:YES];
}

- (void)showSharing
{
    NSString *textToShare = NSLocalizedString(@"You'll thank me later. http://www.musicfeed.co/",nil);
    
    NSArray *objectsToShare = @[textToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void) showAbout{
    MFAboutViewController *aboutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFAboutViewController"];
    
    [((MFSettingsContainerViewController*)self.parentViewController).navigationController pushViewController:aboutVC animated:YES];
}

- (void)logout
{
    [userManager logout];
    UINavigationController *navigation=(UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
    [[[[UIApplication sharedApplication] delegate] window].rootViewController dismissViewControllerAnimated:NO completion:^{
    }];
    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:navigation];

}

#pragma mark - SettingsCell Delegate methods

-(void)didSwitchAtIndexPath:(SettingCell*)cell
{
    NSIndexPath *indexPath=[self.tableView indexPathForCell:cell];
    BOOL value=[cell.switcher isOn];
    
    if(indexPath.section==0)
    {
        switch (indexPath.row)
        {
            case 0:
                settingsManager.isConnectSoundCloud=value;
                [settingsManager saveSettings];
                if (value) {
                    [self loginToSoundcloud];
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log Out",nil) message:NSLocalizedString(@"Are you sure?",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
                    [alertView show];
                }
                break;
            case 1:
                settingsManager.isConnectSpotify=value;
                [settingsManager saveSettings];
                if (value) {
                    [self loginToSpotify];
                } else {
                    [userManager saveSpotifySession:nil];
                }
                break;
            case 2:
                if (value) {
                    NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
                    [userDefauls setObject:@1 forKey:@"showUnfollowPromps"];
                    [userDefauls synchronize];
                    [userManager acceptedUnfollowPrompt];
                } else {
                    NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
                    [userDefauls setObject:@0 forKey:@"showUnfollowPromps"];
                    [userDefauls synchronize];

                }
                break;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case 0:
            {
                settingsManager.isSharingFacebook=value;
                [[IRNetworkClient sharedInstance]shareFacebook:value
                                                       success:^{}
                                                       failure:^(NSString *errorMessage){
                                                           [self showErrorMessage:errorMessage];
                                                       }];
                break;
            }
            case 1:
                settingsManager.isSharingTwitter=value;
                [[IRNetworkClient sharedInstance]shareTwitter:value
                                                       success:^{}
                                                       failure:^(NSString *errorMessage){}];
                break;
        }
    }
    
    [settingsManager saveSettings];
}

#pragma mark - Menu open/close methods

#pragma mark - Soundcloud - Login

- (void)loginToSoundcloud
{
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController;
        loginViewController =
        [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL completionHandler:^(NSError *error) {
            if (SC_CANCELED(error)) {
                NSLogExt(@"Canceled!");
                ((SettingCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).switcher.on = NO;
                settingsManager.isConnectSoundCloud = NO;
                [settingsManager saveSettings];
            }
            else if (error) {
                NSLogExt(@"Ooops, something went wrong: %@", [error localizedDescription]);
                ((SettingCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).switcher.on = NO;
                settingsManager.isConnectSoundCloud = NO;
                [settingsManager saveSettings];
            }
            else {
                NSLogExt(@"Done!");
            }
        }];
        
        CBContainerVCToFixStatusBarOverlap *containerVC = [[CBContainerVCToFixStatusBarOverlap alloc] init];
        [containerVC addChildViewController:loginViewController];
        containerVC.view.backgroundColor = [UIColor clearColor];
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            loginViewController.view.frame = CGRectMake(loginViewController.view.frame.origin.x,
                                                        loginViewController.view.frame.origin.y + 20,
                                                        containerVC.view.frame.size.width,
                                                        containerVC.view.frame.size.height - 20);
        }
        else {
            loginViewController.view.frame = CGRectMake(loginViewController.view.frame.origin.x,
                                                        loginViewController.view.frame.origin.y,
                                                        containerVC.view.frame.size.width,
                                                        containerVC.view.frame.size.height);
        }
        [containerVC.view addSubview:loginViewController.view];
        
        /* END workaround for iOS7 bug */
        
        [self presentViewController:containerVC animated:YES completion:nil];
    }];
}

- (void)loginToSpotify
{
    [userManager loginInSpotify];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

-(void)sendIosMusicDB{
    //[self.sendLibraryActivityIndicatior startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* artists = [MusicLibary iTunesMusicLibaryArtists];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[self.sendLibraryActivityIndicatior stopAnimating];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:artists options:NSJSONWritingPrettyPrinted error:nil];
            
            if([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailController=[[MFMailComposeViewController alloc]init];
                mailController.mailComposeDelegate = self;
                
                [mailController setSubject:NSLocalizedString(@"iOS MusicLibrary",nil)];
                [mailController setToRecipients:[NSArray arrayWithObject:kFeedbackEmail]];
                [mailController addAttachmentData:jsonData mimeType:@"text/json" fileName:@"data.json"];
                
                [self presentViewController:mailController animated:YES completion:nil];
                
            }
            else
            {
                NSURL* url = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"mailto:%@", kFeedbackEmail]];
                [[UIApplication sharedApplication] openURL: url];
                //        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"Cannot send email",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
                //        [alert show];
            }
            
        });
    });
}

#pragma mark - Send feedback
- (void)openSendReview
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailController=[[MFMailComposeViewController alloc]init];
        mailController.mailComposeDelegate = self;
        
        [mailController setSubject:NSLocalizedString(@"Musicfeed feedback",nil)];
        [mailController setToRecipients:[NSArray arrayWithObject:kFeedbackEmail]];
        
        [self presentViewController:mailController animated:YES completion:nil];
        
    }
    else
    {
        NSURL* url = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"mailto:%@", kFeedbackEmail]];
        [[UIApplication sharedApplication] openURL: url];
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"Cannot send email",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
//        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}
                                              
#pragma mark - UIAlertViewDelegate methods
                                              
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        settingsManager.isConnectSoundCloud = YES;
        [settingsManager saveSettings];
        SettingCell *cell = (SettingCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        [cell.switcher setOn:YES animated:YES];
    }
    else {
        
    }
}

@end
