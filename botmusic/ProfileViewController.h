//
//  ProfileViewController.h
//  botmusic
//
//  Created by Илья Романеня on 04.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentsViewController.h"
#import "AbstractViewController.h"
#import "TrackCell.h"
#import "FollowCell.h"
#import "CustomAKSegmentControl.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MFUserInfo+Behavior.h"
#import "MBProgressHUD.h"
#import "BaseButton.h"
#import "UIView+Utilities.h"
#import <UIImage+ImageWithColor.h>
#import <UIColor+Expanded.h>
#import <UIImageView+AFNetworking.h>
#import <UIAlertView+BlocksKit.h>
#import "MFUserInfo+Behavior.h"
#import "IRPlayerManager.h"
#import "MGSwipeTableCell.h"
#import <UIScrollView+SVPullToRefresh.h>
#import <UIScrollView+SVInfiniteScrolling.h>

@class MFUserInfoService, MFUserInfoView;

@interface ProfileViewController : AbstractViewController <UITableViewDataSource, UITableViewDelegate, TrackViewDelegate, FollowCellDelegate,CommentViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,MGSwipeTableCellDelegate,UIScrollViewDelegate>
{
    NSInteger _selectedIndex;
}

@property (nonatomic, strong) MFUserInfoService* userService;
@property (nonatomic, weak) IBOutlet MFUserInfoView *headerView;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet UIView *mainHeaderView;

@property (nonatomic, weak) IBOutlet UIView *followedButtonsView;
@property (nonatomic, weak) IBOutlet UILabel *tabTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton *artistsButton;
@property (nonatomic, weak) IBOutlet UIButton *friendsButton;

@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *followButton;

@property (nonatomic, strong) NSMutableArray* tracks;
@property (nonatomic, strong) NSMutableArray* artistsFollowItems;
@property (nonatomic, strong) NSMutableArray* friendsFollowItems;
@property (nonatomic, strong) NSMutableArray* combinedFollowItems;
@property (nonatomic, strong) NSMutableArray* followers;

@property (nonatomic,strong) MFUserInfo *userInfo;
@property (nonatomic,assign) BOOL isNotMyProfile;
@property (nonatomic,assign) BOOL isSearchProfile;
@property (nonatomic,assign) CGFloat keyboardHeight;

-(IBAction)didTouchUpFollowButton:(id)sender;

-(IBAction)didTouchUpMenuButton:(id)sender;
-(IBAction)didTouchUpBackButton:(id)sender;
-(IBAction)didTouchUpSearchButton:(id)sender;
-(IBAction)didTouchUpCancelButton:(id)sender;

-(IBAction)didTouchUpFriendsButton:(id)sender;
-(IBAction)didTouchUpArtistsButton:(id)sender;

@end
