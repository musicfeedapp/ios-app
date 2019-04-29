//
//  ShareViewController.h
//  botmusic
//
//  Created by Илья Романеня on 16.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFTrackItem+Behavior.h"
#import "ShareHeaderCell.h"
#import "ShareItemCell.h"

@interface ShareViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ShareHeaderCellDelegate>

@property (nonatomic, strong) MFTrackItem* feedItem;
@property (nonatomic, assign) BOOL added;

@property (nonatomic, weak) IBOutlet UITableView* tableView;

- (BOOL)isFacebookShared:(ShareHeaderCell*)sender;
- (BOOL)isTwitterShared:(ShareHeaderCell*)sender;

- (void)shareOnFacebook:(ShareHeaderCell*)sender
        completionBlock:(CompletionBlock)completionBlock;
- (void)shareOnTwitter:(ShareHeaderCell*)sender
       completionBlock:(CompletionBlock)completionBlock;

- (IBAction)closeTap:(id)sender;

@end
