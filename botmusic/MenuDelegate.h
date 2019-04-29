//
//  MenuDelegate.h
//  botmusic
//
//  Created by Илья Романеня on 12.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AbstractViewController;

@protocol MainVCDelegate <NSObject>

@required
- (void)openMenuFromRect:(CGRect)rect inView:(UIView*)view;
- (void)closeMenu;
- (void)pageDidAppear:(AbstractViewController*)pageItemViewController;
@end
