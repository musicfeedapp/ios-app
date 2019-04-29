//
//  MenuViewController.h
//  botmusic
//
//  Created by Supervisor on 08.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "MFSideMenu.h"
#import "ProfileViewController.h"
#import "FeedViewController.h"
#import "SettingsViewController.h"
#import "SuggestionsViewController.h"
#import "DataConverter.h"
#import "MenuCell.h"
#import "SuggestionCell.h"
#import "MenuSettingsCell.h"

@interface MenuViewController : AbstractViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign)       NSUInteger selectedIndex;

@end
