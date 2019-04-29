//
//  TrackInfoViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/27/15.
//
//

#import "TrackInfoViewController.h"
#import "NDMusicControl.h"
#import "PlaylistsViewController.h"
#import "TrackInfoView.h"
#import "MFTrackItem+Behavior.h"
#import "MFCommentTableCell.h"
#import "MFCommentItem+Behavior.h"
#import "MFActivityItem+Behavior.h"
#import "MFNotificationManager.h"
#import "MGSwipeButton.h"
#import <UIColor+Expanded.h>
#import <Mixpanel.h>
#import "UIImageView+WebCache_FadeIn.h"
#import "MagicalRecord/MagicalRecord.h"

static NSString * const kTrackStateKeyPath = @"trackItem.trackState";

@interface TrackInfoViewController () <TrackInfoViewDelegate, MFCommentViewDelegate>

@property (nonatomic, strong) NDMusicControl *musicControl;

@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic, strong) NSMutableArray *allActivities;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewBottomSpaceConstraint;
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) CGFloat lastOffsetConstant;
@property (nonatomic) BOOL keyboardShown;

@end

@implementation TrackInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setObservers];
    [self setUI];
    [self setupData];
    [self trackStateChanged:(NDMusicConrolStateType)self.trackItem.trackState];
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAtUserAvatar:)];
    [_userImageView addGestureRecognizer:avatarTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    playerManager.videoPlayer.currentViewController = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kTrackStateKeyPath context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.actionsTableView.delegate = nil;
    self.actionsTableView.dataSource = nil;

}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    id newObject = [change objectForKey:NSKeyValueChangeNewKey];
    
    if ([NSNull null] == (NSNull *)newObject) {
        newObject = nil;
    }
    
    if ([kTrackStateKeyPath isEqualToString:keyPath]) {
        [self trackStateChanged:[newObject integerValue]];
    }
}

#pragma mark - Setup

- (void)setObservers
{
    [self addObserver:self forKeyPath:kTrackStateKeyPath
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didKeyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    NSString *notificationStatusBarTappedName = [MFNotificationManager nameForNotification:MFNotificationTypeStatusBarTapped];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didTapOnHeader:)
                                                 name:notificationStatusBarTappedName
                                               object:nil];
}

- (void)setUI
{
    self.actionsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self setupTrackInfoView];
    [self setupImageViews];
    [self setupMusicControl];
}

- (void)setupTrackInfoView
{
    self.trackInfoView = [TrackInfoView createTrackInfoView];
    self.trackInfoView.track = self.trackItem;
    self.trackInfoView.trackInfoViewDelegate = self;
    [self.trackInfoView setFrame:self.trackView.bounds];
    [self.trackView addSubview:self.trackInfoView];

}

- (void)setupImageViews
{
    NSURL* imageUrl = [NSURL URLWithString:self.trackItem.trackPicture];
    [self.trackImageView setImage:[UIImage imageNamed:@"DefaultArtwork"]];
    [self.trackImageView sd_setImageAndFadeOutWithURL:imageUrl
                                         placeholderImage:[UIImage imageNamed:@"DefaultArtwork"]];
    if (self.trackItem.isYoutubeTrack) {
        self.artworkRightConstraint.constant = 0.0;
        self.artworkLeftConstraint.constant = 0.0;
        self.artworkHeightConstraint.constant = 233.0;
        CGRect frame = self.containerViewInsideTableView.frame;
        frame.size.height = 150+self.artworkHeightConstraint.constant;
        self.containerViewInsideTableView.frame = frame;
    } else {
        self.artworkRightConstraint.constant = 19.0;
        self.artworkLeftConstraint.constant = 19.0;
        self.artworkHeightConstraint.constant = [UIScreen mainScreen].bounds.size.width - 2*19;
        CGRect frame = self.containerViewInsideTableView.frame;
        frame.size.height = 150+self.artworkHeightConstraint.constant;
        self.containerViewInsideTableView.frame = frame;
    }
    [self.view layoutIfNeeded];
    [self.userImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:userManager.userInfo.profileImage relativeToURL:BASE_URL]];
    [self.userImageView.layer setCornerRadius:(self.userImageView.frame.size.width / 2)];
    [self.userImageView setClipsToBounds:YES];
}

- (void)setupMusicControl
{
    CGFloat musicControlSize = 50;
    _musicControl = [[NDMusicControl alloc] initWithFrame:CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds) - musicControlSize/2,
                                                                     CGRectGetMidY(self.trackImageView.frame) - musicControlSize/2,
                                                                     musicControlSize,
                                                                     musicControlSize)];
    _musicControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [_musicControl addTarget:self action:@selector(didTouchUpMusicControl) forControlEvents:UIControlEventTouchUpInside];
    
    [self.upperView addSubview:_musicControl];
}

- (void)setupData
{
    self.activities = [[NSMutableArray alloc] init];
    [self setActivitiesFromCache];
    [self downloadActivities];
}
- (void)setActivitiesFromCache{
    _allActivities = [[self.trackItem.activities allObjects] mutableCopy];
    [self sortActivities];
    [_actionsTableView reloadData];
    [self updateUI];
}
- (void) sortActivities{
    if (!_isShowingOnlyComments) {
        
        NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
        [_allActivities sortUsingDescriptors:@[sortOrder]];
        
        NSMutableArray* usersID = [[NSMutableArray alloc] init];
        NSMutableArray* tempArray = [[NSMutableArray alloc] init];
        for (MFActivityItem* item in _allActivities) {
            if (![usersID containsObject:item.userFacebookId]){
                [usersID addObject:item.userFacebookId];
                [tempArray addObject:item];
            }
        }
        
        if (self.allActivities.lastObject && ![tempArray containsObject:self.allActivities.lastObject]) {
            [tempArray addObject: self.allActivities.lastObject];
        }
        
        _activities = tempArray;
        _activities = [[[_activities objectEnumerator] allObjects] mutableCopy];
        
    } else {
        
        NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
        [_allActivities sortUsingDescriptors:@[sortOrder]];
        NSMutableArray* tempArray = [[NSMutableArray alloc] init];
        for (MFActivityItem* item in _allActivities) {
            if (item.type == IRActivityTypeComment){
                [tempArray addObject:item];
            }
        }
        _activities = tempArray;
        _activities = [[[_activities objectEnumerator] allObjects] mutableCopy];
        
    }
    
}

-(void) updateUI{
    if (self.actionsTableView.contentSize.height < CGRectGetHeight(self.actionsTableView.frame)) {
        //self.tableViewBottomSpaceConstraint.constant = [UIScreen mainScreen].bounds.size.height - CGRectGetMinY(self.actionsTableView.frame) - self.actionsTableView.contentSize.height - 50.0f;
    }
    
    //CGFloat height = CGRectGetHeight(self.inputView.frame) - 50.0f;
    if (!self.container.isPlayerViewHidden) {
        self.tableViewBottomSpaceConstraint.constant = PLAYER_VIEW_HEIGHT;
        //height += PLAYER_VIEW_HEIGHT;
    }
    
    //self.tableViewBottomSpaceConstraint.constant = self.tableViewBottomSpaceConstraint.constant > height ? height : self.tableViewBottomSpaceConstraint.constant < 0 - 50.0f ? 0 - 50.0f : self.tableViewBottomSpaceConstraint.constant;
    
    [self.view layoutIfNeeded];
    
//    if ([self.actionsTableView numberOfRowsInSection:0]) {
//        [self.actionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
}

- (void)downloadActivities
{
    [[IRNetworkClient sharedInstance] getActivitiesByTrackId:self.trackItem.itemId
                                                   withEmail:userManager.userInfo.email
                                                       token:userManager.fbToken
                                                successBlock:^(NSArray *array) {
                                                    NSMutableArray *activities = [[dataManager convertAndAddActivityItemsToDatabase:array] mutableCopy];
                                                    
                                                    
                                                    self.trackItem.activities = [NSSet setWithArray:activities];
                                                    
                                                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
                                                    _allActivities = [[[NSArray alloc] initWithArray:activities] mutableCopy];
                                                    _activities = activities;
                                                    
                                                    [self sortActivities];
                                                    
                                                    [_actionsTableView reloadData];
                                                    
                                                    [self updateUI];
                                                }
                                                failureBlock:^(NSString *errorMessage) {
                                                    
                                                }];
}

#pragma mark - TableView Delegate & Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.activities.count>0 && [(MFActivityItem*)self.activities.lastObject type]==IRActivityTypeComment && !self.isShowingOnlyComments) {
        return self.activities.count+1;
    }
    return self.activities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.activities.count) {
        return [MFCommentTableCell heightForActivity:_activities[indexPath.row]];
    }
    return 40.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"MFCommentTableCell";
    
    MFCommentTableCell *cell = (MFCommentTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[MFCommentTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [cell setCommentDelegate:self];
    
    if (indexPath.row == 0) {
        [cell setSeparatorViewHidden:YES];
    } else {
        [cell setSeparatorViewHidden:NO];
    }
    
    if (indexPath.row < self.activities.count) {
        MFActivityItem* activityItem = self.activities[indexPath.row];
        [cell setActivityInfo:activityItem];
        
        if ([activityItem.userExtId isEqualToString:userManager.userInfo.extId] && activityItem.type == IRActivityTypeComment) {
            MGSwipeButton *swipeButtonRemove = [MGSwipeButton buttonWithTitle:@"remove"
                                                              backgroundColor:[UIColor colorWithRGBHex:kOffWhiteColor]
                                                                     callback:^BOOL(MGSwipeTableCell *sender) {
                                                                         [self deleteCommentActivity:activityItem];
                                                                         return YES;
                                                                     }];
            [swipeButtonRemove setTitleColor:[UIColor colorWithRGBHex:kBrandPinkColor] forState:UIControlStateNormal];
            [swipeButtonRemove.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
            
            UIPanGestureRecognizer *removePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
            [swipeButtonRemove addGestureRecognizer:removePanRecognizer];
            
            cell.rightButtons =  @[swipeButtonRemove];
            cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
            MGSwipeExpansionSettings* sws = [[MGSwipeExpansionSettings alloc] init];
            sws.buttonIndex = 0;
            sws.fillOnTrigger = YES;
            sws.threshold = 1.5;
            cell.rightExpansion = sws;
            
        } else {
            
            cell.rightButtons = nil;
            cell.rightExpansion = nil;
            
        }
    } else {
        MFActivityItem* prevItem = self.activities.lastObject;
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate* createdAt = [dateFormatter dateFromString:prevItem.createdAtString];
        NSMutableDictionary* dictionaty = [[NSMutableDictionary alloc] init];
        if (prevItem.userName) {
            [dictionaty setObject:prevItem.userName forKey:@"userName"];
        }
        if ([createdAt timeAgo]) {
            [dictionaty setObject:[createdAt timeAgo] forKey:@"postDate"];
        }
        if (prevItem.userAvatarUrl) {
            [dictionaty setObject:prevItem.userAvatarUrl forKey:@"userAvatarUrl"];
        }
        if (prevItem.userExtId) {
            [dictionaty setObject:prevItem.userExtId forKey:@"userId"];
        }
        
        [cell setInitialPostDateInfo:dictionaty];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if ([(MFActivityItem*)self.activities[indexPath.row] type] == IRActivityTypePlaylist) {
//        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:((MFActivityItem*)self.activities[indexPath.row]).userExtId];
//        [self shouldOpenPlaylist:[((MFActivityItem*)self.activities[indexPath.row]).playlist ofUser:userInfo];
//    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (!self.keyboardShown && (self.actionsTableView.contentSize.height >= CGRectGetHeight(self.actionsTableView.frame) - CGRectGetHeight(self.inputView.frame))) {
//        CGPoint velocity = [[scrollView panGestureRecognizer] velocityInView:scrollView.superview];
//        if (velocity.y == 0) {
//            return;
//        }
//        
//        self.tableViewBottomSpaceConstraint.constant = self.lastOffsetConstant + (scrollView.contentOffset.y - self.lastContentOffset);
//        CGFloat height = CGRectGetHeight(self.inputView.frame) - 50.0f;
//        if (!self.container.isPlayerViewHidden) {
//            self.tableViewBottomSpaceConstraint.constant = self.tableViewBottomSpaceConstraint.constant + PLAYER_VIEW_HEIGHT;
//            height += PLAYER_VIEW_HEIGHT;
//        }
//        
//        self.tableViewBottomSpaceConstraint.constant = self.tableViewBottomSpaceConstraint.constant > height ? height : self.tableViewBottomSpaceConstraint.constant < 0 - 50.0f ? 0 - 50.0f : self.tableViewBottomSpaceConstraint.constant;
//    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _lastContentOffset = scrollView.contentOffset.y;
    _lastOffsetConstant = self.tableViewBottomSpaceConstraint.constant;
}

#pragma mark - Button Touches

- (IBAction)didTouchUpBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTouchUpCloseButton:(id)sender
{
    [self.commentTextField resignFirstResponder];
}

#pragma mark - Other actions

- (void)didTouchUpMusicControl
{
    if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(didSelectPlay:)]) {
        [self.playDelegate didSelectPlay:self.trackItem];
        //self.tableViewBottomSpaceConstraint.constant = self.tableViewBottomSpaceConstraint.constant > 50.0f - PLAYER_VIEW_HEIGHT ? 50.0f - PLAYER_VIEW_HEIGHT : self.tableViewBottomSpaceConstraint.constant;
        self.tableViewBottomSpaceConstraint.constant = PLAYER_VIEW_HEIGHT;
        [self.view layoutIfNeeded];
    } else {
        [self.container setPlayerViewHidden:NO];
        if (![playerManager.currentTrack isEqual:self.trackItem]) {
            [playerManager playSingleTrack:self.trackItem];
        }
        else if ([playerManager playing]) {
            [playerManager pauseTrack];
        }
        else {
            [playerManager resumeTrack];
        }
        //self.tableViewBottomSpaceConstraint.constant = self.tableViewBottomSpaceConstraint.constant > PLAYER_VIEW_HEIGHT - 50.0f ? PLAYER_VIEW_HEIGHT - 50.0f : self.tableViewBottomSpaceConstraint.constant;
        self.tableViewBottomSpaceConstraint.constant = PLAYER_VIEW_HEIGHT;
        [self.view layoutIfNeeded];
    }
}

- (void)trackStateChanged:(NDMusicConrolStateType)state
{
    [_musicControl changePlayState:state];
}

#pragma mark - TrackInfoView Delegate methods

- (void)didLikeTrack:(MFTrackItem *)track
{
        __block MFTrackItem *trackItem = track;
    [[IRNetworkClient sharedInstance] likeTrackById:track.itemId withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^{
        [self downloadActivities];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:track
                                                             forKey:@"trackItem"];
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayerLikeNotificationEvent
                                                            object:self
                                                          userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:PlaylistLikeNotificationEvent
                                                            object:self
                                                          userInfo:userInfo];
        [MFNotificationManager postTrackLikedNotification:track];
        [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
    } failureBlock:^(NSString *errorMessage) {
        //trackItem.isLiked = NO;
        // TODO: handle error
        [self.trackItem dislikeTrackItem];
        [self.trackInfoView reloadLikes];
    }];
}

- (void)didUnlikeTrack:(MFTrackItem *)track
{
    
    __block MFTrackItem *trackItem = track;
    [[IRNetworkClient sharedInstance] unlikeTrackById:track.itemId withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:track
                                                             forKey:@"trackItem"];
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayerUnlikeNotificationEvent
                                                            object:self
                                                          userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:PlaylistUnlikeNotificationEvent
                                                            object:self
                                                          userInfo:userInfo];
        [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
        [MFNotificationManager postTrackDislikedNotification:track];
        [self downloadActivities];
    } failureBlock:^(NSString *errorMessage) {
        //trackItem.isLiked = YES;
        // TODO: handle error
        [self.trackItem likeTrackItem];
        [self.trackInfoView reloadLikes];
    }];
}

- (void)didSelectShare:(MFTrackItem *)track
{
    self.trackItem = track;
    [self showSharing];
}

- (void)didSelectDownload:(MFTrackItem *)track
{
    self.trackItem = track;
    [self buyWithITunes];
}

- (void)didAddTrackToPlaylist:(MFTrackItem *)track
{
    PlaylistsViewController *playlistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
    playlistsVC.container = self.container;
    playlistsVC.trackToAdd = track;
    
    [self.navControllerToPush pushViewController:playlistsVC animated:YES];
}

- (void)shouldShowComments:(MFTrackItem *)track
{
//    CommentsViewController *commentsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
//    [commentsVC setTrackItem:self.trackItem];
//    [commentsVC setDelegate:self];
//    commentsVC.container = self.container;
//    
//    [self.navControllerToPush pushViewController:commentsVC animated:YES];
    
    self.isShowingOnlyComments = !self.isShowingOnlyComments;
    [self sortActivities];
    [self.actionsTableView reloadData];
}

- (void)shouldOpenAuthorProfile:(MFTrackItem *)track
{
    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:track.authorExtId];
    userInfo.username = track.username;
    userInfo.extId = track.authorExtId;
    [self showUserProfileWithUserInfo:userInfo];
}

#pragma mark - Comments methods

- (void)sendComment:(NSString *)comment
{
    [[IRNetworkClient sharedInstance]postTrackCommentById:self.trackItem.itemId
                                                  comment:comment
                                                withEmail:userManager.userInfo.email
                                                    token:userManager.fbToken
                                             successBlock:^{
                                                 BOOL notFirstComment = NO;
                                                 for (MFActivityItem* item in _activities){
                                                     if ((item.type == IRActivityTypeComment)&&[item.userFacebookId isEqualToString:userManager.userInfo.facebookID]) notFirstComment = YES;
                                                 }
                                                 
                                                 if (!notFirstComment) {
                                                     
                                                     [[Mixpanel sharedInstance] track:@"Track commented" properties:@{@"track": self.trackItem.trackName,
                                                                                                                                        @"author" : self.trackItem.authorName,
                                                                                                                                        @"trackID": self.trackItem.itemId,
                                                                                                                                        @"authorID": self.trackItem.authorId}];
                                                     [FBSDKAppEvents logEvent:@"Track commented" parameters:@{@"track": self.trackItem.trackName,
                                                                                                              @"author" : self.trackItem.authorName,
                                                                                                              @"trackID": self.trackItem.itemId,
                                                                                                              @"authorID": self.trackItem.authorId}];
                                                 }
                                                 
                                                 [self.trackItem addComment];
                                                 [MFNotificationManager postCommentsCountChangedNotification:self.trackItem];
                                                 [self downloadActivities];
                                             } failureBlock:^(NSString *errorMessage) {
                                                 
                                             }];
}

- (void)deleteCommentActivity:(MFActivityItem *)activityItem {
    
    if  ([_activities containsObject:activityItem]){
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[_activities indexOfObject:activityItem] inSection:0];
        
        MFActivityItem* itemToRemove = self.activities[indexPath.row];
        
        
        if (self.trackItem.itemId && activityItem.eventableId) {
            [[IRNetworkClient sharedInstance] removeTrackCommentByID:self.trackItem.itemId
                                                           commentID:activityItem.itemId
                                                        successBlock:^{
                                                            [_activities removeObjectAtIndex:indexPath.row];
                                                            [_allActivities removeObject:activityItem];
                                                            NSLog(@"REMOVING FROM FEED %ld %@", [_activities count], activityItem.comment);
                                                            [_actionsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                            [self.trackItem removeComment];
                                                            [MFNotificationManager postCommentsCountChangedNotification:self.trackItem];

                                                        }
                                                        failureBlock:^(NSString *errorMessage){
                                                            [self showErrorMessage:@"Can't remove comment"];
                                                            //[_activities addObject:itemToRemove];
                                                        }];
        }
    }
}

#pragma mark - UITextField actions

- (IBAction)didTextFieldSelectDone:(id)sender
{
    
    if (![self.commentTextField.text isEqualToString:@""]) {
        [self sendComment:self.commentTextField.text];
    }
    
    [self.commentTextField resignFirstResponder];
    self.commentTextField.text = @"";
    
}

#pragma mark - Keyboard actions

- (void)didKeyboardShow:(NSNotification*)notification
{
    self.keyboardShown = YES;
    [self.closeButton setHidden:NO];
    
    NSDictionary* info = [notification userInfo];
    CGRect keyRect;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyRect];
    CGFloat height = keyRect.size.height;
    [self.view layoutIfNeeded];
    self.tableViewBottomSpaceConstraint.constant = height;
    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
    }];
    if (self.activities.count > 0) {
        [self.actionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else {
        [self.actionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)didKeyboardHide:(NSNotification*)notification
{
    self.keyboardShown = NO;
    [self.closeButton setHidden:YES];
    
    self.tableViewBottomSpaceConstraint.constant = 0;
    if (self.actionsTableView.contentSize.height < [UIScreen mainScreen].bounds.size.height - CGRectGetMinY(self.actionsTableView.frame)) {
        //self.tableViewBottomSpaceConstraint.constant = [UIScreen mainScreen].bounds.size.height - CGRectGetMinY(self.actionsTableView.frame) - self.actionsTableView.contentSize.height - 50.0f;
    }
    //CGFloat height = CGRectGetHeight(self.inputView.frame) - 50.0f;
    if (!self.container.isPlayerViewHidden) {
        self.tableViewBottomSpaceConstraint.constant =PLAYER_VIEW_HEIGHT;
        //height += PLAYER_VIEW_HEIGHT;
    }
    
    //self.tableViewBottomSpaceConstraint.constant = self.tableViewBottomSpaceConstraint.constant > height ? height : self.tableViewBottomSpaceConstraint.constant < 0 - 50.0f ? 0 - 50.0f : self.tableViewBottomSpaceConstraint.constant;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
    }];
    //[self.actionsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - MFCommentViewDelegate methods

- (void)shouldOpenUserProfileWithUserInfo:(MFUserInfo *)userInfo
{
    [self showUserProfileWithUserInfo:userInfo];
}

#pragma mark - Tap Events

- (void)didTapAtUserAvatar:(id)sender
{
    [self showUserProfileWithUserInfo:userManager.userInfo];
}

#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender
{
    [self.actionsTableView scrollRectToVisible:CGRectMake(0, 0, _actionsTableView.tableHeaderView.frame.size.width, _actionsTableView.tableHeaderView.frame.size.height) animated:YES];
}

@end
