 //
//  FeedViewController.m
//  botmusic
//
//  Created by Илья Романеня on 04.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "FeedViewController.h"
#import "MFFeedTableCell.h"
#import "MGSwipeButton.h"
#import "MFNotificationManager.h"
#import "TrackInfoViewController.h"
#import "PlaylistsViewController.h"
#import "SearchViewController.h"
#import "RemovedTracksViewController.h"
#import "PSRateManager.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MFFeedManager.h"
#import "MFDeepLinkingManager.h"
#import "JLNotificationPermission.h"
#import "MusicLibary.h"
#import "MFRecognitionManager.h"
#import "MFIntroViewController.h"
#import "MFOnBoardingViewController.h"
#import "MFAddTrackViewController.h"
#import "NewSearchViewController.h"
#import "MFSingleTrackViewController.h"
#import "MFFeedOverlay.h"
#import "NSObject+Utilities.h"
#import "MFTabBarViewController.h"

static NSString *const kMyMusic=@"Favorites";
static NSString *const kFeed=@"musicfeed";
static NSInteger SMALL_COUNT=5;
static CGFloat const INFINITE_SCROLLING_VIEW_HEIGHT = 60;
static NSString *const kFeedbackEmail=@"feedback@musicfeed.co";
static NSString *const LastPlayedTrackKey=@"LastPlayedTrackKey";

@interface FeedViewController () <MGSwipeTableCellDelegate, TrackInfoPlayDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) NSMutableArray *selectedCells;
@property (nonatomic, weak)    TrackView* currentTrack;

@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic,strong) MFTrackItem* removedTrack;
@property (nonatomic, assign) BOOL doNotHideNavBar;
@property (weak, nonatomic) UIButton *addTrackButton;
@property (strong, nonatomic) MFFeedOverlay* instructionalOverlay;
@property (nonatomic, strong) MFPlaylistItem* postsPlaylist;
//@property (nonatomic, strong) NSTimer* scrollingTimer;
@end

@implementation FeedViewController

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeNotReachable];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notReachableNotification:)
                                                     name:notificationName
                                                   object:nil];
        
        NSString* notificationNextTrackName = [MFNotificationManager nameForNotification:MFNotificationTypeLoadingNextTrack];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadingNextTrackNotification:)
                                                     name:notificationNextTrackName
                                                   object:nil];
        
        NSString *notificationStatusBarTappedName = [MFNotificationManager nameForNotification:MFNotificationTypeStatusBarTapped];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didTapOnHeader:)
                                                     name:notificationStatusBarTappedName
                                                   object:nil];
        
        NSString *notificationRestoreTrackName = [MFNotificationManager nameForNotification:MFNotificationTypeRestoreTrack];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRestoreTrack:)
                                                     name:notificationRestoreTrackName
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(scrollFeedToPlayingTrack:)
                                                     name:@"scrollFeedToPlayingTrack"
                                                   object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggingStateChanged) name:@"MFUserLoggedOut" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggingStateChanged) name:@"MFUserLoggedIn" object:nil];

        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollTo];


}

- (void)viewDidAppear:(BOOL)animated
{
    playerManager.videoPlayer.currentViewController = self;
    //[self scrollTo];
    [super viewDidAppear:animated];
    
    //[self scrollTo];
    [self.container setPanMode:MFSideMenuPanModeDefault];


    NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
    NSNumber* overlayShown = [userDefauls objectForKey:@"TutorialOverlayWasShown"];
    if (!overlayShown) {
        [self showTutorialOverlay];
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"TutorialOverlayWasShown"];
    }
    //[self pullTriggered];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    MFTrackItem *trackItem=[self lastestTrackItem];
    
    // In case of no feed items in the user feed after the installation
    // it's possible to have no feed items.
    if (trackItem != NULL) {
        if(self.isMyMusic)
        {
            saver.myMusicLatestTrackItemID = trackItem.itemId;
        }
        else
        {
            saver.feedLatestTrackItemID = trackItem.itemId;
        }
    }
    
    [self setFeeds:_feeds];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"OnBoarding" bundle:nil];
//    MFOnBoardingViewController* obvc = [storyboard instantiateViewControllerWithIdentifier:@"MFOnBoardingViewController"];
//    [self presentViewController:obvc
//                       animated:YES
//                     completion:nil];
    self.feedFilterType = MFFeedFilterTypeFeed;
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(like:) name:PlayerLikeNotificationEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlike:) name:PlayerUnlikeNotificationEvent object:nil];

    NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateUserFollowing];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateFollowing:)
                                                 name:notificationName
                                               object:nil];
    [self pullTriggered];
    //[playerManager changeTracks:_feeds];
    
    playerManager.preparationVC = self;
    
    _currentFeedType = feedTypeAll;
    isFirstPullTrigger = YES;
    
    [self setFeedView];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [MFMessageManager sharedInstance].statusBarShouldBeHidden = NO;
    [self setTableView];
    //[self.feedView insertSubview:self.errorView belowSubview:self.feedView.headerView];
    self.topErrorView = self.feedView.topErrorView;
    self.topErrorViewLabel = self.feedView.topErrorViewLabel;
    self.topErrorViewBottomAlignConstraint = self.feedView.topErrorViewAlignment;
    self.topErrorViewButton = self.feedView.topErrorViewButton;
    self.headerTopConstraint = self.feedView.headerTopConstraint;
    self.addTrackButton = self.feedView.addTrackButton;
    [self.addTrackButton addTarget:self action:@selector(addTrackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //[self setGradientShadow];
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        isVeryFirstPullTrigger = YES;
    });
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] renumberBadgesOfPendingNotifications:0];
    
    [MFDeepLinkingManager performDeepLinking];




    //NSArray* array = [MusicLibary iTunesMusicLibaryArtists];
    //NSArray* array1 = [MusicLibary iTunesMusicLibaryTracks];
    //[self testrefq];
}

- (void) testrefq{
    [[MFMessageManager sharedInstance] showTrackAddedMessageInViewController:self.tabBarController];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self testrefq];
    });
}

- (void) loggingStateChanged{
    self.feedView.findPeopleView.hidden = YES;
    [self pullTriggered];
}

- (void) showTutorialOverlay{
    self.instructionalOverlay = [[[NSBundle mainBundle] loadNibNamed:@"MFFeedOverlay" owner:nil options:nil] firstObject];
    self.instructionalOverlay.alpha = 0.0;
    self.instructionalOverlay.frame = [NSObject appDelegate].window.bounds;
    [[NSObject appDelegate].window addSubview:self.instructionalOverlay];
    [self.instructionalOverlay.gotItButton addTarget:self action:@selector(dismissTutorialOverlay) forControlEvents:UIControlEventTouchUpInside];
    [UIView animateWithDuration:0.3 animations:^{
        self.instructionalOverlay.alpha = 1.0;
    }];
}

- (void) dismissTutorialOverlay{
    [UIView animateWithDuration:0.3 animations:^{
        self.instructionalOverlay.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.instructionalOverlay removeFromSuperview];
    }];
}
- (void)setGradientShadow
{
    if (_gradient == nil) {
        _gradient = [CAGradientLayer layer];
    }
    
    _gradient.frame = CGRectMake(0, 39, [UIScreen mainScreen].bounds.size.width, 2);
    UIColor *startColour = [UIColor colorWithWhite:0.0 alpha:0.0];
    UIColor *endColour = [UIColor colorWithWhite:0.0 alpha:0.08];
    [_gradient setStartPoint:CGPointMake(0.5, 1.0)];
    [_gradient setEndPoint:CGPointMake(0.5, 0.0)];
    _gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [self.containerView.layer insertSublayer:_gradient above:self.tableView.layer];
}

//- (void) viewDidLayoutSubviews{
//    [super viewDidLayoutSubviews];
//    [self.view layoutIfNeeded];
//    [self scrollViewDidScroll:self.tableView];
//}

#pragma mark - Set Reachability notifications



#pragma mark - Initial Settings

- (void)setFeedView
{
    self.feedView = [FeedView createFeedView];
    
    //feed or faivorites
//    if(self.isMyMusic)
//    {
//        [self.feedView.headerLabel setText:kMyMusic];
//    }
//    else
//    {
//        [self.feedView.headerLabel setText:kFeed];
//    }
    [self.feedView.findPeopleButton addTarget:self action:@selector(findPeopleButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.feedView.suggestionsButton addTarget:self action:@selector(suggestionsButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.feedView setDelegate:self];
    [self.feedView setSearchDelegate:self];
    [self.containerView addSubview:_feedView];
    
    [_feedView.menuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [_feedView.headerView addGestureRecognizer:self.headerTapRecognizer];
}

- (void)suggestionsButtonTapped{
    [(MFTabBarViewController*)self.tabBarController navigateToSuggestions];
}

- (void)setTableView
{
    self.tableView = _feedView.tableView;
    self.tableView.delegate = self;
    
    self.tableView.sectionHeaderHeight=0.0f;
    self.tableView.sectionFooterHeight=0.0f;
    
    self.tableView.dataSource = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^
     {
         [self pullTriggered];
     }];
    [self.tableView addInfiniteScrollingWithActionHandler:^
     {
         [self dragTriggered];
     }];
    
//    self.tableView.pullToRefreshView.arrowColor = [UIColor colorWithRGBHex:kActiveColor];
//    self.tableView.pullToRefreshView.textColor = [UIColor colorWithRGBHex:kActiveColor];
//    self.tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
//    self.tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    [self.tableView triggerPullToRefresh];
}

- (void)configFeedStatusArray:(NSInteger)count
{
    _feedStatusArray=[NSMutableArray array];
    for(int i=0;i<count;i++)
    {
        FeedStatus *status=[FeedStatus new];
        [_feedStatusArray addObject:status];
    }
}
- (void)checkFeedCount
{
    if(!self.isMyMusic && self.feeds && self.feeds.count<=SMALL_COUNT && isFirstPullTrigger)
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Discover more music by adding more artists.", nil) delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Add Now", nil];
        [alertView setTag:0];
        [alertView show];
    }
}

- (void)findPeopleButtonTapped{
    if (![userManager isLoggedIn]) {
        //[MFNotificationManager postUserUnauthorizedNotification];
        [(MFTabBarViewController*)self.tabBarController navigateToSuggestions];
    } else {
        UIStoryboard* st = [UIStoryboard storyboardWithName:@"OnBoarding" bundle:nil];
        MFOnBoardingViewController* vc = [st instantiateViewControllerWithIdentifier:@"MFOnBoardingViewController"];
        vc.presentationMode = MFOnBoardingViewControllerPresentationModeFollow;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Notification center


- (void)scrollFeedToPlayingTrack:(NSNotification *)notification {
    if(playerManager.haveTrack)
    {
        if((!self.isMyMusic && saver.trackSource==MFTracksSourceFeed) || (self.isMyMusic && saver.trackSource==MFTracksSourceMyMusic))
        {
            [self scrollToTrackItemID:saver.playingTrackItemID animated:YES];
        }
    }
}

- (void)like:(NSNotification *)notification {
    MFTrackItem *trackItem=[[notification userInfo] objectForKey:@"trackItem"];    
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    
    if (indexPath) {
        TrackView *trackView=[self trackViewForIndexPath:indexPath];
        [trackView setTrackInfo:trackItem];
        
        [self.feeds replaceObjectAtIndex:indexPath.row withObject:trackItem];
    }
}

- (void)unlike:(NSNotification *)notification {
    MFTrackItem *trackItem=[[notification userInfo] objectForKey:@"trackItem"];
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    
    if (indexPath) {
        TrackView *trackView=[self trackViewForIndexPath:indexPath];
        [trackView setTrackInfo:trackItem];
        
        [self.feeds replaceObjectAtIndex:indexPath.row withObject:trackItem];
    }
}

- (void)notReachableNotification:(NSNotification *) notification
{
    [self showAndKeepTopErrorViewWithMessage:self.kErrorMessage autohide:NO];
}


- (void)loadingNextTrackNotification:(NSNotification *) notification
{
    [self scrollToCurrentTrack];
}


- (void)didUpdateFollowing:(NSNotification *)notification
{
    MFUserInfo* ui = notification.userInfo[@"user_info"];
    if (ui && !ui.isFollowed){
        MFUserInfo* userInfo;
        if (userManager.isLoggedIn) {
            userInfo = userManager.userInfo;
        } else {
            userInfo = dataManager.getAnonUserInfo;
        }

        NSArray* feeds = [MFTrackItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"ANY belongToUsers == %@", userInfo]];
        for (MFTrackItem* item in feeds) {
            if ([item.authorExtId isEqualToString:ui.extId]) {
                item.isFeedTrack = NO;
                [userInfo removeTracksObject:item];
            }
        }
    }
    
    [self pullTriggered];
}

- (void)didRestoreTrack:(NSNotification *)notification
{
    [self pullTriggered];
}

#pragma mark - Talbe View delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"TrackCell";
    
    MFFeedTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[MFFeedTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    //cell.delegate = self;

    [cell.trackView setTrackInfo:_feeds[indexPath.row]];

    //[trackView setIsCommentsOpen:indexPath.row==selectedIndex];
    [cell.trackView setDelegate:self];
    [cell.trackView setIndexPath:[indexPath copy]];
    [cell.trackView setTag:1];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearchMode) {
        return self.searchResultArray.count;
    }
    return _feeds.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TrackView trackViewHeight];
}


#pragma mark - Track View delegate

- (void)didTapOnView:(MFTrackItem *)trackItem
{
    [self didTapOnView:trackItem playOnlyOneTrack:NO];
}

- (void)didTapOnView:(MFTrackItem *)trackItem playOnlyOneTrack:(BOOL)onlyOne
{
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    NSIndexPath *trackPath = indexPath;
    if (self.isSearchMode) {
        trackPath = [self indexPathForTrackItem:[self.searchResultArray objectAtIndex:indexPath.row]];
        
    }
    FeedStatus *status = StatusNone;
    if (trackPath){
        status = self.feedStatusArray[trackPath.row];
    }
    
    if (status.feedStatus == StatusNone) {
        
        playerManager.preparationVC=self;
        NSArray *nondeletedFeeds = [self nondeletedFeeds];
        MFTrackItem *track = trackItem;
        NSUInteger index = 0;
        if (trackPath){
            track = _feeds[trackPath.row];
            index = [nondeletedFeeds indexOfObject:track];
        }
        playerManager.isManualTrackSwitching = playerManager.haveTrack;
        if (onlyOne){
            [playerManager playSingleTrack:trackItem];
        } else {
            playerManager.currentSourceName = [self playlistNameForCurrentType];
            [playerManager playPlaylist:nondeletedFeeds fromIndex:index];
        }
        if(self.isMyMusic)
        {
            [saver setTrackSource:MFTracksSourceMyMusic];
        }
        else
        {
            [saver setTrackSource:MFTracksSourceFeed];
        }
    }
    else if ([status haveStatus:StatusPlaying])
    {
        if (playerManager.haveTrack) {
            [playerManager pauseTrack];
            //            status.feedStatus = StatusPaused;
        }
    }
    else if([status haveStatus:StatusPaused])
    {
        if(playerManager.haveTrack)
        {
            [playerManager resumeTrack];
            //            status.feedStatus = StatusPlaying;
        }
    }
    else if([status haveStatus:StatusVideoPlaying])
    {
        status.feedStatus=StatusNone;
    }
    else if([status haveStatus:StatusDeleting])
    {
        status.feedStatus=StatusNone;
    }

}

- (void)didLike:(MFTrackItem *)trackItem
{
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    [self showLikeAtIndexPath:indexPath];
    
    [[IRNetworkClient sharedInstance] likeTrackById:trackItem.itemId
                                          withEmail:userManager.userInfo.email
                                              token:[userManager fbToken]
                                       successBlock:^{
                                       }
                                       failureBlock:^(NSString *errorMessage){
                                           [self showUnLikeAtIndexPath:indexPath];
                                           [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                       }];

    [[PSRateManager sharedInstance]promptForRatingIfPossibleWithCompletion:^(PSRateCompletionType type){
        if (type == PSRateCompletionTypeDisliked){
            if([MFMailComposeViewController canSendMail])
            {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Would you like to send us feedback?", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                [alertView setTag:3];
                [alertView show];
                
                
            }
            
        }
    }
                                                                  view:self.view];
}

- (void)showLikeAtIndexPath:(NSIndexPath*)indexPath
{
    MFTrackItem *trackItem=_feeds[indexPath.row];
    [trackItem likeTrackItem];
    
    TrackView *trackView=[self trackViewForIndexPath:indexPath];
    //[trackView setTrackInfo:trackItem];
    [trackView setIsLiked:trackItem.isLiked];
    //[self.feeds replaceObjectAtIndex:indexPath.row withObject:trackItem];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:trackItem
                                                         forKey:@"trackItem"];
    [[NSNotificationCenter defaultCenter] postNotificationName:FeedLikeNotificationEvent
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)showUnLikeAtIndexPath:(NSIndexPath*)indexPath
{
    MFTrackItem *trackItem=_feeds[indexPath.row];
    [trackItem dislikeTrackItem];
    
    TrackView *trackView=[self trackViewForIndexPath:indexPath];
    //[trackView setTrackInfo:trackItem];
    [trackView setIsLiked:trackItem.isLiked];

    //[self.feeds replaceObjectAtIndex:indexPath.row withObject:trackItem];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:trackItem
                                                         forKey:@"trackItem"];
    [[NSNotificationCenter defaultCenter] postNotificationName:FeedUnlikeNotificationEvent
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)didUnlike:(MFTrackItem *)trackItem
{
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    [self showUnLikeAtIndexPath:indexPath];
    
    [[IRNetworkClient sharedInstance] unlikeTrackById:trackItem.itemId
                                            withEmail:userManager.userInfo.email
                                                token:[userManager fbToken]
                                         successBlock:^{}
                                         failureBlock:^(NSString *errorMessage){
                                             [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

                                             [self showLikeAtIndexPath:indexPath];
                                         }];
}

- (void)didSelectComment:(MFTrackItem *)trackItem
{
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    FeedStatus *status = _feedStatusArray[indexPath.row];
    [status addStatus:StatusCommenting];
    
    [self showCommentsViewController:trackItem];
}

- (void)didDelete:(MFTrackItem *)feedItem
{
    NSIndexPath *indexPath = [self indexPathForTrackItem:feedItem];

    [self.feedStatusArray removeObjectAtIndex:indexPath.row];
    [self.feeds removeObjectAtIndex:indexPath.row];


    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];


    switch (self.feedFilterType) {
        case MFFeedFilterTypeFeed:
        {
            [self deleteFeedItem:feedItem atIndexPath:indexPath];
        }
            break;

        case MFFeedFilterTypeAudioOnly:
        {
            [self deleteFeedItem:feedItem atIndexPath:indexPath];
        }
            break;

        case MFFeedFilterTypeVideoOnly:
        {
            [self deleteFeedItem:feedItem atIndexPath:indexPath];
        }
            break;

        case MFFeedFilterTypePosts:
        {
            [self deletePostItem:feedItem];
        }
            break;

        case MFFeedFilterTypeTrending:
        {
            [self deleteTrendingItem:feedItem];
        }
            break;

        default:
            break;
    }

    
}

- (void) deleteFeedItem:(MFTrackItem*)feedItem atIndexPath:(NSIndexPath*)indexPath{
    if (!settingsManager.isPromptRemove) {
        [settingsManager setIsPromptRemove:YES];
        [settingsManager saveSettings];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"Tracks can be restored from Settings. Take a look?", nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        [alertView setTag:1];
        [alertView show];
    }
    [[MFFeedManager sharedInstance] deleteTrackFromFeed:feedItem
                                           successBlock:^(NSDictionary *dictionary) {
                                               NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
                                               NSNumber* showUnfollowPromps = [userDefauls objectForKey:@"showUnfollowPromps"];

                                               if ([[dictionary objectForKey:@"unfollow"] boolValue]&&![userManager showingUnfollowPromptsStopped] && [showUnfollowPromps intValue] == 1 && ![feedItem.authorExtId isEqualToString:userManager.userInfo.extId]){

                                                   self.removedTrack = feedItem;
                                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Unfollow %@",nil), self.removedTrack.authorName]
                                                                                                       message:[NSString stringWithFormat:NSLocalizedString(@"You recently removed serveral tracks from %@. Unfollow?",nil), self.removedTrack.authorName]
                                                                                                      delegate:self
                                                                                             cancelButtonTitle:@"No"
                                                                                             otherButtonTitles:@"Yes", nil];
                                                   [alertView setTag:2];
                                                   [alertView show];
                                               }

                                               if ((saver.trackSource == MFTracksSourceMyMusic && self.isMyMusic) || (saver.trackSource == MFTracksSourceFeed && !self.isMyMusic)) {
                                                   NSUInteger index = indexPath.row;
                                                   if (playerManager.hasTransitionalTrack) {
                                                       index++;
                                                   }
                                                   //[playerManager removeTrackAtIndex:index];
                                               }

                                           }
                                           failureBlock:^(NSString *errorMessage) {
                                               [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                           }];
}

- (void) deletePostItem:(MFTrackItem*)trackItem{
    [[IRNetworkClient sharedInstance] deleteSongsWithPlaylistId:self.postsPlaylist.itemId songsIds:@[trackItem.itemId] email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {

        //NSIndexPath *indexPath = [self indexPathForTrackWithId:track.itemId];
        [MFNotificationManager postUpdatePlaylistNotification:self.postsPlaylist];
        [MFNotificationManager postUpdateLovedTracksPlaylistNotification];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];

}

- (void) deleteTrendingItem:(MFTrackItem*)trackItem{

}

- (void)updateParallax:(NSTimer*) timer {
    [self scrollViewDidScroll:self.tableView];
}

- (NSIndexPath *)removeDeletingTracksFromIndex:(NSIndexPath *)indexPath {
    //counter for removed tracks
    int num = 0;
    for (int i = 0; i < [_feedStatusArray count]; i++) {
        FeedStatus *status = _feedStatusArray[i];
        if (status.feedStatus == StatusDeleting){
            if (i<indexPath.row) {
                num++;
            }
            [self.feedStatusArray removeObjectAtIndex:i];
            [self.feeds removeObjectAtIndex:i];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    if (num == 0) {
        return indexPath;
    }
    return [NSIndexPath indexPathForRow:(indexPath.row - num) inSection:indexPath.section];
}

- (void)didShare:(MFTrackItem *)trackItem
{
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    
    if (self.isSearchMode) {
        trackItem = self.searchResultArray[indexPath.row];
    }
    
    self.trackItem = trackItem;
    [self showSharing];
}

- (void)didSelectShowFriend:(MFTrackItem *)trackItem
{
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    
    if (self.feeds && self.feeds.count > indexPath.row) {
        MFTrackItem *trackItem = self.feeds[indexPath.row];
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:trackItem.authorExtId];
        userInfo.username = trackItem.username;
        //userInfo.profileImage = trackItem.authorPicture;
        userInfo.facebookID = trackItem.authorId; //TODO is correct?
        userInfo.extId = trackItem.authorExtId;
        userInfo.name = trackItem.authorName;
        [self showUserProfileWithUserInfo:userInfo];
    }
}

- (void)didRestoreDeleted:(NSIndexPath *)indexPath
{
    FeedStatus *status=_feedStatusArray[indexPath.row];
    [status setFeedStatus:StatusNone];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView beginUpdates];
        TrackView *deletedTrackView = [self trackViewForIndexPath:indexPath];
        [deletedTrackView.restoreButton setHidden:YES];
        [deletedTrackView setTapEnable:YES];
        [self.tableView endUpdates];
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
    }];
    
    MFTrackItem *trackItem = _feeds[indexPath.row];
    
    if((saver.trackSource==MFTracksSourceMyMusic && self.isMyMusic) || (saver.trackSource==MFTracksSourceFeed && !self.isMyMusic)) {
        NSUInteger index = indexPath.row;
        if (playerManager.hasTransitionalTrack) {
            index++;
        }
        //[playerManager insertTrack:trackItem atIndex:index];
    }
    
    [[IRNetworkClient sharedInstance] restoreTrackWithId:trackItem.itemId email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
        
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

- (void)shouldOpenTrackInfo:(MFTrackItem *)trackItem
{
//    TrackInfoViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"trackInfoViewController"];
//    trackInfoVC.container = self.container;
//    trackInfoVC.trackItem = trackItem;
//    trackInfoVC.playDelegate = self;

    MFSingleTrackViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = trackItem;
    trackInfoVC.container = self.container;
    [self.navigationController pushViewController:trackInfoVC animated:YES];
}

- (void)didAddToPlaylist:(MFTrackItem *)trackItem
{
    PlaylistsViewController *playlistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
    playlistsVC.container = self.container;
    playlistsVC.trackToAdd = trackItem;
    
    [self.navigationController pushViewController:playlistsVC animated:YES];
}

- (void)didRepostTrack:(MFTrackItem *)track{
    [[IRNetworkClient sharedInstance] publishTrackByID:track.itemId SuccessBlock:^(NSDictionary *dictionary) {
        [[MFMessageManager sharedInstance] showTrackRepostedMessageInViewController:self.tabBarController];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

    }];
}

#pragma mark - Pull and Drag triggers

- (void)pullTriggered
{
    [self setTracksFromCacheForCurrentMode:100 lastTrack:nil];
    if (!self.feeds.count) {
        [self.feedView.activityIndicator startAnimating];
        //[self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top - 0.5 - self.tableView.pullToRefreshView.bounds.size.height) animated:YES];
        //[self.tableView triggerPullToRefresh];
    }
    [self downloadTracksForCurrentMode:100 lastTrack:nil];
    /*
    [[MFFeedManager sharedInstance] getLastTracks:100
                                        fromTrack: nil
                                   isFirstTrigger:isFirstPullTrigger
                                  succesFromCache:^(NSMutableArray* tracks){
                                      self.feeds = tracks;
                                      //[playerManager changeTracks:_feeds];
                                      [self configFeedStatusArray:[_feeds count]];
                                      if (self.feeds.count) {
                                          self.feedView.findPeopleView.hidden = YES;
                                      }
                                      [self.tableView reloadData];
                                      //[self scrollTo];
                                      //[self scrollViewDidScroll:self.tableView];
                                      
                                  }
                                updatedFromServer:^(NSMutableArray* tracks){
                                    [self.tableView.pullToRefreshView stopAnimating];
                                    if(tracks){
                                        self.feeds = tracks;
                                        //[playerManager changeTracks:_feeds];
                                        [self configFeedStatusArray:[_feeds count]];
                                        [self.tableView reloadData];
                                        
                                        [self checkFeedCount];
                                        
                                    }
                                    if (!self.feeds.count) {
                                        self.feedView.findPeopleView.hidden = NO;
                                    } else {
                                        self.feedView.findPeopleView.hidden = YES;
                                    }
                                    [self hideTopErrorViewWithMessage:self.kConnectedMessage];
                                    //[self scrollTo];
                                }
                                failureFromServer:^(NSString* error){
                                    [self.tableView.pullToRefreshView stopAnimating];
                                    [self configFeedStatusArray:[_feeds count]];
                                    [self showAndKeepTopErrorViewWithMessage:self.kNetworkErrorMessage autohide:YES];
                                    //[self scrollTo];
                                }];
     */

}

- (void)dragTriggered
{
    [self setTracksFromCacheForCurrentMode:self.feeds.count + 100 lastTrack:self.feeds.lastObject];
    [self downloadTracksForCurrentMode:self.feeds.count + 100 lastTrack:self.feeds.lastObject];
/*
    [[MFFeedManager sharedInstance] getLastTracks: (int)self.feeds.count + 100
                                        fromTrack: self.feeds.lastObject
                                   isFirstTrigger:YES
                                  succesFromCache:^(NSMutableArray* tracks){
                                      if (tracks.count == 0) {
                                          [UIView animateWithDuration:0.3 animations:^{
                                              [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - INFINITE_SCROLLING_VIEW_HEIGHT)];
                                          }];
                                      }
                                      self.feeds = tracks;
                                      //[playerManager changeTracks:_feeds];
                                      [self configFeedStatusArray:[_feeds count]];
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^
                                                     {
                                                         [self.tableView reloadData];
                                                     });
                                      [self checkFeedCount];
                                      
                                      //[self scrollTo];
                                  }
                                updatedFromServer:^(NSMutableArray* tracks){
                                    [self.tableView.infiniteScrollingView stopAnimating];
                                    if(tracks){
                                        if (tracks.count == 0) {
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - INFINITE_SCROLLING_VIEW_HEIGHT)];
                                            }];
                                        }
                                        self.feeds = tracks;
                                        //[playerManager changeTracks:_feeds];
                                        [self configFeedStatusArray:[_feeds count]];
                                    
                                        dispatch_async(dispatch_get_main_queue(), ^
                                                   {
                                                       [self.tableView reloadData];
                                                   });
                                        [self checkFeedCount];
                                    }
                                    [self hideTopErrorViewWithMessage:self.kConnectedMessage];
                                }
                                failureFromServer:^(NSString* error){
                                    [self.tableView.infiniteScrollingView stopAnimating];
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - INFINITE_SCROLLING_VIEW_HEIGHT)];
                                    }];
                                    [self showAndKeepTopErrorViewWithMessage:self.kNetworkErrorMessage autohide:YES];
                                }];
*/
    
}

#pragma mark - PlayerPreparationDelegate methods

- (void)needToLoginInSoundCloud:(UIViewController *)loginController
{
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)didStartTrackAtIndex:(NSUInteger)index afterTrackAtIndex:(NSUInteger)prevIndex {
//    FeedStatus *prevStatus = self.feedStatusArray[prevIndex];
//    [prevStatus setFeedStatus:StatusNone];
//    
//    FeedStatus *status = self.feedStatusArray[index];
//    [status setFeedStatus:StatusPlaying];
}

- (void)didPauseTrackAtIndex:(NSUInteger)index {
    FeedStatus *status = self.feedStatusArray[index];
    [status setFeedStatus:StatusPaused];
}

- (void)didResumeTrackAtIndex:(NSUInteger)index {
    FeedStatus *status = self.feedStatusArray[index];
    [status setFeedStatus:StatusPlaying];
}

- (void)didPauseTrack:(MFTrackItem *)trackItem
{
    NSIndexPath *closeIndexPath=[self activeFeedIndexPath];
    [self closeFooterForIndexPath:closeIndexPath andOpen:nil];
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    if (indexPath) {
        [((FeedStatus *)_feedStatusArray[indexPath.row]) setFeedStatus:StatusPaused];
    }
}

- (void)didResumeTrack:(MFTrackItem *)trackItem
{
    NSIndexPath *closeIndexPath=[self activeFeedIndexPath];
    [self closeFooterForIndexPath:closeIndexPath andOpen:nil];
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    if (indexPath) {
        [((FeedStatus *)_feedStatusArray[indexPath.row]) setFeedStatus:StatusPlaying];
    }
}

- (void)didStartTrack:(MFTrackItem *)trackItem afterTrack:(MFTrackItem *)prevTrack {
    
    NSIndexPath *closeIndexPath=[self activeFeedIndexPath];
    [self closeFooterForIndexPath:closeIndexPath andOpen:nil];
    NSIndexPath *indexPath = [self indexPathForTrackItem:trackItem];
    
    if (indexPath) {
//        ((MFTrackItem *)_feeds[indexPath.row]).trackState = IRTrackItemStatePlaying;
        [((FeedStatus *)_feedStatusArray[indexPath.row]) setFeedStatus:StatusPlaying];
        [[NSUserDefaults standardUserDefaults] setObject:trackItem.itemId forKey:LastPlayedTrackKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSIndexPath *prevIndexPath = [self indexPathForTrackItem:prevTrack];
    if (prevIndexPath) {
//        ((MFTrackItem *)_feeds[prevIndexPath.row]).trackState = IRTrackItemStatePlayed;
        [((FeedStatus *)_feedStatusArray[prevIndexPath.row]) setFeedStatus:StatusNone];
    }
}

#pragma mark - Menu Toogle

- (void)toggleMenu
{
    [self.container toggleLeftSideMenuCompletion:nil];
}

#pragma mark - CommentsViewController Methods

- (void)showCommentsViewController:(MFTrackItem*)trackItem
{
//    NSIndexPath *commentIndexPath=[self commentFeedIndexPath];
//    _commentsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
//    [_commentsVC setDelegate:self];
//    [_commentsVC setTrackItem:(MFTrackItem*)_feeds[commentIndexPath.row]];
//    _commentsVC.container = self.container;
//
//    [self.navigationController pushViewController:_commentsVC animated:YES];
    [self commentFeedIndexPath];
    MFSingleTrackViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = trackItem;
    trackInfoVC.container = self.container;
    
    [self.navigationController pushViewController:trackInfoVC animated:YES];
    
}

- (void)didAddComment
{
    NSIndexPath *commentIndexPath=[self commentFeedIndexPath];
    MFTrackItem *trackItem=_feeds[commentIndexPath.row];
    //[trackItem addComment];
    /*
    TrackView *trackView=[self trackViewForIndexPath:commentIndexPath];
    [trackView setTrackInfo:trackItem];
     */
}

- (void)didRemoveComment
{
    NSIndexPath *commentIndexPath=[self commentFeedIndexPath];
    MFTrackItem *trackItem=_feeds[commentIndexPath.row];
    [trackItem removeComment];
    
    TrackView *trackView=[self trackViewForIndexPath:commentIndexPath];
    [trackView setTrackInfo:trackItem];
}

- (void)willCloseCommentController
{
    NSIndexPath *commentIndexPath=[self commentFeedIndexPath];
    FeedStatus *status=_feedStatusArray[commentIndexPath.row];
    [status removeStatus:StatusCommenting];
    
    if([playerManager currentTrack])
    {
        [self.container setPlayerViewHidden:NO];
    }
}

#pragma mark - UIInterfaceOrientation Methods

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if(appDelegate.isShowVideo)
    {
        return self.interfaceOrientation;
    }
    else
    {
        return UIInterfaceOrientationPortrait;
    }
}

#pragma mark - Search methods
- (void)scrollTo
{
    if(isFirstPullTrigger)
    {
        isFirstPullTrigger=NO;
        
        [self scrollToCurrentTrack];
    }
}

- (void)scrollToTrackItemID:(NSString*)trackItemID animated:(BOOL)animated
{
    if(trackItemID)
    {
        NSInteger index=[_feeds indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^(id obj, NSUInteger idx, BOOL *stop)
                         {
                             if([[(MFTrackItem*)obj itemId]integerValue]==[trackItemID integerValue])
                             {
                                 return YES;
                             }
                             return NO;
                         }];
        if(index!=NSNotFound)
        {
            
            NSIndexPath *indexPath=[NSIndexPath indexPathForItem:index inSection:0];
            
            FeedStatus *status=_feedStatusArray[indexPath.row];
            
            if(playerManager.haveTrack)
            {
                if([playerManager playing])
                {
                    status.feedStatus=StatusPlaying;
                    //((MFTrackItem *)_feeds[index]).trackState = IRTrackItemStatePlaying;
                }
                else
                {
                    status.feedStatus=StatusPaused;
                    //((MFTrackItem *)_feeds[index]).trackState = IRTrackItemStatePaused;
                }
            }
            
            if(indexPath&&self.tableView){
                _doNotHideNavBar = YES;
                if (indexPath.row != 0) {
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
                } else {
                    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top - 0.5) animated:NO];
                }
                _doNotHideNavBar = NO;
            }
            
        } else {
                [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top - 0.5)];
        }
    }
}

- (void)scrollToCurrentTrack
{
    if(playerManager.haveTrack)
    {
        if((!self.isMyMusic && saver.trackSource==MFTracksSourceFeed) || (self.isMyMusic && saver.trackSource==MFTracksSourceMyMusic))
        {
            [self scrollToTrackItemID:saver.playingTrackItemID animated:NO];
        }
    }
    else if(isVeryFirstPullTrigger){
        isVeryFirstPullTrigger = NO;
        NSString* itemID =[[NSUserDefaults standardUserDefaults] objectForKey:LastPlayedTrackKey];
        if(itemID) [self scrollToTrackItemID:itemID animated:NO];
    }
    else
    {
        if(self.isMyMusic)
        {
            [self scrollToTrackItemID:saver.myMusicLatestTrackItemID animated:NO];
        }
        else
        {
            [self scrollToTrackItemID:saver.feedLatestTrackItemID animated:NO];
        }
        
    }
    
//    if(isVeryFirstPullTrigger){
//        isVeryFirstPullTrigger = NO;
//        NSString* itemID =[[NSUserDefaults standardUserDefaults] objectForKey:LastPlayedTrackKey];
//        if(itemID) [self scrollToTrackItemID:itemID animated:NO];
//    }
//    else
//    {
//        if(self.isMyMusic)
//        {
//            [self scrollToTrackItemID:saver.myMusicLatestTrackItemID animated:NO];
//        }
//        else
//        {
//            [self scrollToTrackItemID:saver.feedLatestTrackItemID animated:NO];
//        }
//        
//    }
    
}

#pragma mark - Helpers

- (TrackView*)trackViewForIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        TrackView *trackView = (TrackView *)[cell.contentView viewWithTag:1];
        return trackView;
    } else {
        return nil;
    }
}

- (NSIndexPath*)indexPathForTrackItem:(MFTrackItem*)trackItem
{
    for (int i = 0; i < _feeds.count; i++) {
        MFTrackItem *track = _feeds[i];
        if ([track.itemId isEqual:trackItem.itemId]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

- (void)closeFooterForIndexPath:(NSIndexPath*)closeIndexPath andOpen:(NSIndexPath*)openIndexPath
{
    if (closeIndexPath!=nil) {
        FeedStatus *status=_feedStatusArray[closeIndexPath.row];
        [status setFeedStatus:StatusNone];
    }
}

- (NSIndexPath*)activeFeedIndexPath
{
    for(int i=0;i<[_feedStatusArray count];i++)
    {
        FeedStatus *status=_feedStatusArray[i];
        if([status isFeedActive])
        {
            return [NSIndexPath indexPathForItem:i inSection:0];
        }
    }
    
    return nil;
}

- (NSIndexPath*)commentFeedIndexPath
{
    for(int i=0;i<[_feedStatusArray count];i++)
    {
        FeedStatus *status=_feedStatusArray[i];
        if([status haveStatus:StatusCommenting])
        {
            return [NSIndexPath indexPathForItem:i inSection:0];
        }
    }
    
    return nil;
}

- (NSIndexPath*)deleteFeedIndexPath
{
    for(int i=0;i<[_feedStatusArray count];i++)
    {
        FeedStatus *status=_feedStatusArray[i];
        if([status haveStatus:StatusDeleting])
        {
            return [NSIndexPath indexPathForItem:i inSection:0];
        }
    }
    
    return nil;
}

- (MFTrackItem*)lastestTrackItem{
    NSIndexPath *indexPath;
    if([[self.tableView visibleCells] count]>3){
        
        UITableViewCell *cell=[[self.tableView visibleCells] objectAtIndex: [[self.tableView visibleCells] count] - 4];
        indexPath=[self.tableView indexPathForCell:cell];
    }
    if (indexPath != nil) {
        return self.feeds[indexPath.row];
    } else {
        return NULL;
    }
}

- (NSArray *)nondeletedFeeds
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedStatus == %d", StatusDeleting];
    NSArray *deleted = [_feedStatusArray filteredArrayUsingPredicate:predicate];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (FeedStatus *status in deleted) {
        [indexes addIndex:[_feedStatusArray indexOfObject:status]];
    }
    NSMutableArray *result = [_feeds mutableCopy];
    [result removeObjectsAtIndexes:indexes];
    
    return result;
}

#pragma mark - UIAlertVIew Delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex) {
            SuggestionsViewController *suggestionVC=[self.storyboard instantiateViewControllerWithIdentifier:@"suggestionsViewController"];
            suggestionVC.isRedirectTo=YES;
            [self.navigationController pushViewController:suggestionVC animated:YES];
            
            [self.container setPanMode:MFSideMenuPanModeNone];
        }
    }
    else if (alertView.tag == 1) {
        if (buttonIndex) {
            RemovedTracksViewController *removedTracksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"removedTracksViewController"];
            removedTracksVC.container = self.container;
            [self.navigationController pushViewController:removedTracksVC animated:YES];
        }
    }
    else if (alertView.tag == 2) {
        if (buttonIndex) {
            NSDictionary *proposalsDictionary = @{@"ext_id" : self.removedTrack.authorExtId,
                                                  @"followed" : @"false"};
            
            [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                              token:[userManager fbToken]
                                                          proposals:@[proposalsDictionary]
                                                       successBlock:^{
                                                           [self.removedTrack setAuthorIsFollowed:!self.removedTrack.authorIsFollowed];
                                                           MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:self.removedTrack.authorExtId];
                                                           userInfo.facebookID = self.removedTrack.authorId;
                                                           userInfo.extId = self.removedTrack.authorExtId;
                                                           userInfo.isFollowed = self.removedTrack.authorIsFollowed;
                                                           [MFNotificationManager postUpdateUserFollowingNotification:userInfo];
                                                           
                                                       }
                                                       failureBlock:^(NSString *errorMessage){
                                                           [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                                       }];
            [userManager acceptedUnfollowPrompt];
        }
        if (buttonIndex == 0) {
            [userManager rejectedUnfollowPrompt];
            if ([userManager showingUnfollowPromptsStopped]){
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"Stop asking to unfollow users?",nil)
                                                                   delegate:self
                                                          cancelButtonTitle:@"No"
                                                          otherButtonTitles:@"Yes", nil];
                [alertView setTag:4];
                [alertView show];
                
            }
        }
    }
    else if (alertView.tag ==3){
        if(buttonIndex){
            MFMailComposeViewController *mailController=[[MFMailComposeViewController alloc]init];
            mailController.mailComposeDelegate = self;
            [mailController setSubject:@"Musicfeed feedback"];
            [mailController setToRecipients:[NSArray arrayWithObject:kFeedbackEmail]];
            
            [self presentViewController:mailController animated:YES completion:nil];
        }
    }
    else if (alertView.tag ==4){
        if(buttonIndex){
            
            NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
            [userDefauls setObject:@0 forKey:@"showUnfollowPromps"];
            [userDefauls synchronize];
            
        } else if (buttonIndex == 0){
            [userManager acceptedUnfollowPrompt];
            
            NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
            [userDefauls setObject:@1 forKey:@"showUnfollowPromps"];
            [userDefauls synchronize];
        }
    }
}

#pragma mark - Setters & Getters

- (void)setFeeds:(NSMutableArray *)feeds
{
    _feeds = feeds;
}

#pragma mark - Feed Search Delegate

- (void)setSearchMode:(BOOL)isSearchMode
{
    self.isSearchMode = isSearchMode;
    [self.tableView reloadData];
}

- (void)didBeginEditing:(id)sender
{
    self.searchResultArray = nil;
}

- (void)didEditingChanged:(id)sender
{
    [self.startTypingLabel setHidden:YES];

    NSArray *targetArray = self.feeds;

    NSString *keywords = ((UITextField *)sender).text;

    self.searchResultArray = targetArray;
    [self.tableView reloadData];

    if (keywords == nil) {
        keywords = @"";
    }
    
    if (![keywords isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"trackName CONTAINS[c] %@ OR username CONTAINS[c] %@", keywords, keywords];
        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[targetArray filteredArrayUsingPredicate:predicate]];
        
        self.searchResultArray = filteredArray;
        
        [self.tableView reloadData];
    }
}

- (void)didCancelSearch
{
    [self scrollToCurrentTrack];
}


#pragma mark - Error message methods


#pragma mark - TrackInfoPlay Delegate methods

- (void)didSelectPlay:(MFTrackItem *)trackItem
{
    [self didTapOnView:trackItem playOnlyOneTrack:YES];
}

#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender
{
    if ([self.tableView numberOfRowsInSection:0] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - NavigationMenuDelegate methods

- (void)didSelectSearch
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    SearchViewController *searchVC = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    NewSearchViewController* searchVC = [[NewSearchViewController alloc] init];
    searchVC.container = self.container;
    
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSArray *listOfVisibleCells = self.tableView.visibleCells;
//    
//    for (int i=0; i<[listOfVisibleCells count]; i++) {
//        
//        MFFeedTableCell *cell = [listOfVisibleCells objectAtIndex:i];
//        
//        if (cell.trackView.trackItem.isYoutubeTrack) {
//            CGFloat cropPercent = 0.0;
//            cell.trackView.imageViewTopConstraint.constant = (scrollView.contentOffset.y+scrollView.contentInset.top-cell.frame.origin.y)/15.0 - 243.0*cropPercent;
//            cell.trackView.imageViewHeight.constant = (243.0)*(1.0+2.0*cropPercent);
//        } else {
//            cell.trackView.imageViewTopConstraint.constant = (scrollView.contentOffset.y+scrollView.contentInset.top-cell.frame.origin.y)/15.0;
//            cell.trackView.imageViewHeight.constant = 243.0;
//        }
//    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //[self showPlayerAndNavBar];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if (!decelerate) {
//        [self showPlayerAndNavBar];
//    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //[self showPlayerAndNavBar];
}

-(void) hidePlayerAndNavBar{
    //[self.container hideSmallPlayerAndNavBar:self];
}

-(void) showPlayerAndNavBar{
    //[self.container showSmallPlayerAndNavBar:self];
}

-(void) showPlayerAndNavBar:(NSTimer*)timer{
    //[self.container showSmallPlayerAndNavBar:self];
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    _doNotHideNavBar = YES;
    [self scrollViewDidScroll:self.tableView];
    _doNotHideNavBar = NO;
}

- (void)addTrackButtonTapped:(id)sender {
    MFAddTrackViewController* addTrackController = [[MFAddTrackViewController alloc] init];
    addTrackController.view.frame = [[[UIApplication sharedApplication] delegate] window].bounds;
    
    FXBlurView* bv = [[FXBlurView alloc] initWithFrame:self.view.frame];
    bv.blurRadius = 35.0;
    bv.tintColor = [UIColor clearColor];
    [self.view addSubview:bv];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:bv];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:addTrackController.view];
    bv.alpha = 0.0;
    bv.dynamic = NO;
    addTrackController.blurView = bv;
    addTrackController.view.alpha = 0.0;
    [self addChildViewController:addTrackController];
    [addTrackController didMoveToParentViewController:self];
    [UIView animateWithDuration:0.2 animations:^{
        addTrackController.view.alpha = 1.0;
        bv.alpha = 1.0;
    }];
    
}

- (void)setTracksFromCacheForCurrentMode:(NSInteger)number lastTrack:( MFTrackItem* _Nullable )lastTrack{
    switch (self.feedFilterType) {
        case MFFeedFilterTypeFeed:
            {
            [[MFFeedManager sharedInstance] returnFeedsFromDatabase:number block:^(NSMutableArray *tracks) {
                self.feeds = tracks;
            }];
            }
            break;

        case MFFeedFilterTypeAudioOnly:
        {
            [[MFFeedManager sharedInstance] returnFeedsFromDatabase:number block:^(NSMutableArray *tracks) {
                self.feeds = [self getOnlyAudioTracks:tracks];
            }];
        }
            break;

        case MFFeedFilterTypeVideoOnly:
        {
            [[MFFeedManager sharedInstance] returnFeedsFromDatabase:number block:^(NSMutableArray *tracks) {
                self.feeds = [self getOnlyVideoTracks:tracks];
            }];
        }
            break;

        case MFFeedFilterTypePosts:
            if (lastTrack) {
                //do nothing
            } else {
                self.feeds = [@[] mutableCopy];
                if (userManager.userInfo.playlists.count) {
                    self.feeds = [[((MFPlaylistItem*)userManager.userInfo.playlists[0]).songs array] mutableCopy];
                    self.postsPlaylist = userManager.userInfo.playlists[0];
                }
            }
            break;

        case MFFeedFilterTypeTrending:
            if (userManager.isLoggedIn) {
                self.feeds = [[userManager.userInfo.trendingTracks array] mutableCopy];
            } else {
                self.feeds = [[dataManager.getAnonUserInfo.trendingTracks array] mutableCopy];
            }
            break;

        default:
            break;
    }

    [self configFeedStatusArray:[_feeds count]];
    if (self.feeds.count) {
        self.feedView.findPeopleView.hidden = YES;
    }
    [self.tableView reloadData];
}

- (void)downloadTracksForCurrentMode:(NSInteger)number lastTrack:( MFTrackItem* _Nullable )lastTrack{
    switch (self.feedFilterType) {
        case MFFeedFilterTypeFeed:
        {
            [self downloadFeeds:number lastTrack:lastTrack];
        }
            break;

        case MFFeedFilterTypeAudioOnly:
        {
            [self downloadFeeds:number lastTrack:lastTrack];
        }
            break;

        case MFFeedFilterTypeVideoOnly:
        {
            [self downloadFeeds:number lastTrack:lastTrack];
        }
            break;

        case MFFeedFilterTypePosts:
        {
            if (lastTrack) {
                [self downloadPostsFromPost:lastTrack];
            } else {
                [self downloadPostsFirstPage];
            }
        }
            break;

        case MFFeedFilterTypeTrending:
        {
            [self downloadTrending];
        }
            break;

        default:
            break;
    }

}

- (void)tracksDownloaded:(NSArray*)tracks{
    [self.tableView.pullToRefreshView stopAnimating];
    [self.tableView.infiniteScrollingView stopAnimating];
    [self.feedView.activityIndicator stopAnimating];
    if(tracks){
        if (self.feedFilterType == MFFeedFilterTypeAudioOnly) {
            self.feeds = [self getOnlyAudioTracks:tracks];
        } else if (self.feedFilterType == MFFeedFilterTypeVideoOnly) {
            self.feeds = [self getOnlyVideoTracks:tracks];
        } else {
            self.feeds = [tracks mutableCopy];
        }
        //[playerManager changeTracks:_feeds];
        [self configFeedStatusArray:[_feeds count]];
        [self.tableView reloadData];

        [self checkFeedCount];

    }
    if (!self.feeds.count) {
        self.feedView.findPeopleView.hidden = NO;
    } else {
        self.feedView.findPeopleView.hidden = YES;
    }
    [self hideTopErrorViewWithMessage:self.kConnectedMessage];
}

- (void) tracksDownloadFailure:(NSString*)errorMessage{
    [self.tableView.pullToRefreshView stopAnimating];
    [self.tableView.infiniteScrollingView stopAnimating];
    [self.feedView.activityIndicator stopAnimating];
    [self configFeedStatusArray:[_feeds count]];
    [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
}

- (NSString*)playlistNameForCurrentType{
    switch (self.feedFilterType) {
        case MFFeedFilterTypeFeed:
        {
            return NSLocalizedString(@"Feed", nil);
        }
            break;

        case MFFeedFilterTypePosts:
        {
            return NSLocalizedString(@"My Posts", nil);
        }
            break;

        case MFFeedFilterTypeTrending:
        {
            return NSLocalizedString(@"Trending Tracks", nil);
        }
            break;

        case MFFeedFilterTypeAudioOnly:
        {
            return NSLocalizedString(@"Feed - Audio only", nil);
        }
            break;

        case MFFeedFilterTypeVideoOnly:
        {
            return NSLocalizedString(@"Feed - Video only", nil);
        }
            break;

        default:
            break;
    }
}

- (void)setFeedFilterType:(MFFeedFilterType)feedFilterType{
    _feedFilterType = feedFilterType;
    [self pullTriggered];
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top)];
}

- (void) downloadFeeds:(NSInteger)number lastTrack:( MFTrackItem* _Nullable )lastTrack{
    [[MFFeedManager sharedInstance] getLastTracks:number fromTrack:lastTrack isFirstTrigger:isFirstPullTrigger succesFromCache:nil updatedFromServer:^(NSMutableArray *tracks) {
        [self tracksDownloaded:tracks];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MFRefreshFeedBadgeNumber" object:nil];
    } failureFromServer:^(NSString *errorMessage) {
        [self tracksDownloadFailure:errorMessage];
    }];
}

- (void) downloadPostsFirstPage{
    [[IRNetworkClient sharedInstance] getPlaylistsWithEmail:userManager.userInfo.email token:userManager.fbToken extId:userManager.userInfo.extId successBlock:^(NSArray *array) {
        
        NSArray *playlists = [dataManager convertAndAddPlaylistsToDatabase:array ofUser:userManager.userInfo];
        
        userManager.userInfo.playlists = [NSOrderedSet orderedSetWithArray:playlists];
        self.postsPlaylist = playlists[0];
        
        [[IRNetworkClient sharedInstance] getPlaylistsWithId:self.postsPlaylist.itemId extId:userManager.userInfo.extId lastTimelineId:nil successBlock:^(NSDictionary *dictionary) {
            
            NSArray *tracks = [dataManager convertAndAddTracksToDatabase:dictionary[@"songs"]];
            self.postsPlaylist.songs = [NSOrderedSet orderedSetWithArray:tracks];
            
            [self tracksDownloaded:[self.postsPlaylist.songs array]];
            
        } failureBlock:^(NSString *errorMessage) {
            [self tracksDownloadFailure:errorMessage];
        }];
        
    } failureBlock:^(NSString *errorMessage) {
        [self tracksDownloadFailure:errorMessage];
    }];

}

- (void) downloadPostsFromPost:(MFTrackItem*)lastTrack{
    [[IRNetworkClient sharedInstance] getPlaylistsWithEmail:userManager.userInfo.email token:userManager.fbToken extId:userManager.userInfo.extId successBlock:^(NSArray *array) {

        NSArray *playlists = [dataManager convertAndAddPlaylistsToDatabase:array ofUser:userManager.userInfo];

        userManager.userInfo.playlists = [NSOrderedSet orderedSetWithArray:playlists];
        self.postsPlaylist = playlists[0];

        [[IRNetworkClient sharedInstance] getPlaylistsWithId:self.postsPlaylist.itemId extId:userManager.userInfo.extId lastTimelineId:lastTrack.itemId successBlock:^(NSDictionary *dictionary) {

            NSArray *tracks = [dataManager convertAndAddTracksToDatabase:dictionary[@"songs"]];
            NSMutableOrderedSet * set = [NSMutableOrderedSet orderedSetWithArray:[self.feeds arrayByAddingObjectsFromArray:tracks]];
            [self tracksDownloaded:[set array]];

        } failureBlock:^(NSString *errorMessage) {
            [self tracksDownloadFailure:errorMessage];
        }];

    } failureBlock:^(NSString *errorMessage) {
        [self tracksDownloadFailure:errorMessage];
    }];

}

- (void) downloadTrending{
    [[IRNetworkClient sharedInstance] getTrendingTracksWithSuccessBlock:^(NSArray *array) {
        NSArray *tracks = [dataManager convertAndAddTracksToDatabase:array];
        if (userManager.isLoggedIn) {
            userManager.userInfo.trendingTracks = [NSOrderedSet orderedSetWithArray:tracks];
        } else {
            dataManager.getAnonUserInfo.trendingTracks = [NSOrderedSet orderedSetWithArray:tracks];
        }
        [self tracksDownloaded:tracks];
    } failureBlock:^(NSString *errorMessage) {
        [self tracksDownloadFailure:errorMessage];
    }];
}

- (NSMutableArray*)getOnlyAudioTracks:(NSArray*)tracks{
    NSMutableArray* array = [NSMutableArray array];
    for (MFTrackItem* track in tracks) {
        if (!track.isYoutubeTrack) {
            [array addObject:track];
        }
    }
    return array;
}

- (NSMutableArray*)getOnlyVideoTracks:(NSArray*)tracks{
    NSMutableArray* array = [NSMutableArray array];
    for (MFTrackItem* track in tracks) {
        if (track.isYoutubeTrack) {
            [array addObject:track];
        }
    }
    return array;
}
@end
