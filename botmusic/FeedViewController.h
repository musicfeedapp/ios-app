//
//  FeedViewController.h
//  botmusic
//
//  Created by Илья Романеня on 04.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFTrackItem+Behavior.h"
#import "MFCommentItem+Behavior.h"
#import "AbstractViewController.h"
#import "TrackCell.h"
#import <UIColor+Expanded.h>
#import <UIScrollView+SVPullToRefresh.h>
#import <UIScrollView+SVInfiniteScrolling.h>
#import <UIAlertView+BlocksKit.h>
#import "IRPlayerManager.h"
#import "ShareViewController.h"
#import "FeedView.h"
#import "CommentsViewController.h"
#import "ProfileViewController.h"
#import "FeedStatus.h"
#import "SuggestionsViewController.h"
#import "TrackView.h"

@interface FeedViewController : AbstractViewController <UITableViewDelegate, UITableViewDataSource, NavigationMenuDelegate,TrackViewDelegate, UIGestureRecognizerDelegate, CommentViewControllerDelegate, PlayerPreparationDelegate, UIAlertViewDelegate, FeedSearchDelegate>
{
    BOOL isFirstPullTrigger;
    BOOL isVeryFirstPullTrigger;
}

@property(nonatomic,weak)FeedView *feedView;
@property (nonatomic) MFFeedFilterType feedFilterType;

@property (nonatomic, weak)UITableView* tableView;

@property (nonatomic, weak) IBOutlet UIView* view;
@property (nonatomic, weak) IBOutlet UIView* containerView;
@property (weak, nonatomic) NSLayoutConstraint *headerTopConstraint;

@property(nonatomic,strong)CommentsViewController *commentsVC;

@property (nonatomic, copy)NSString *currentFeedType;

@property(nonatomic,strong)NSMutableArray *feeds;
@property(nonatomic,strong)NSMutableArray *feedStatusArray;

@property(nonatomic)BOOL isMyMusic;

@end
