//
//  NSObject+AppDelegate.m
//
//  Created by Илья Романеня.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "NSObject+Utilities.h"
#import "MBProgressHUD.h"
#import "UIViewController+Presents.h"

@implementation NSObject (Utilities)

- (AppDelegate *)appDelegate {
	
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

	return appDelegate;
}

- (void)showErrorConnectionMessage
{
    [self showProgressHUD:@"Please try later." withTitle:@"Server is unavailable."];
}

- (void)showErrorMessage: (NSString*) errorMessage
{
    [self showProgressHUD:errorMessage withTitle:@""];
}

- (void)showAlertMessage:(NSString*)errorMessage withTitle:(NSString*)title
{
    [self showProgressHUD:errorMessage withTitle:title];
}

- (void)showProgressHUD:(NSString*)errorMessage withTitle:(NSString*)title
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        UIViewController* vc;
        
        if([self isKindOfClass:[UIViewController class]]){
            vc=(UIViewController*)self;
        }else{
            vc=[self topViewController];
        }
       
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = errorMessage;
        hud.labelText = title;
        hud.yOffset = 120.0f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    });
}

- (UIViewController*)topViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    return [rootViewController topVisibleViewController];
}


@end
