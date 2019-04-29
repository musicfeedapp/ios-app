//
//  UIViewController+Presents.h
//  botmusic
//
//  Created by Supervisor on 22.06.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Presents)

-(void)presentModalViewController:(UIViewController*)controller;
-(void)dismissViewController;
- (UIViewController*)topVisibleViewController;

@end
