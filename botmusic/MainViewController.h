//
//  MainViewController.h
//  botmusic
//
//  Created by Илья Романеня on 04.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"
#import "PlayerViewController.h"
#import <REMenu.h>
#import "MenuDelegate.h"
#import "FeedViewController.h"
#import "ProfileViewController.h"
#import "IRPlayerManager.h"

@interface MainViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, MainVCDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerContainerConstraintWidth;
@property (nonatomic, strong) REMenu* navBarMenu;

@property (nonatomic, strong) PageViewController* pageVC;
@property (nonatomic, strong) PlayerViewController* playerVC;
@property (nonatomic, weak) UIViewController* pageLastLoadedVC;

@property (nonatomic, strong) NSArray* pageVCs;
@property (nonatomic, strong) FeedViewController* feedVC;
@property (nonatomic, strong) ProfileViewController* profileVC;

@property (nonatomic, weak) IBOutlet UINavigationBar* navBar;
@property (nonatomic, weak) IBOutlet UIPageControl* pageControl;

- (void)openMenuFromRect:(CGRect)rect inView:(UIView*)view;

- (IBAction)doubleTap:(id)sender;
@end
