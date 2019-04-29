//
//  PreviewViewController.m
//  botmusic
//
//  Created by Dzionis Brek on 24.02.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "PreviewViewController.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController

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
    
    [self makeTutorialTrackRequest];
    
    [self createPageControllerPages];
    [self createPageControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Preparation methods

- (void)makeTutorialTrackRequest{
    [[IRNetworkClient sharedInstance]getIntroWithEmail:userManager.userInfo.email
                                             token:userManager.fbToken
                                      successBlock:^(NSDictionary *dictionary)
     {
         @try {
             NSDictionary *trackDictionary=dictionary[@"timeline"];
             NSArray* tutorialTracks = [dataManager convertAndAddTracksToDatabase:[NSArray arrayWithObject:trackDictionary]];
             self.tutorialTrack = [tutorialTracks firstObject];
             self.friendPicture=dictionary[@"friend"][@"picture"];
             self.artistPicture=dictionary[@"artist"][@"picture"];
             self.friendUsername=dictionary[@"friend"][@"username"];
             self.artistUsername=dictionary[@"artist"][@"username"];
         }
         @catch (NSException *exception) {
//             [EBNotifier logException:[NSException exceptionWithName:exception.name reason:exception.reason userInfo:dictionary] parameters:dictionary];
         }
         
     }
     failureBlock:^(NSString *errorMessage)
     {
         [NSObject showErrorConnectionMessage];
     }];
}

- (void)createPageControllerPages
{
    UIViewController *firstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"previewFirstSlide"];
    UIViewController *followVC = [self.storyboard instantiateViewControllerWithIdentifier:@"previewFollowSlide"];
    UIViewController *playVC=[self.storyboard instantiateViewControllerWithIdentifier:@"previewPlaySlide"];
    UIViewController *playVideoVC=[self.storyboard instantiateViewControllerWithIdentifier:@"playerViewController"];
    UIViewController *deleteVC=[self.storyboard instantiateViewControllerWithIdentifier:@"previewDeleteSlide"];
    
    self.pageVCs = @[firstVC,followVC,playVC,playVideoVC,deleteVC];
	
    for (UIViewController* VC in self.childViewControllers)
    {
        if ([VC isKindOfClass:[PageViewController class]])
        {
            self.pageVC = (PageViewController*)VC;
        }
    }
    self.pageVC.dataSource = self;
    self.pageVC.delegate = self;
    
    [self.pageVC setViewControllers:@[[self.pageVCs firstObject]]
                          direction:UIPageViewControllerNavigationDirectionForward
                           animated:YES
                         completion:nil];
}

-(void)createPageControl
{
    _pageControl = [[DDPageControl alloc] init];
	[_pageControl setCenter: CGPointMake(self.view.center.x, self.view.bounds.size.height-30.0f)];
	[_pageControl setNumberOfPages: [self.pageVCs count]];
	[_pageControl setCurrentPage: 0];
	[_pageControl setDefersCurrentPageDisplay: YES];
	[_pageControl setType: DDPageControlTypeOnFullOffEmpty];
	[_pageControl setOnColor: [UIColor colorWithWhite: 0.9f alpha: 1.0f]];
	[_pageControl setOffColor: [UIColor colorWithWhite: 0.7f alpha: 1.0f]];
	[_pageControl setIndicatorDiameter: 9.0f];
	[_pageControl setIndicatorSpace: 15.0f];
	[self.view addSubview: _pageControl];
}

#pragma mark - UIPageViewController Source & Delegate methods

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
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if(finished && completed)
    {
        NSUInteger currentIndex =[_pageVCs indexOfObject:[_pageVC.viewControllers lastObject]];
        
        [_pageControl setCurrentPage:currentIndex];
        [_pageControl updateCurrentPageDisplay];
    }
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
