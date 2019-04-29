//
//  MFConnectToServicesViewController.m
//  botmusic
//

#import "MFConnectToServicesViewController.h"

@interface MFConnectToServicesViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UISwitch *autoshareSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fanPageSwitch;
@property (weak, nonatomic) IBOutlet UIView *connectedView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MFConnectToServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.disconnectButton.layer.borderWidth = 1.0;
    self.disconnectButton.layer.borderColor = [UIColor colorWithRGBHex:0x9A999D].CGColor;
    if (userManager.userInfo.facebookID && ![userManager.userInfo.facebookID isEqualToString:@""]){
        self.disconnectButton.hidden = NO;
        self.connectButton.hidden = YES;
        self.connectedView.hidden = NO;
    } else {
        self.disconnectButton.hidden = YES;
        self.connectButton.hidden = NO;
        self.connectedView.hidden = YES;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)connectButtonTapped:(id)sender {

    /*
    if (!userManager.fbSession || (userManager.fbSession.state != FBSessionStateCreated))
    {
        // Create a new, logged out session.

        NSLogExt(@"Creating new fb session");
        userManager.fbSession = [[FBSession alloc] initWithPermissions:@[@"email", @"user_posts", @"user_likes",@"user_friends",@"user_actions.music",@"public_profile",@"user_birthday"]];
    }
    else
    {
        [self fbLoggedIn];
    }

    // if the session isn't open, let's open it now and present the login UX to the user
    [FBSession setActiveSession:userManager.fbSession];
    // if the session isn't open, let's open it now and present the login UX to the user
    [userManager.fbSession openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent fromViewController:self completionHandler:^(FBSession *session,
            FBSessionState status,
            NSError *error) {
        if (status == FBSessionStateOpen)
        {
            [self fbLoggedIn];
        }
        else
        {

        }
    }];
     */
}

/*
- (void)fbLoggedIn{
    self.connectButton.hidden = YES;
    [self.activityIndicator startAnimating];
    [[IRNetworkClient sharedInstance] connectToFacebookID:userManager.fbSession.accessTokenData.userID withEmail:userManager.userInfo.email facebookToken:userManager.fbSession.accessTokenData.accessToken token:userManager.fbToken successBlock:^(NSDictionary *userData) {
        self.disconnectButton.hidden = NO;
        [self.activityIndicator stopAnimating];
        self.connectedView.hidden = NO;
    } failureBlock:^(NSString *errorMessage) {
        [self.activityIndicator stopAnimating];
        self.connectButton.hidden = NO;
    }];
}*/

- (IBAction)disconnectButtonTapped:(id)sender {
    self.disconnectButton.hidden = YES;
    [self.activityIndicator startAnimating];
    [[IRNetworkClient sharedInstance] disconnectToFacebookWithToken:userManager.fbToken withEmail:userManager.userInfo.email successBlock:^(NSDictionary *userData) {
        self.connectButton.hidden = NO;
        [self.activityIndicator stopAnimating];
        self.connectedView.hidden = YES;
    } failureBlock:^(NSString *errorMessage) {
        [self.activityIndicator stopAnimating];
        self.disconnectButton.hidden = NO;
    }];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
