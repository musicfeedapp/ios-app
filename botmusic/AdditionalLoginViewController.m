//
//  AdditionalLoginViewController.m
//  botmusic
//
//  Created by Илья Романеня on 14.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

@interface AdditionalLoginViewController ()

@end

@implementation AdditionalLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    userManager.addLoginDelegate = self;
    
    [self.loginButton setBackgroundImage:[[UIImage imageNamed:@"common-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)] forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:[[UIImage imageNamed:@"common-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)] forState:UIControlStateNormal];
    
#ifdef DEBUG
    self.loginTextField.text = @"1116137939";
    self.passwordTextField.text = @"201287ali";
#endif
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.modalPresentationStyle = UIModalPresentationFormSheet;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    userManager.addLoginDelegate = nil;
    
    [self.parentViewController viewDidAppear:NO];
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

#pragma mark - Delegate
- (void)loginSuccess
{
    NSLogExt(@"Spotify login success");
    
    self.loginButton.enabled = YES;
    [self.loginActivityIndicator stopAnimating];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginFailed:(NSString*)errorMessage
{
    NSLogExt(@"Spotify login failed");
    [NSObject showAlertMessage:errorMessage withTitle:@"Spotify login failed"];
    
    self.loginButton.enabled = YES;
    [self.loginActivityIndicator stopAnimating];
}

#pragma mark - IBActions
- (IBAction)login:(id)sender
{
    if (self.loginTextField.text.length == 0)
    {
        [self.loginTextField becomeFirstResponder];
        return;
    }
    if (self.passwordTextField.text.length == 0)
    {
        [self.passwordTextField becomeFirstResponder];
        return;
    }
    
    self.loginButton.enabled = NO;
    [self.loginActivityIndicator startAnimating];
    
    [userManager loginSpotifyWithUserName:self.loginTextField.text password:self.passwordTextField.text];
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
