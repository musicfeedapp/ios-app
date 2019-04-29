//
//  FollowViewController.h
//  botmusic
//
//  Created by Илья Романеня on 09.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowCell.h"
#import "MFUserInfo+Behavior.h"

@interface FollowViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FollowCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIButton* nextButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic, strong) NSMutableArray* friendsFollowItems;
@property (nonatomic, strong) NSMutableArray* artistsFollowItems;

- (void)changeFollowing:(FollowCell *)sender;
- (BOOL)following:(FollowCell *)sender;

-(IBAction)nextTap:(id)sender;
@end
