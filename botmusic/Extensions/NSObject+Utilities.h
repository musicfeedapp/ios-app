//
//  NSObject+Utilities.h
//
//  Created by Илья Романеня.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface NSObject (Utilities)

- (AppDelegate *)appDelegate;

- (void)showErrorConnectionMessage;
- (void)showErrorMessage:(NSString*)errorMessage;
- (void)showAlertMessage:(NSString*)errorMessage withTitle:(NSString*)title;
- (void)showProgressHUD:(NSString*)errorMessage withTitle:(NSString*)title;

- (UIViewController*) topViewController;
@end
