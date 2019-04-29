//
//  AppDelegate.h
//  botmusic
//
//  Created by Илья Романеня on 02.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCUI.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL isShowVideo;

- (UIViewController *)topViewController;
- (void)renumberBadgesOfPendingNotifications:(NSUInteger)number;
@end
