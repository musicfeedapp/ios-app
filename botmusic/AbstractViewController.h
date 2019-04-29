//
//  PageItemAbstractViewController.h
//  botmusic
//
//  Created by Илья Романеня on 13.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Social/Social.h>
#import "MFTrackItem+Behavior.h"
#import "MFSideMenu.h"
#import "FXBlurView.h"
#import "Reachability.h"
#import "MFUserInfo+Behavior.h"
#import "MFErrorManager.h"
#import "FBSDKCoreKit.h"

extern NSString * const PlayerLikeNotificationEvent;
extern NSString * const PlayerUnlikeNotificationEvent;
extern NSString * const FeedLikeNotificationEvent;
extern NSString * const FeedUnlikeNotificationEvent;
extern NSString * const PlaylistLikeNotificationEvent;
extern NSString * const PlaylistUnlikeNotificationEvent;

//static NSString *const kNetworkErrorMessage = @"Network Error";
//static NSString *const kErrorMessage = @"No Internet Connection";
//static NSString *const kConnectedMessage = @"Connected";
//static NSString *const kTrackAdded = @"Track added!";

@interface AbstractViewController : UIViewController <UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) MFSideMenuContainerViewController *container;
@property (nonatomic,strong) MFTrackItem *trackItem;
@property (nonatomic,weak) IBOutlet FXBlurView *blurView;

// Animated error view
@property (nonatomic, strong) IBOutlet UIView *topErrorView;
@property (nonatomic, strong) IBOutlet UILabel *topErrorViewLabel;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topErrorViewBottomAlignConstraint;
@property (weak, nonatomic) IBOutlet UIButton *topErrorViewButton;
- (IBAction)topErrorButtonClicked:(id)sender;



@property (nonatomic) BOOL isTopErrorViewAnimating;

@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, strong) UILabel *errorMessage;
@property (nonatomic, strong) UITableView *tableViewBelowMessageBar;

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UITableView *searchingTableView;
@property (nonatomic,weak) IBOutlet UILabel *startTypingLabel;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityView;

@property (nonatomic,weak) IBOutlet UILabel *headerLabel;
@property (nonatomic,weak) IBOutlet UITextField *searchTextField;
@property (nonatomic,weak) IBOutlet UIButton *menuButton;
@property (nonatomic,weak) IBOutlet UIButton *searchButton;
@property (nonatomic,weak) IBOutlet UIButton *cancelButton;

@property (nonatomic,copy)NSArray *searchResultArray;
@property (nonatomic,assign) BOOL isSearchMode;

@property (nonatomic, strong) UITapGestureRecognizer *headerTapRecognizer;

@property (nonatomic, strong) NSString* kNetworkErrorMessage;
@property (nonatomic, strong) NSString* kErrorMessage;
@property (nonatomic, strong) NSString* kConnectedMessage;
@property (nonatomic, strong) NSString* kTrackAdded;
@property (nonatomic, strong) NSString* kSpotifyError;
@property (nonatomic, strong) NSString* kProblemWithNetwork;


- (IBAction)didTouchUpMenuButton:(id)sender;
- (IBAction)didTouchUpBackButton:(id)sender;
- (IBAction)didTouchUpSearchButton:(id)sender;
- (IBAction)didTouchUpCancelButton:(id)sender;

- (IBAction)didTextFieldEditChanged:(id)sender;
- (IBAction)didTextFieldTapSearchButton:(id)sender;

- (void)showUserProfileWithUserInfo:(MFUserInfo*)userInfo;
- (void)shouldOpenTrackInfo:(MFTrackItem *)trackItem;
- (void)shouldOpenPlaylist:(MFPlaylistItem *)playlistItem ofUser:(MFUserInfo*)userInfo;

- (void)showSearch;
- (void)hideSearch;

- (void)showSharing;
- (void)didShareTrackItem;

- (void)addToFavorites;
- (void)removeFromFavorites;

- (void)buyWithITunes;
- (void)changeFollowingState;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)searchWillShow;
- (void)searchWillHide;

//- (void)showErrorWithMessage:(NSString*)message;
//- (void)hideError;
//- (void)showAndKeepErrorWithMessage:(NSString*)message autohide:(BOOL)autohide;
//- (void)hideErrorWithMessage:(NSString*)message;

- (void)didTapOnHeader:(id)sender;
- (UINavigationController*)navControllerToPush;
// Animated error view methods

- (void)showAndKeepTopErrorViewWithMessage:(NSString *)message autohide:(BOOL)autohide;
- (void)hideTopErrorViewAnimated:(BOOL)animated;
- (void)hideTopErrorViewWithMessage:(NSString *)message;

@end
