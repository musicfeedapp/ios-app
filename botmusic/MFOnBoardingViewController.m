//
//  MFOnBoardingViewController.m
//  botmusic
//
//  Created by Panda Systems on 8/24/15.
//
//

#import "MFOnBoardingViewController.h"
#import "MenuCreator.h"
#import "MFSelectingGenresViewController.h"
#import "MFFollowViewController.h"
#import "MFOnBoardingServicesViewController.h"
#import "MusicLibary.h"

#import <FBSDKCoreKit.h>
#import "FBSDKShareKit/FBSDKShareKit.h"

@interface MFOnBoardingViewController () <MFSelectingGenresSearchDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *headerNameLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *pageViewControllerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIView *darkView;
@property (weak, nonatomic) IBOutlet UIView *searchResultsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *leftAddGenreButton;
@property (weak, nonatomic) IBOutlet UIButton *rightAddGenreButton;

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property(nonatomic, strong) UIPageViewController* pageController;
@property(nonatomic, strong) NSMutableArray* pages;
@property(nonatomic) int currentIndex;
@end

@implementation MFOnBoardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pages = [NSMutableArray array];
    
    MFOnBoardingServicesViewController* firstController = [self.storyboard instantiateViewControllerWithIdentifier:@"MFOnBoardingServicesViewController"];
    //[self.pages addObject:firstController];
    
    MFSelectingGenresViewController* secondController = [self.storyboard instantiateViewControllerWithIdentifier:@"MFSelectingGenresViewController"];
    secondController.genresSearchDelegate = self;
    if (self.presentationMode == MFOnBoardingViewControllerPresentationModeSelectingGenres) {
        secondController.isSettingsMode = YES;
    }
    [self.pages addObject:secondController];
    
    MFFollowViewController* thirdController = [self.storyboard instantiateViewControllerWithIdentifier:@"MFFollowViewController"];
    [self.pages addObject:thirdController];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showShareSheet) name:@"MFShowShareSheet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inviteFriends) name:@"MFShowFacebookInvite" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noInternetConnection) name:@"MFNoInternetConnection" object:nil];
    [[MFMessageManager sharedInstance] checkReachability:self];
    [[self.pageController view] setFrame:[self.pageViewControllerContainer bounds]];
    [self addChildViewController:self.pageController];
    [self setInitalViewController];

    [self.pageViewControllerContainer addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    [self hideButtons];
    [self configureHeader];
    if (self.presentationMode != MFOnBoardingViewControllerPresentationModeFull) {
        self.pageControl.hidden = YES;
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    } else {
        [MusicLibary sendArtistsToServer];
    }
    [self.view bringSubviewToFront:self.pageControl];
    self.searchBar.delegate = self;
    self.searchBar.translucent = YES;
    self.searchBar.placeholder = @"Find or Create a Tag";
    for (UIView *searchBarSubview in [self.searchBar subviews]) {
        for (UIView *searchBarSubSubview in searchBarSubview.subviews) {
            if ([searchBarSubSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
                
                @try {
                    
                    [(UITextField *)searchBarSubSubview setReturnKeyType:UIReturnKeyDone];
                    //[(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
                }
                @catch (NSException * e) {
                    
                    // ignore exception
                }
            }
        }
    }
    self.blurView.tintColor = [UIColor clearColor];
    self.blurView.blurRadius = 30;

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setInitalViewController{
    switch (self.presentationMode) {
        case MFOnBoardingViewControllerPresentationModeFull:
            self.currentIndex = 0;
            break;
        case MFOnBoardingViewControllerPresentationModeConnectingServices:
            self.currentIndex = 0;
            break;
        case MFOnBoardingViewControllerPresentationModeSelectingGenres:
            self.currentIndex = 0;
            break;
        case MFOnBoardingViewControllerPresentationModeFollow:
            self.currentIndex = 1;
            break;
    }
    [self.pageController setViewControllers:[NSArray arrayWithObject:self.pages[self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonTapped:(id)sender {
    if (self.presentationMode == MFOnBoardingViewControllerPresentationModeFull) {
        if (self.currentIndex!=0) {
            [self.pageController setViewControllers:[NSArray arrayWithObject:self.pages[self.currentIndex-1]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
            self.currentIndex--;
            [self.pageControl setCurrentPage:self.currentIndex];
        }
        [self configureHeader];
        [self hideButtons];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (IBAction)forwardButtonTapped:(id)sender {
    if (self.currentIndex<self.pages.count-1) {
        [self.pageController setViewControllers:[NSArray arrayWithObject:self.pages[self.currentIndex+1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        self.currentIndex++;
        [self.pageControl setCurrentPage:self.currentIndex];
    }
    [self configureHeader];
    [self hideButtons];
}

- (IBAction)doneButtonTapped:(id)sender {
    if (self.presentationMode == MFOnBoardingViewControllerPresentationModeFull) {
        if ([self.presentingViewController.presentingViewController isKindOfClass:[UITabBarController class]]) {
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            MFSideMenuContainerViewController *slidingVC = [MenuCreator createMenu:NO];
            [self presentViewController:slidingVC
                               animated:YES
                             completion:nil];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) hideButtons{
    self.backButton.hidden = YES;
    self.forwardButton.hidden = YES;
    self.doneButton.hidden = YES;
    self.leftAddGenreButton.hidden = YES;
    self.rightAddGenreButton.hidden = YES;
    self.dismissButton.hidden = YES;

    if (self.presentationMode == MFOnBoardingViewControllerPresentationModeFull) {
        if (self.currentIndex == 0) {
            self.forwardButton.hidden = NO;
            self.leftAddGenreButton.hidden = NO;
        } else if (self.currentIndex == 1) {
            self.backButton.hidden = NO;
            self.doneButton.hidden = NO;
        }
    } else {
        if (self.presentationMode == MFOnBoardingViewControllerPresentationModeSelectingGenres) {
            self.backButton.hidden = NO;
            self.rightAddGenreButton.hidden = NO;
        }
        if (self.presentationMode == MFOnBoardingViewControllerPresentationModeFollow) {
            self.backButton.hidden = NO;
        }
    }
    if (self.isShownFromBottom && self.presentationMode == MFOnBoardingViewControllerPresentationModeFollow) {
        self.backButton.hidden = YES;
        self.dismissButton.hidden = NO;
    }
}

-(void)configureHeader{
    if (self.currentIndex == 0) {
        self.headerNameLabel.text = @"Genres";
    }
    if (self.currentIndex == 1) {
        self.headerNameLabel.text = @"Find Friends";
    }
    if (self.currentIndex == 2) {
        self.headerNameLabel.text = @"Find Friends";
    }
}

-(void) startSearch{
    self.blurView.hidden = NO;
    self.blurView.alpha = 0.0;
    self.searchView.hidden = NO;
    self.darkView.hidden = NO;
    self.darkView.alpha = 0.0;
    self.searchResultsContainerView.hidden = NO;
    self.searchResultsContainerView.alpha = 0.0;
    
    self.searchViewTopConstraint.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.blurView.alpha = 1.0;
        self.darkView.alpha = 1.0;
        self.searchResultsContainerView.alpha = 1.0;

    }];
    self.pageControl.hidden = YES;
    [self.searchBar becomeFirstResponder];
    if (self.searchBar.text.length>0) {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    }
}

- (IBAction)cancelSearchButtonTapped:(id)sender {
    
    self.searchViewTopConstraint.constant = -62;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.blurView.alpha = 0.0;
        self.darkView.alpha = 0.0;
        self.searchResultsContainerView.alpha = 0.0;

    } completion:^(BOOL finished) {
        self.blurView.hidden = YES;
        self.searchView.hidden = YES;
        self.searchResultsContainerView.hidden = YES;

    }];
//    if (_presentationMode == MFOnBoardingViewControllerPresentationModeFull) {
//        self.pageControl.hidden = NO;
//    }
    [self.searchBar resignFirstResponder];
}

- (void)finishSearch{
    [self cancelSearchButtonTapped:nil];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [(MFSelectingGenresViewController*)self.pages[0] placeGenresFilteredByString:searchText onView:self.searchResultsContainerView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [(MFSelectingGenresViewController*)self.pages[0] searchBarSearchButtonClicked:(UISearchBar *)searchBar];
}

- (void)showShareSheet{
    NSString *textToShare = NSLocalizedString(@"Follow me on Musicfeed! The way to save, share, and discover new music. ♫♩", nil);
    NSURL *myWebsite = [NSURL URLWithString:@"http://get.musicfeed.co/"];

    NSArray *objectsToShare = @[textToShare, myWebsite];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

    NSArray *excludeActivities = @[UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    activityVC.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)inviteFriends {
    FBSDKAppInviteContent *content = [[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/905983722854403"];

    [FBSDKAppInviteDialog showWithContent:content delegate:nil];
}

- (IBAction)addGenreTapped:(id)sender {
    [self startSearch];
}

- (IBAction)dismissButtonTapped:(id)sender {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionReveal; //kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromBottom; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void) noInternetConnection{
    [[MFMessageManager sharedInstance] showNoInternetConnectionInViewController:self];
}
@end
