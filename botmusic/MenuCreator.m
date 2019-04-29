//
//  MenuCreator.m
//  botmusic
//
//  Created by Supervisor on 04.06.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "MenuCreator.h"
#import "MFPremiumProfileViewController.h"
#import "NewSearchViewController.h"
#import "SuggestionsViewController.h"
#import "MFTabBarViewController.h"
#import "MFAddTrackViewController.h"

@implementation MenuCreator

+(MFSideMenuContainerViewController*)createMenu:(BOOL)anonymousMode
{
//    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
//    
//    MFSideMenuContainerViewController *slidingVC=[storyboard instantiateViewControllerWithIdentifier:@"slidingViewController"];
//    MenuViewController *menuController=[storyboard instantiateViewControllerWithIdentifier:@"menuViewController"];
//    menuController.container=slidingVC;
//    
//    slidingVC.leftMenuViewController=menuController;
//    
//    FeedViewController *feedVC=[storyboard instantiateViewControllerWithIdentifier:@"feedViewController"];
//    feedVC.container=slidingVC;
//    
//    UINavigationController *navigationVC=[[UINavigationController alloc]initWithRootViewController:feedVC];
//    [navigationVC setNavigationBarHidden:YES];
//    slidingVC.centerViewController=navigationVC;

    UIFont* musicfeedFont = [UIFont fontWithName:@"Musicfeed Icons 3.0" size:34];

//    UITabBarItem* addTrackBarButtonItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:1];
//    [addTrackBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: musicfeedFont} forState:UIControlStateNormal];
////    [suggestionsBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: musicfeedFont, NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateSelected];
//    addTrackBarButtonItem.titlePositionAdjustment = UIOffsetMake(0, -6);
    UITabBarItem* addTrackBarButtonItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"mic"] selectedImage:[UIImage imageNamed:@"mic_selected"]];
    addTrackBarButtonItem.tag = 1;
    addTrackBarButtonItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

//    UITabBarItem* searchBarButtonItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:2];
//    [searchBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: musicfeedFont} forState:UIControlStateNormal];
////    [searchBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: musicfeedFont, NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateSelected];
//    searchBarButtonItem.titlePositionAdjustment = UIOffsetMake(0, -6);
    UITabBarItem* searchBarButtonItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"search"] selectedImage:[UIImage imageNamed:@"search_selected"]];
    searchBarButtonItem.tag = 2;
    searchBarButtonItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

//
//    UITabBarItem* profileTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:4];
//    [profileTabBarItem setTitleTextAttributes:@{NSFontAttributeName: musicfeedFont} forState:UIControlStateNormal];
////    [profileTabBarItem setTitleTextAttributes:@{NSFontAttributeName: musicfeedFont, NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateSelected];
//    profileTabBarItem.titlePositionAdjustment = UIOffsetMake(0, -6);
    UITabBarItem* profileTabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"profile"] selectedImage:[UIImage imageNamed:@"profile_selected"]];
    profileTabBarItem.tag = 4;
    profileTabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

//    UITabBarItem* feedTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:5];
//    [feedTabBarItem setTitleTextAttributes:@{NSFontAttributeName: musicfeedFont} forState:UIControlStateNormal];
////    [feedTabBarItem setTitleTextAttributes:@{NSFontAttributeName: musicfeedFont, NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateSelected];
//    feedTabBarItem.titlePositionAdjustment = UIOffsetMake(0, -6);
    UITabBarItem* feedTabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"feed"] selectedImage:[UIImage imageNamed:@"feed_selected"]];
    feedTabBarItem.tag = 5;
    feedTabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);


    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    UIStoryboard *storyboardProfile=[UIStoryboard storyboardWithName:@"Profile" bundle:nil];

    FeedViewController *feedVC=[storyboard instantiateViewControllerWithIdentifier:@"feedViewController"];
    feedVC.container=nil;
    feedVC.isMyMusic=NO;
    UINavigationController *feednavigationVC=[[UINavigationController alloc]initWithRootViewController:feedVC];
    [feednavigationVC setNavigationBarHidden:YES];
    feednavigationVC.tabBarItem = feedTabBarItem;

    MFPremiumProfileViewController *profileVC=[storyboardProfile instantiateViewControllerWithIdentifier:@"MFPremiumProfileViewController"];
    profileVC.userInfo=userManager.userInfo;
    profileVC.container=nil;
    UINavigationController *profilenavigationVC=[[UINavigationController alloc] initWithRootViewController:profileVC];
    [profilenavigationVC setNavigationBarHidden:YES];
    profilenavigationVC.tabBarItem = profileTabBarItem;

    NewSearchViewController* searchVC = [[NewSearchViewController alloc] init];
    searchVC.container = nil;
    UINavigationController *searchnavigationVC=[[UINavigationController alloc] initWithRootViewController:searchVC];
    [searchnavigationVC setNavigationBarHidden:YES];
    searchnavigationVC.tabBarItem = searchBarButtonItem;

#ifdef BASIC

    MFTabBarViewController *tabBarVC = [[MFTabBarViewController alloc] init];
    [tabBarVC setViewControllers:@[feednavigationVC, profilenavigationVC, searchnavigationVC]];

#else

    MFAddTrackViewController* addTrackController = [[MFAddTrackViewController alloc] init];
    UINavigationController *addTracksnavigationVC=[[UINavigationController alloc]initWithRootViewController:addTrackController];
    [addTracksnavigationVC setNavigationBarHidden:YES];
    addTracksnavigationVC.tabBarItem = addTrackBarButtonItem;

    MFTabBarViewController *tabBarVC = [[MFTabBarViewController alloc] init];

    [tabBarVC setViewControllers:@[feednavigationVC, profilenavigationVC, addTracksnavigationVC, searchnavigationVC]];

#endif

    if (anonymousMode) {
        [tabBarVC switchToAnonymousState];
    }
    return tabBarVC;
}

@end
