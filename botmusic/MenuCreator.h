//
//  MenuCreator.h
//  botmusic
//
//  Created by Supervisor on 04.06.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFSideMenu.h"
#import "MenuViewController.h"
#import "FeedViewController.h"

@interface MenuCreator : NSObject

+(MFSideMenuContainerViewController*)createMenu:(BOOL)anonymousMode;

@end
