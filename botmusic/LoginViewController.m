//
//  ViewController.m
//  botmusic
//
//  Created by Илья Романеня on 02.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "LoginViewController.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MFIntroViewController.h"
#import "MFTabBarViewController.h"
#import "Mixpanel.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>

static NSString * const kPrivacyPolicyLink = @"http://www.musicfeed.co/terms";

@interface LoginViewController ()
@property(nonatomic) MFEmailViewState emailViewState;
@property(nonatomic, strong) AVPlayer* avPlayer;

@property(nonatomic) BOOL viewSetUp;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.alpha = 0.0;
    [self prepareForView];
    [self setupMediaPlayer];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    AVPlayerLayer* avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    avPlayerLayer.frame = [[UIScreen mainScreen] bounds];
    [self.videoContainer.layer addSublayer:avPlayerLayer];
    [self.avPlayer play];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noInternetConnection) name:@"MFNoInternetConnection" object:nil];
    [[MFMessageManager sharedInstance] checkReachability:self];

}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.view layoutIfNeeded];
    if (!self.viewSetUp) {
        self.viewSetUp = YES;

        _facebookButton.layer.cornerRadius = 5.0;//_facebookButton.frame.size.width/2.0;
        _twitterButton.layer.cornerRadius = _twitterButton.frame.size.width/2.0;
        _emailButton.layer.cornerRadius = 5.0;//_emailButton.frame.size.width/2.0;
        [self setGradientSeparators];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:self.preferredStatusBarStyle];
    if (!self.shownInAnonymousMode) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [MFMessageManager sharedInstance].statusBarShouldBeHidden = YES;
    }
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)setupMediaPlayer{
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"startup-login-backdrop-blurred-video-1080×1920-iPhone5" withExtension:@"mp4"];

    self.avPlayer = [AVPlayer playerWithURL:videoURL];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loopVideo:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)prepareForView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.signUnViewBottomConstraint.constant = [UIScreen mainScreen].bounds.size.height/4.0;

    [self.signInEmailTextField setTintColor:[UIColor colorWithRGBHex:kNewBlueColor]];
    [self.signInPasswordTextField setTintColor:[UIColor colorWithRGBHex:kNewBlueColor]];
    [self.signUpEmailTextField setTintColor:[UIColor colorWithRGBHex:kNewBlueColor]];
    [self.forgotEmailField setTintColor:[UIColor colorWithRGBHex:kNewBlueColor]];
    [self.signUpNameTextField setTintColor:[UIColor colorWithRGBHex:kNewBlueColor]];
    [self.signUpPasswordTextField setTintColor:[UIColor colorWithRGBHex:kNewBlueColor]];

    self.signUpViewLeadingConstraint.constant = [UIScreen mainScreen].bounds.size.width;
    self.forgotViewLeadingConstraint.constant = -[UIScreen mainScreen].bounds.size.width;
    UIColor *color = [UIColor colorWithWhite:1.0 alpha:0.5];

    NSMutableAttributedString* attrString = [self.signInEmailTextField.attributedPlaceholder mutableCopy];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){0,attrString.length}];
    self.signInEmailTextField.attributedPlaceholder = attrString;

    attrString = [self.signInPasswordTextField.attributedPlaceholder mutableCopy];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){0,attrString.length}];
    self.signInPasswordTextField.attributedPlaceholder = attrString;

    attrString = [self.signUpEmailTextField.attributedPlaceholder mutableCopy];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){0,attrString.length}];
    self.signUpEmailTextField.attributedPlaceholder = attrString;

    attrString = [self.forgotEmailField.attributedPlaceholder mutableCopy];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){0,attrString.length}];
    self.forgotEmailField.attributedPlaceholder = attrString;

    attrString = [self.signUpNameTextField.attributedPlaceholder mutableCopy];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){0,attrString.length}];
    self.signUpNameTextField.attributedPlaceholder = attrString;

    attrString = [self.signUpPasswordTextField.attributedPlaceholder mutableCopy];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){0,attrString.length}];
    self.signUpPasswordTextField.attributedPlaceholder = attrString;

    if (self.shownInAnonymousMode){
        self.skipButton.hidden = YES;
    }
}

- (void) keyboardWillShow:(NSNotification*)notification{
    [self.view layoutIfNeeded];
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (self.signUnViewBottomConstraint.constant < kbSize.height - [UIScreen mainScreen].bounds.size.height/15.0) {
        self.signUnViewBottomConstraint.constant = kbSize.height - [UIScreen mainScreen].bounds.size.height/15.0;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.leftButton.alpha = 0.25;
        [self.view layoutIfNeeded];
    }];
}

-(void) keyboardWillHide:(NSNotification*)notification{
    [self.view layoutIfNeeded];
    self.signUnViewBottomConstraint.constant = [UIScreen mainScreen].bounds.size.height/4.0;
    [UIView animateWithDuration:0.25 animations:^{
        self.leftButton.alpha = 0.0;
        [self.view layoutIfNeeded];
    }];
}

- (void)loopVideo:(NSNotification*)notification {
    if (notification.object == self.avPlayer.currentItem) {
        [self.avPlayer.currentItem seekToTime:kCMTimeZero];
        [self.avPlayer play];
    }
}

- (void)applicationDidBecomeActive{
    [self.avPlayer play];
}
-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)fbLoggedIn
{

    [self.activityIndicator startAnimating];
    [self hideInitalButtons];

    NSString * accessToken = [FBSDKAccessToken currentAccessToken].tokenString;

    [[IRNetworkClient sharedInstance] loginWithFacebookToken:accessToken
                                                successBlock:^(NSDictionary* userData)
     {
         [self.activityIndicator stopAnimating];
         settingsManager.isConnectFacebook = YES;
         [settingsManager saveSettings];

         [[Mixpanel sharedInstance] track:@"User logged in with facebook"];

         MFUserInfo* userInfo = [[dataManager getUserInfoInContextbyExtID:userData[@"ext_id"]] configureWithDictionary:userData anotherUser:YES];
         [userManager loginBotmusicWithUser:userInfo apiToken:[userData validStringForKey:@"authentication_token"]];

         [self loginComplete];

         if([userData[@"is_new_user"] boolValue]){
             [userManager setFirstLogin:NO];
             [self showTutorial];
         }else{
             [self showMainMenu];
             //[self showTutorial];
         }
     }
     failureBlock:^(NSString* errorMessage)
     {
         [self.activityIndicator stopAnimating];

         [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self];

         [self unhideInitalButtons];

         settingsManager.isConnectFacebook = NO;
         [settingsManager saveSettings];

     }];
}

- (void)hideInitalButtons{
    self.twitterButton.hidden = YES;
    self.facebookButton.hidden = YES;
    self.emailButton.hidden = YES;
    self.skipButton.hidden = YES;
    self.twitterLabel.hidden = YES;
    self.facebookLabel.hidden = YES;
    self.emailLabel.hidden = YES;
}

- (void)unhideInitalButtons{
    self.twitterButton.hidden = NO;
    self.facebookButton.hidden = NO;
    self.emailButton.hidden = NO;
    self.skipButton.hidden = NO;
    self.twitterLabel.hidden = NO;
    self.facebookLabel.hidden = NO;
    self.emailLabel.hidden = NO;
}

- (void)setGradientSeparators
{
    CAGradientLayer* gradient1 = [CAGradientLayer layer];
    gradient1.frame = self.SIseparator2.bounds;
    UIColor *startColour = [UIColor colorWithWhite:1.0 alpha:1.0];
    UIColor *endColour = [UIColor colorWithWhite:1.0 alpha:0.0];
    [gradient1 setStartPoint:CGPointMake(0.0, 0.5)];
    [gradient1 setEndPoint:CGPointMake(1.0, 0.5)];
    gradient1.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [self.SIseparator2.layer addSublayer:gradient1];

    CAGradientLayer* gradient2 = [CAGradientLayer layer];
    gradient2.frame = self.SIseparator3.bounds;
    [gradient2 setStartPoint:CGPointMake(0.0, 0.5)];
    [gradient2 setEndPoint:CGPointMake(1.0, 0.5)];
    gradient2.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [self.SIseparator3.layer addSublayer:gradient2];

    CAGradientLayer* gradient3 = [CAGradientLayer layer];
    gradient3.frame = self.SUseparator1.bounds;
    [gradient3 setStartPoint:CGPointMake(0.0, 0.5)];
    [gradient3 setEndPoint:CGPointMake(1.0, 0.5)];
    gradient3.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [self.SUseparator1.layer addSublayer:gradient3];

    CAGradientLayer* gradient4 = [CAGradientLayer layer];
    gradient4.frame = self.SUseparator2.bounds;
    [gradient4 setStartPoint:CGPointMake(0.0, 0.5)];
    [gradient4 setEndPoint:CGPointMake(1.0, 0.5)];
    gradient4.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [self.SUseparator2.layer addSublayer:gradient4];

    CAGradientLayer* gradient5 = [CAGradientLayer layer];
    gradient5.frame = self.SUseparator3.bounds;
    [gradient5 setStartPoint:CGPointMake(0.0, 0.5)];
    [gradient5 setEndPoint:CGPointMake(1.0, 0.5)];
    gradient5.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [self.SUseparator3.layer addSublayer:gradient5];

    CAGradientLayer* gradient6 = [CAGradientLayer layer];
    gradient6.frame = self.SUseparator3.bounds;
    [gradient6 setStartPoint:CGPointMake(0.0, 0.5)];
    [gradient6 setEndPoint:CGPointMake(1.0, 0.5)];
    gradient6.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [self.FSeparator.layer addSublayer:gradient6];
}

- (void)showTutorial
{
    self.initalView.hidden = YES;
    self.emailView.hidden = YES;
    if (self.shownInAnonymousMode) {
        UITabBarController* tb = self.tabBarController;
        [(MFTabBarViewController*)self.tabBarController switchToLoggedInState];
        MFIntroViewController* webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"introViewController"];
        [tb presentViewController:webVC
                           animated:YES
                         completion:nil];
    } else {
        MFIntroViewController* webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"introViewController"];
        [self presentViewController:webVC
                           animated:YES
                         completion:nil];
    }
}

- (void)showMainMenu
{
    if (self.shownInAnonymousMode) {
        [(MFTabBarViewController*)self.tabBarController switchToLoggedInState];
    } else {
        MFSideMenuContainerViewController *slidingVC=[MenuCreator createMenu:NO];
        [self presentViewController:slidingVC
                           animated:YES
                         completion:nil];
    }
}

- (IBAction)fb:(UIButton *)sender
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [self fbLoggedIn];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login
                logInWithReadPermissions: @[@"email", @"user_posts", @"user_likes",@"user_friends",@"public_profile",@"user_birthday"]
                      fromViewController:self
                                 handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                     if (error) {
                                         NSLog(@"[facebook] Process error");
                                     } else if (result.isCancelled) {
                                         NSLog(@"[facebook] Cancelled");
                                     } else {
                                         NSLog(@"[facebook] Logged in");
                                         [FBSDKAccessToken setCurrentAccessToken:result.token];
                                         [self fbLoggedIn];
                                     }
                                 }];
    }
}

- (IBAction)emailButtonTapped:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.initalView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.initalView.hidden = YES;
        self.emailView.alpha = 0.0;
        self.emailView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.emailView.alpha = 1.0;
        }];
    }];
}

- (IBAction)skipButtonTapped:(id)sender {
    [self.activityIndicator startAnimating];
    [self hideInitalButtons];
    if ([userManager isUnsignedUserCreatedforThisPhone]) {
        [self continueInAnonymousModeWithIntro:NO];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray* artists = [MusicLibary iTunesMusicLibaryArtists];
            dispatch_async(dispatch_get_main_queue(), ^{

                [[IRNetworkClient sharedInstance] createUnsignedUserWithArtists:artists successBlock:^(NSDictionary *dictionary) {
                    [userManager createdUnsignedUserForThisPhone];
                    [self continueInAnonymousModeWithIntro:YES];
                } failureBlock:^(NSString *errorMessage) {
                    [self.activityIndicator stopAnimating];

                    [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self];

                    [self unhideInitalButtons];

                    settingsManager.isConnectFacebook = NO;
                    [settingsManager saveSettings];
                }];

            });
        });
    }
}

- (void)continueInAnonymousModeWithIntro:(BOOL)withIntro{
    [userManager logout];
    [self loginComplete];
    [self.activityIndicator stopAnimating];

    settingsManager.isConnectFacebook = NO;
    [settingsManager saveSettings];
    if (withIntro) {
        MFIntroViewController* webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"introViewController"];
        webVC.shouldSkipOnboardingAfter = YES;
        [self presentViewController:webVC
                           animated:YES
                         completion:nil];
    } else {
        MFSideMenuContainerViewController *slidingVC=[MenuCreator createMenu:YES];
        [self presentViewController:slidingVC
                           animated:YES
                         completion:nil];
    }
}

- (IBAction)signInButtonTapped:(id)sender {
    [self resignResponders];
    [self.activityIndicator startAnimating];
    [UIView animateWithDuration:0.3 animations:^{
        self.emailView.alpha = 0.0;
    } completion:^(BOOL finished) {

    }];

    [[IRNetworkClient sharedInstance] loginWithEmail:self.signInEmailTextField.text password:self.signInPasswordTextField.text successBlock:^(NSDictionary *userData) {

        [self.activityIndicator stopAnimating];
        MFUserInfo* userInfo = [[dataManager getUserInfoInContextbyExtID:userData[@"ext_id"]] configureWithDictionary:userData anotherUser:YES];
        [userManager loginBotmusicWithUser:userInfo apiToken:[userData validStringForKey:@"authentication_token"]];
        [self loginComplete];
        [self showMainMenu];
    } failureBlock:^(NSString *errorMessage) {
        [self.activityIndicator stopAnimating];
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self];
        [UIView animateWithDuration:0.3 animations:^{
            self.emailView.alpha = 1.0;
        } completion:^(BOOL finished) {

        }];
    }];
}

- (IBAction)signUpButtonTapped:(id)sender {
    if (![self validateSignUpFields]) {
        return;
    }
    [self resignResponders];
    [self.activityIndicator startAnimating];

    [UIView animateWithDuration:0.3 animations:^{
        self.emailView.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];

    [[IRNetworkClient sharedInstance] signUpWithEmail:self.signUpEmailTextField.text password:self.signUpPasswordTextField.text userName:self.signUpNameTextField.text successBlock:^(NSDictionary *userData) {

        [self.activityIndicator stopAnimating];
        MFUserInfo* userInfo = [[dataManager getUserInfoInContextbyExtID:userData[@"ext_id"]] configureWithDictionary:userData anotherUser:YES];
        [userManager loginBotmusicWithUser:userInfo apiToken:[userData validStringForKey:@"authentication_token"]];
        [self loginComplete];
        [self showTutorial];

    } failureBlock:^(NSString *errorMessage) {
        if ([errorMessage isEqualToString:@"The email address is already in use"]){
            UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Account Exists" message:@"Looks like you've already got an account here" preferredStyle:UIAlertControllerStyleAlert];
            [ac addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self showSignIn];
                self.signInEmailTextField.text = self.signUpEmailTextField.text;
            }]];
            [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
            [self presentViewController:ac animated:YES completion:nil];
        } else {
            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self];
        }

        [self.activityIndicator stopAnimating];
        [UIView animateWithDuration:0.3 animations:^{

            self.emailView.alpha = 1.0;
        } completion:^(BOOL finished) {

        }];
    }];
}

- (BOOL)validateSignUpFields{
    if (self.signUpNameTextField.text.length < 3) {
        [[MFMessageManager sharedInstance] showErrorMessage:@"Usernames should be between 3 and 20 characters, letters and numbers only" inViewController:self];
        return NO;
    }
    if (!self.signUpEmailTextField.text.length) {
        [[MFMessageManager sharedInstance] showErrorMessage:@"Please enter a valid email address" inViewController:self];
        return NO;
    }
    if (!self.signUpPasswordTextField.text.length) {
        [[MFMessageManager sharedInstance] showErrorMessage:@"Please enter a valid password" inViewController:self];
        return NO;
    }

    return YES;
}

- (IBAction)xButtonTapped:(id)sender {
    [self resignResponders];
    [UIView animateWithDuration:0.3 animations:^{
        self.emailView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.emailView.hidden = YES;
        self.initalView.alpha = 0.0;
        self.initalView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.initalView.alpha = 1.0;
        }];
    }];
}

- (IBAction)SIEmailDidEndOnExit:(id)sender {
    [self.signInPasswordTextField becomeFirstResponder];
}
- (IBAction)SIPasswordDidEndOnExit:(id)sender {
    [self.signInPasswordTextField resignFirstResponder];
    [self signInButtonTapped:nil];
}
- (IBAction)SUNameDidEndOnExit:(id)sender {
    [self.signUpEmailTextField becomeFirstResponder];
}
- (IBAction)SUEmailDidEndOnExit:(id)sender {
    [self.signUpPasswordTextField becomeFirstResponder];
}
- (IBAction)SUPasswordDidEndOnExit:(id)sender {
    [self.signUpPasswordTextField resignFirstResponder];
    [self signUpButtonTapped:nil];
}
- (IBAction)outsideTextViewsTapped:(id)sender {
    [self resignResponders];
}
- (IBAction)FEmailDidEndOnExit:(id)sender {
    [self sendButtonTapped:nil];
    [self.forgotEmailField resignFirstResponder];
}

-(void)resignResponders{
    [self.signInEmailTextField resignFirstResponder];
    [self.signInPasswordTextField resignFirstResponder];
    [self.signUpNameTextField resignFirstResponder];
    [self.signUpEmailTextField resignFirstResponder];
    [self.signUpPasswordTextField resignFirstResponder];
    [self.forgotEmailField resignFirstResponder];
}

-(void)loginComplete{
    [userManager downloadSuggestionsIfNeeded];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [MFMessageManager sharedInstance].statusBarShouldBeHidden = NO;
    [self.avPlayer pause];
    self.avPlayer = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (IBAction)rightButtonTapped:(id)sender {
    if (self.emailViewState == MFEmailViewStateSignIn) {
        [self showSignUp];
    } else if (self.emailViewState == MFEmailViewStateSignUp){
        [self showSignIn];
    } else if (self.emailViewState == MFEmailViewStateForgotPassword){
        [self showSignIn];
    }
}
- (IBAction)leftButtonTapped:(id)sender {
    [self showForgotPass];

//    if (self.emailViewState == MFEmailViewStateSignIn) {
//        [self showForgotPass];
//    } else if (self.emailViewState == MFEmailViewStateSignUp){
//        [self showSignIn];
//    } else if (self.emailViewState == MFEmailViewStateForgotPassword){
//
//    }
}

-(void)showSignIn{
    self.emailViewState = MFEmailViewStateSignIn;
    [self.rightButton setTitle:NSLocalizedString(@"Sign Up", nil) forState:UIControlStateNormal];
//    [self.leftButton setTitle:NSLocalizedString(@"Forgot password?", nil) forState:UIControlStateNormal];
    //self.leftButton.alpha = 0.25;
    [self.view layoutIfNeeded];

    self.forgotViewLeadingConstraint.constant = -[UIScreen mainScreen].bounds.size.width;
    self.signInViewLeadingConstraint.constant = 0.0;
    self.signUpViewLeadingConstraint.constant = [UIScreen mainScreen].bounds.size.width;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

-(void)showSignUp{
    self.emailViewState = MFEmailViewStateSignUp;
    [self.rightButton setTitle:NSLocalizedString(@"Sign In", nil) forState:UIControlStateNormal];
    [self.view layoutIfNeeded];

    self.forgotViewLeadingConstraint.constant = -2.0*[UIScreen mainScreen].bounds.size.width;
    self.signInViewLeadingConstraint.constant = - [UIScreen mainScreen].bounds.size.width;
    self.signUpViewLeadingConstraint.constant = 0.0;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

-(void)showForgotPass{
    self.emailViewState = MFEmailViewStateForgotPassword;
    [self.rightButton setTitle:NSLocalizedString(@"Sign In", nil) forState:UIControlStateNormal];
    [self.view layoutIfNeeded];

    self.forgotViewLeadingConstraint.constant = 0.0;
    self.signInViewLeadingConstraint.constant = [UIScreen mainScreen].bounds.size.width;
    self.signUpViewLeadingConstraint.constant = 2.0*[UIScreen mainScreen].bounds.size.width;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}
- (IBAction)sendButtonTapped:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Our server doesn't support this feature yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void) noInternetConnection{
    [[MFMessageManager sharedInstance] showNoInternetConnectionInViewController:self];
}

@end
