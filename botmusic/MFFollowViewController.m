//
//  MFFollowViewController.m
//  botmusic
//
//  Created by Panda Systems on 8/25/15.
//
//

#import "MFFollowViewController.h"
#import "SuggestionsOnBoardingViewController.h"
#import "UIColor+Expanded.h"
#import "MFFriendsOnBoardingViewController.h"

@interface MFFollowViewController ()
@property (weak, nonatomic) IBOutlet UIButton *suggestionsButton;
@property (weak, nonatomic) IBOutlet UIButton *contactsButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UILabel *suggestionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactsLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) SuggestionsOnBoardingViewController* suggestionsController;
@property (strong, nonatomic) MFFriendsOnBoardingViewController* contactsController;
@property (strong, nonatomic) MFFriendsOnBoardingViewController* facebookController;
@property (strong, nonatomic) MFFriendsOnBoardingViewController* artistsController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@end

@implementation MFFollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.suggestionsController = [self.storyboard instantiateViewControllerWithIdentifier:@"SuggestionsOnBoardingViewController"];
    self.suggestionsController.onBoardingViewController = (MFOnBoardingViewController*)self.parentViewController.parentViewController;
    self.contactsController = [self.storyboard instantiateViewControllerWithIdentifier:@"MFFriendsOnBoardingViewController"];
    self.contactsController.friendsType = MFFriendsTypeContacts;
    self.contactsController.onBoardingViewController = (MFOnBoardingViewController*)self.parentViewController.parentViewController;
    self.facebookController = [self.storyboard instantiateViewControllerWithIdentifier:@"MFFriendsOnBoardingViewController"];
    self.facebookController.friendsType = MFFriendsTypeFacebook;
    self.facebookController.onBoardingViewController = (MFOnBoardingViewController*)self.parentViewController.parentViewController;
    self.artistsController = [self.storyboard instantiateViewControllerWithIdentifier:@"MFFriendsOnBoardingViewController"];
    self.artistsController.friendsType = MFFriendsTypeImportedArtists;
    self.artistsController.onBoardingViewController = (MFOnBoardingViewController*)self.parentViewController.parentViewController;

    [self hideAllControllers];
    [self suggestionsButtonTapped:nil];
    self.separatorHeightConstraint.constant = 1.0/[UIScreen mainScreen].scale;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.suggestionsController.view setFrame:self.containerView.bounds];
    //self.facebookButton.layer.cornerRadius = self.facebookButton.frame.size.height/2.0;
    //self.twitterButton.layer.cornerRadius = self.twitterButton.frame.size.height/2.0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)suggestionsButtonTapped:(id)sender {
    [self hideAllControllers];
    self.suggestionsController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.suggestionsController.view];
    self.suggestionsLabel.textColor = [UIColor colorWithRGBHex:0x444348];
    self.suggestionsButton.selected = YES;
    self.suggestionsButton.userInteractionEnabled = NO;
}
- (IBAction)contactsButtonTapped:(id)sender {
    [self hideAllControllers];
    self.contactsController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.contactsController.view];
    self.contactsLabel.textColor = [UIColor colorWithRGBHex:0x444348];
    self.contactsButton.selected = YES;
    self.contactsButton.userInteractionEnabled = NO;
}
- (IBAction)facebookButtonTapped:(id)sender {
    [self hideAllControllers];
    self.facebookController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.facebookController.view];
    self.facebookLabel.textColor = [UIColor colorWithRGBHex:0x444348];
    self.facebookButton.selected = YES;
    self.facebookButton.userInteractionEnabled = NO;

}
- (IBAction)twitterButtonTapped:(id)sender {
    [self hideAllControllers];
    self.artistsController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.artistsController.view];
    self.twitterLabel.textColor = [UIColor colorWithRGBHex:0x444348];
    self.twitterButton.selected = YES;
    self.twitterButton.userInteractionEnabled = NO;

}

-(void)hideAllControllers{
    self.suggestionsLabel.textColor = [UIColor colorWithRGBHex:0x87868A];
    self.contactsLabel.textColor = [UIColor colorWithRGBHex:0x87868A];
    self.facebookLabel.textColor = [UIColor colorWithRGBHex:0x87868A];
    self.twitterLabel.textColor = [UIColor colorWithRGBHex:0x87868A];
    self.suggestionsButton.selected = NO;
    self.contactsButton.selected = NO;
    self.twitterButton.selected = NO;
    self.facebookButton.selected = NO;
    self.suggestionsButton.userInteractionEnabled = YES;
    self.contactsButton.userInteractionEnabled = YES;
    self.facebookButton.userInteractionEnabled = YES;
    self.twitterButton.userInteractionEnabled = YES;
    for (UIView* view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
}

@end
