//
//  StartViewController.m
//  botmusic
//
//  Created by Supervisor on 08.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "StartViewController.h"

@interface StartViewController ()
@property BOOL isUserNavigated;
@end

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackground];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isUserNavigated) {
        self.isUserNavigated = YES;
        if (!userManager.isLoggedIn)
        {
            NSLogExt(@"User manager isLoggedIn = NO");
            if ([userManager isUnsignedUserCreatedforThisPhone]) {
                MFSideMenuContainerViewController *slidingVC=[MenuCreator createMenu:YES];
                [self presentViewController:slidingVC
                                   animated:YES
                                 completion:nil];
            } else {
                [self transferToLogin];
            }
        }
        else
        {
            NSLogExt(@"User manager isLoggedIn = YES");
            [self getAccountData];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [MFMessageManager sharedInstance].statusBarShouldBeHidden = NO;
}

- (void)setupBackground {
    NSString *imageName = @"StartImage";
    
    _backgroudImage.image=[UIImage imageNamed:imageName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loginExisting {
    MFSideMenuContainerViewController *slidingVC=[MenuCreator createMenu:NO];

    [self presentViewController:slidingVC
                       animated:YES
                     completion:nil];
}

- (void)transferToLogin {
    LoginViewController *loginController=[self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    [self presentViewController:loginController animated:NO completion:nil];
}

- (void)getAccountData {
    [[IRNetworkClient sharedInstance] profileWithEmail:userManager.userInfo.email token:[userManager fbToken] successBlock:^(NSDictionary* userData) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            MFUserInfo *userInfo = [[dataManager getMyUserInfoInContext] configureWithDictionary:userData anotherUser:NO];
            userManager.userInfo = userInfo;
            
//            NSDictionary *followings = userData[@"followings"];
//            NSArray *followingArtists = followings[@"artists"];
//            NSArray *followingFriends = followings[@"friends"];
//            NSArray *followers = userData[@"followed"];
            
//            cacheManager.followingArtists = [DataConverter convertProposals:followingArtists];
//            cacheManager.followingFriends = [DataConverter convertProposals:followingFriends];
//            cacheManager.followers = [DataConverter convertProposals:followers];
        });
    } failureBlock:^(NSString* errorString) {

    }];
    
    [self loginExisting];
}

@end
