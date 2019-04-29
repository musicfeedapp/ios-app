//
//  MFIntroViewController.m
//  botmusic
//
//  Created by Panda Systems on 8/10/15.
//
//

#import "MFIntroViewController.h"
#import "MFIntroPageViewController.h"
#import "UIColor+Expanded.h"
#import "MenuCreator.h"
#import "MFOnBoardingViewController.h"
#import "MusicLibary.h"


@interface MFIntroViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property(nonatomic, strong) UIPageViewController* pageController;
@property(nonatomic, strong) NSMutableArray* pages;
@property (nonatomic) NSInteger currentIndex;
@end

@implementation MFIntroViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.messageLabel.text = NSLocalizedString(@"Keep track of your friends and favorite artists' music posts", nil);
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [MFMessageManager sharedInstance].statusBarShouldBeHidden = YES;
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    //self.view.backgroundColor = [UIColor colorWithRGBHex:kFaintColor];
    
    self.pages = [NSMutableArray array];
    for (int i = 0; i<4; i++) {
        MFIntroPageViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"introPageViewController"];
        vc.number = i;
        vc.introViewController = self;
        [self.pages addObject:vc];
    }
    [self.pageController setViewControllers:[NSArray arrayWithObject:self.pages[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.currentIndex = 0;
    [self addChildViewController:self.pageController];
    [self.view insertSubview:self.pageController.view atIndex:0];
    //[[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];

    [MusicLibary sendArtistsToServer];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    for (MFIntroPageViewController* vc in self.pages) {
        [vc.actionTimer invalidate];
        vc.actionTimer = nil;
    }
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

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    long i = ((MFIntroPageViewController*)viewController).number - 1;
    if (i<0) {
        return nil;
    } else {
        return self.pages[i];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    long i = ((MFIntroPageViewController*)viewController).number + 1;
    if (i>3) {
        return nil;
    } else {
        return self.pages[i];
    }
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(6_0){
    return 4;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController NS_AVAILABLE_IOS(6_0){
    if (self.pageController.viewControllers.count){
        return [(MFIntroPageViewController*)self.pageController.viewControllers[0] number];
    } else {
        return 0;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    NSInteger index = [(MFIntroPageViewController*)self.pageController.viewControllers[0] number];
    [self configureForIndex:index];
}
- (void) doneButtonPressed{
    long index = [(MFIntroPageViewController*)self.pageController.viewControllers[0] number];

    if (index<3) {
        [self.pageController setViewControllers:@[self.pages[index+1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        [self configureForIndex:index+1];
    } else {
        [self tutorialDone];
    }

}

- (void) tutorialDone{
    for (MFIntroPageViewController* vc in self.pages) {
        [vc.actionTimer invalidate];
        vc.actionTimer = nil;
    }


    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [MFMessageManager sharedInstance].statusBarShouldBeHidden = NO;
    if (self.shouldSkipOnboardingAfter) {
        UIViewController *slidingVC=[MenuCreator createMenu:YES];
        [self presentViewController:slidingVC
                           animated:YES
                         completion:nil];
    } else {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"OnBoarding" bundle:nil];
        MFOnBoardingViewController* obvc = [storyboard instantiateViewControllerWithIdentifier:@"MFOnBoardingViewController"];
        [self presentViewController:obvc
                           animated:YES
                         completion:nil];
    }
}

- (IBAction)nextButtonTapped:(id)sender {
    [self doneButtonPressed];
}

- (void) configureForIndex:(NSInteger)index{
    if (index == 0) {
        self.messageLabel.text = NSLocalizedString(@"Keep track of your friends and favorite artists' music posts", nil);
        [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    }
    if (index == 1) {
        self.messageLabel.text = NSLocalizedString(@"Listen to tracks and watch videos directly in your feed", nil);
        [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    }
    if (index == 2) {
        self.messageLabel.text = NSLocalizedString(@"Heart your biggest faves and share your love for the music", nil);
        [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    }
    if (index == 3) {
        self.messageLabel.text = NSLocalizedString(@"Remove tracks you dont like so musicfeed can learn your preferences", nil);
        [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
    }
}
@end
