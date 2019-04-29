//
//  UIViewController+Presents.m
//  botmusic
//
//  Created by Supervisor on 22.06.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "UIViewController+Presents.h"
#import "MFTabBarViewController.h"

static CGFloat const PRESENT_ANIMATION_DURATION=0.4f;

@implementation UIViewController (Presents)

-(void)presentModalViewController:(UIViewController*)controller
{
    CGRect frame=controller.view.frame;
    frame.origin.y=frame.size.height;
    controller.view.frame=frame;
    
    frame.origin.y=0;
    
    [self.view addSubview:controller.view];
    
    [UIView animateWithDuration:PRESENT_ANIMATION_DURATION animations:^{
         controller.view.frame=frame;
     } completion:^(BOOL finished){
         [self addChildViewController:controller];
     }];
}
-(void)dismissViewController
{
    CGRect frame=self.view.frame;
    
    frame.origin.y=frame.size.height;
    
    [UIView animateWithDuration:PRESENT_ANIMATION_DURATION animations:^{
        self.view.frame=frame;
    } completion:^(BOOL finished){
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}
- (UIViewController*)topVisibleViewController
{

    if ([self isKindOfClass:[UITabBarController class]])
    {
        UITabBarController* tabBarController = (UITabBarController*)self;
        return [tabBarController.selectedViewController topVisibleViewController];
    }
    else if ([self isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* navigationController = (UINavigationController*)self;
        return [navigationController.visibleViewController topVisibleViewController];
    }
    else if (self.presentedViewController)
    {
        return [self.presentedViewController topVisibleViewController];
    }
    else if (self.childViewControllers.count > 0)
    {
        return [self.childViewControllers.lastObject topVisibleViewController];
    }
    
    return self;
}

@end
