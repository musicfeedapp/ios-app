//
//  MainViewController.m
//  botmusic
//
//  Created by Илья Романеня on 04.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import <REMenu.h>

@interface MainViewController ()

@end

@implementation MainViewController

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
    
    
    self.feedVC = [self.storyboard instantiateViewControllerWithIdentifier:@"feedViewController"];
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Profile" bundle:nil];
    self.profileVC = [storyboard instantiateViewControllerWithIdentifier:@"profileViewController"];
    
    self.pageVCs = @[self.feedVC, self.profileVC];
    
    for (UIViewController* VC in self.childViewControllers)
    {
        if ([VC isKindOfClass:[PageViewController class]])
        {
            self.pageVC = (PageViewController*)VC;
        }
        else if ([VC isKindOfClass:[PlayerViewController class]])
        {
            self.playerVC = (PlayerViewController*)VC;
        }
    }
    self.pageVC.delegate = self;
    self.pageVC.dataSource = self;
    
    [self.pageVC setViewControllers:@[self.feedVC]
                          direction:UIPageViewControllerNavigationDirectionForward
                           animated:YES
                         completion:nil];
    
    self.pageControl.numberOfPages = self.pageVCs.count;
    self.pageControl.currentPage = 0;
    
    REMenuItem *feedItem = [[REMenuItem alloc] initWithTitle:NSLocalizedString(@"Feed",nil)
                                                    subtitle:nil
                                                       image:nil
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLogExt(@"Item: %@", item);
                                                          [self moveToPage:self.feedVC];
                                                      }];
    
    REMenuItem *profileItem = [[REMenuItem alloc] initWithTitle:NSLocalizedString(@"Profile",nil)
                                                       subtitle:nil
                                                          image:nil
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLogExt(@"Item: %@", item);
                                                             [self moveToPage:self.profileVC];
                                                         }];
    
    self.navBarMenu = [[REMenu alloc] initWithItems:@[feedItem, profileItem]];
    self.navBarMenu.closeOnSelection = YES;
    self.navBarMenu.waitUntilAnimationIsComplete = NO;
    [self.navBarMenu showFromRect:self.navBar.frame inView:self.view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Page View delegate
- (void)moveToPage:(UIViewController*)viewController
{
    UIPageViewControllerNavigationDirection direction;
    
    if ([self.pageVCs indexOfObject:self.pageLastLoadedVC] < [self.pageVCs indexOfObject:viewController])
    {
        direction = UIPageViewControllerNavigationDirectionForward;
    }
    else
    {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    [self.pageVC setViewControllers:@[viewController]
                          direction:direction
                           animated:YES
                         completion:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self.pageVCs indexOfObject:viewController];
    if (index == self.pageVCs.count - 1)
    {
        return nil;
    }
    return self.pageVCs[index + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self.pageVCs indexOfObject:viewController];
    if (index == 0)
    {
        return nil;
    }
    return self.pageVCs[index - 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers NS_AVAILABLE_IOS(6_0)
{
    [self closeMenu];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    self.pageLastLoadedVC = [pageViewController.viewControllers lastObject];
}

#pragma mark - MainVC delegate
- (void)openMenuFromRect:(CGRect)rect inView:(UIView*)view
{
    if (!self.navBarMenu.isOpen)
    {
        [self.navBarMenu showFromRect:rect inView:view];
    }
    else
    {
        [self.navBarMenu close];
    }
}

- (void)closeMenu
{
    [self.navBarMenu close];
}

- (void)pageDidAppear:(AbstractViewController*)pageItemViewController
{
    self.pageControl.currentPage = [self.pageVCs indexOfObject:[self.pageVC.viewControllers lastObject]];
}

- (IBAction)doubleTap:(id)sender
{
    
}
@end
