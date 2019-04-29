//
//  FriendFeedViewController.m
//  botmusic
//
//  Created by Dzionis Brek on 17.03.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "FriendFeedViewController.h"
#import <UIScrollView+SVPullToRefresh.h>
#import <UIScrollView+SVInfiniteScrolling.h>

@interface FriendFeedViewController ()

@end

@implementation FriendFeedViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.feedView.menuButton setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pull and Drag triggers

- (void)pullTriggered
{
    [[IRNetworkClient sharedInstance] feedPageWithEmail:userManager.userInfo.email
                                                  token:[userManager fbToken]
                                       facebookFriendID:self.facebookFriendID
                                               feedType:self.currentFeedType
                                      lastFeedTimestamp:nil
                                             lastFeedId:nil
                                                myFeeds:NO
                                           successBlock:^(NSArray* feedArrayData)
     {
         [self.tableView.pullToRefreshView stopAnimating];
         NSMutableArray* tempFeed = [[dataManager convertAndAddTracksToDatabase:feedArrayData] mutableCopy];
         
         self.feeds =tempFeed;// [NSArray arrayWithArray:tempFeed];
         [self.tableView reloadData];
     }
                                           failureBlock:^(NSString* errorMessage)
     {
         [self.tableView.pullToRefreshView stopAnimating];
         [NSObject showErrorConnectionMessage];
     }];
}

- (void)dragTriggered
{
    [[IRNetworkClient sharedInstance] feedPageWithEmail:userManager.userInfo.email
                                                  token:[userManager fbToken]
                                       facebookFriendID:self.facebookFriendID
                                               feedType:self.currentFeedType
                                      lastFeedTimestamp:((MFTrackItem*)[self.feeds lastObject]).timestampString
                                             lastFeedId:((MFTrackItem*)[self.feeds lastObject]).itemId
                                                myFeeds:NO
                                           successBlock:^(NSArray* feedArrayData)
     {
         [self.tableView.infiniteScrollingView stopAnimating];
         NSMutableArray* tempFeed = [[dataManager convertAndAddTracksToDatabase:feedArrayData] mutableCopy];
         self.feeds = [[NSArray arrayWithArray:tempFeed]mutableCopy];
         [self.tableView reloadData];
     }
                                           failureBlock:^(NSString* errorMessage)
     {
         [self.tableView.infiniteScrollingView stopAnimating];
         [NSObject showErrorConnectionMessage];
     }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
