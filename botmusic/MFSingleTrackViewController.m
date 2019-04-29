//
//  MFSingleTrackViewController.m
//  botmusic
//
//  Created by Panda Systems on 11/10/15.
//
//

#import "MFSingleTrackViewController.h"
#import "MFTrackPosterCollectionViewCell.h"
#import "UIColor+Expanded.h"
#import "UIImageView+WebCache_FadeIn.h"
#import "MFTrackItem.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MFActivityItem+Behavior.h"
#import "MFNewCommentTableViewCell.h"
#import "NDMusicControl.h"
#import "Mixpanel.h"
#import "MFNotificationManager.h"
#import "PlaylistsViewController.h"
#import "MFPlayerAnimationView.h"
#import "MFNotificationManager.h"

static NSString * const kTrackStateKeyPath = @"track.trackState";

@interface MFSingleTrackViewController () <UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UIGestureRecognizerDelegate, MFNewCommentTableViewCellDelegate,UITextViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *postersCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postersContainerToTop;
@property (weak, nonatomic) IBOutlet UIView *headerContainer;

@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPostersLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCommentsLabel;
@property (weak, nonatomic) IBOutlet UIView *gradientContainer;

@property (weak, nonatomic) IBOutlet UIView *musicControlView;

@property (weak, nonatomic) IBOutlet UIImageView *playButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewToBottom;

@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageToLeading;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;
@property (nonatomic, strong) NSArray* posters;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addCommentTopHeaderTop;
@property (weak, nonatomic) IBOutlet UIView *playingIndicatorContainerView;
@property (strong, nonatomic) MFPlayerAnimationView* playingIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) NSArray* comments;
@property (nonatomic) BOOL isInCommentAddingState;
@property (nonatomic) BOOL scrollBlocker;
@property (nonatomic) CGFloat scrollBlockerOffset;
@property (weak, nonatomic) IBOutlet UIView *darkHeaderView;
@property (weak, nonatomic) IBOutlet UIView *darkPostersView;
@property (strong, nonatomic) MFActivityItem* editedComment;

@property (nonatomic) UITextView* commentTextView;
@end
static UIImage* defaultAvatar;

@implementation MFSingleTrackViewController{
    BOOL _layoutConfigured;
    CGFloat _anchorPoint;
    BOOL _isDragging;
    CGFloat _lastHeight;
    CFTimeInterval _lastTime;
    double _velocity;
    BOOL _buttonsShown;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.postersCollectionView.hidden = YES;
    // Do any additional setup after loading the view.
    [self.commentsTableView registerNib:[UINib nibWithNibName:@"MFNewCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"MFNewCommentTableViewCell"];
    [self.commentsTableView registerNib:[UINib nibWithNibName:@"MFNewMyCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"MFNewMyCommentTableViewCell"];

    self.commentsTableView.rowHeight = UITableViewAutomaticDimension;
    self.commentsTableView.estimatedRowHeight = 90.0;
    [self.view addGestureRecognizer:self.commentsTableView.panGestureRecognizer];
    [self configureForTrack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self makePostersAndCommentsFromActivities:[_track.activities allObjects]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.posters.count) {
                self.postersCollectionView.hidden = NO;
            }
            [self updateUI];
        });
    });
    [self downloadActivities];
    self.playingIndicatorView = [MFPlayerAnimationView playerAnimationViewWithFrame:self.playingIndicatorContainerView.bounds color:[UIColor whiteColor]];
    [self.playingIndicatorContainerView addSubview:self.playingIndicatorView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didKeyboardShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(like:)
                                                 name:[MFNotificationManager nameForNotification:MFNotificationTypeTrackLiked]
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unlike:)
                                                 name:[MFNotificationManager nameForNotification:MFNotificationTypeTrackDisliked]
                                               object:nil];
    [self addObserver:self forKeyPath:kTrackStateKeyPath
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:nil];
    [self trackStateChanged:self.track.trackState];
    self.trackItem = self.track;
    if (!defaultAvatar) {
        defaultAvatar = [UIImage imageNamed:@"defaultAvatar.jpg"];
    }
}

- (void)downloadActivities
{
    [[IRNetworkClient sharedInstance] getActivitiesByTrackId:self.track.itemId
                                                   withEmail:userManager.userInfo.email
                                                       token:userManager.fbToken
                                                successBlock:^(NSArray *array) {
                                                    NSArray *activities = [dataManager convertAndAddActivityItemsToDatabase:array];

                                                    self.track.activities = [NSSet setWithArray:activities];

                                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                                                        [self makePostersAndCommentsFromActivities:activities];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if (self.postersCollectionView.hidden) {
                                                                self.postersCollectionView.hidden = NO;
                                                                self.postersCollectionView.alpha = 0.0;
                                                                [UIView animateWithDuration:0.3 animations:^{
                                                                    self.postersCollectionView.alpha = 1.0;
                                                                }];
                                                            }
                                                            [self updateUI];
                                                        });
                                                    });
                                                }
                                                failureBlock:^(NSString *errorMessage) {
                                                    [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

                                                    [self updateUI];
                                                }];
}

- (void)updateUI{
    self.isInCommentAddingState = NO;
    CGPoint offset = self.commentsTableView.contentOffset;
    [self.commentsTableView reloadData];
    [self.commentsTableView layoutIfNeeded];
    [self.commentsTableView setContentOffset:offset];
    [self.postersCollectionView reloadData];
    self.numberOfPostersLabel.text = [NSString stringWithFormat:NSLocalizedString(@"POSTERS (%lu)", nil), self.posters.count];
    self.numberOfCommentsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"COMMENTS (%lu)", nil), self.comments.count];
}

- (void)makePostersAndCommentsFromActivities:(NSArray*)activities{
    NSMutableArray* posters = [NSMutableArray array];
    NSMutableArray* comments = [NSMutableArray array];
    NSMutableArray* postersExtIDs = [NSMutableArray array];

    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    NSMutableArray* sortedActivities = [activities mutableCopy];
    [sortedActivities sortUsingDescriptors:@[sortOrder]];

    for (MFActivityItem* activity in sortedActivities) {
        if (activity.type == IRActivityTypeComment) {
            [comments addObject:activity];
        }
        if ((activity.type == IRActivityTypePlaylist || activity.type == IRActivityTypeUserLike) && ![postersExtIDs containsObject:activity.userExtId]) {

            [posters addObject:@{@"name": activity.userName,
                                 @"extId":activity.userExtId,
                                 @"avatar": activity.userAvatarUrl,
                                }];
            [postersExtIDs addObject:activity.userExtId];
        }
    }

    MFActivityItem* oldestActivity = sortedActivities.lastObject;
    if (oldestActivity && ![postersExtIDs containsObject:oldestActivity.userExtId]) {

        [posters addObject:@{@"name": oldestActivity.userName,
                             @"extId":oldestActivity.userExtId,
                             @"avatar": oldestActivity.userAvatarUrl,
                             }];
    }


    _posters = [[posters reverseObjectEnumerator].allObjects copy];
    _comments = [comments copy];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!_layoutConfigured) {
        self.headerContainerHeight.constant = [UIScreen mainScreen].bounds.size.width;
        self.postersContainerToTop.constant = [UIScreen mainScreen].bounds.size.width;
        self.commentsTableView.contentInset = UIEdgeInsetsMake(self.headerContainerHeight.constant + 155, 0, 50 + self.tabBarController.tabBar.bounds.size.height, 0);
        self.commentsTableView.contentOffset = CGPointMake(0, - self.commentsTableView.contentInset.top);


        _buttonsWidth.constant = [UIScreen mainScreen].bounds.size.width*0.27;
        [self makeGradient];
        _layoutConfigured = YES;
    }
}


- (void)configureForTrack{
    [self.artworkImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:_track.trackPicture]];
    self.trackNameLabel.text = _track.trackName;
    if (self.track.isLiked) {
        self.likeButton.selected = YES;
    }

}

- (void)makeGradient{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/2.0);
    UIColor *startColour = [UIColor colorWithWhite:0.0 alpha:0.75];
    UIColor *endColour = [UIColor colorWithWhite:0.0 alpha:0.0];
    [gradient setStartPoint:CGPointMake(0.5, 0.0)];
    [gradient setEndPoint:CGPointMake(0.5, 1.0)];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [_gradientContainer.layer addSublayer:gradient];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (self.isInCommentAddingState) {
            return 1;
        } else {
            return 0;
        }
    }

    return _comments.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        MFNewCommentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MFNewMyCommentTableViewCell"];
        cell.commentField.text = @"";
        self.commentTextView = cell.commentField;
        self.commentTextView.delegate = self;
        //[cell.avatatarImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:userManager.userInfo.profileImage] placeholderImage:defaultAvatar];
        [cell.avatatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:userManager.userInfo.profileImage] name:userManager.userInfo.name];
        cell.nameLabel.text = userManager.userInfo.name;
        cell.timeLabel.hidden = YES;
        cell.delegate = self;
        cell.darkView.alpha = 0.0;
        if (self.isInCommentAddingState) {
            cell.underlyingDarkView.alpha = 0.7;
            dispatch_async(dispatch_get_main_queue(),^{
                self.commentTextView.editable = YES;
                cell.commentField.selectable = YES;
                [self.commentTextView becomeFirstResponder];
            });
        } else {
            cell.underlyingDarkView.alpha = 0.0;
        }

        return cell;
    }

    MFActivityItem* comment = _comments[indexPath.row];
    MFNewCommentTableViewCell* cell;
    if ([comment.userExtId isEqualToString:userManager.userInfo.extId]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MFNewMyCommentTableViewCell"];
        cell.commentField.textColor = [UIColor whiteColor];
        cell.isMyComment = YES;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MFNewCommentTableViewCell"];
        cell.isMyComment = NO;
    }
    cell.commentField.text = comment.comment;
    cell.commentField.editable = NO;
    cell.commentField.selectable = NO;
    //[cell.avatatarImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:comment.userAvatarUrl] placeholderImage:defaultAvatar];
    [cell.avatatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:comment.userAvatarUrl] name:comment.userName];
    cell.nameLabel.text = comment.userName;
    cell.timeLabel.hidden = NO;
    cell.timeLabel.text = comment.postTimeLongStyle;
    cell.delegate = self;
    cell.darkView.alpha = 0.0;
    cell.underlyingDarkView.alpha = 0.0;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _posters.count;
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MFTrackPosterCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MFTrackPosterCollectionViewCell" forIndexPath:indexPath];
    NSDictionary* poster = _posters[indexPath.row];
    //[cell.avatarImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:poster[@"avatar"]] placeholderImage:defaultAvatar];
    [cell.avatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:poster[@"avatar"]] name:poster[@"name"]];
    cell.nameLabel.text = poster[@"name"];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary* poster = _posters[indexPath.row];
    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:poster[@"extId"]];
    userInfo.username = poster[@"name"];
    userInfo.profileImage = poster[@"avatar"];
    [self showUserProfileWithUserInfo:userInfo];
}

-(void) didTappedAvatarAtCell:(UITableViewCell *)cell{
    NSIndexPath* ip = [self.commentsTableView indexPathForCell:cell];
    MFActivityItem* activity = _comments[ip.row];
    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:activity.userExtId];
    userInfo.username = activity.userName;
    userInfo.profileImage = activity.userAvatarUrl;
    [self showUserProfileWithUserInfo:userInfo];
}

- (void) didSelectDeleteComment:(MFNewCommentTableViewCell *)cell{
    NSIndexPath* ip = [self.commentsTableView indexPathForCell:cell];
    MFActivityItem* comment = self.comments[ip.row];
    if (!comment) {
        return;
    }

    NSMutableArray* array = [self.comments mutableCopy];
    if ([array containsObject:comment]) {
        [array removeObject:comment];
        self.comments = [array copy];

        //CGPoint offset = self.commentsTableView.contentOffset;
        [self.commentsTableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self.commentsTableView setContentOffset:offset animated:NO];
    }


    [[IRNetworkClient sharedInstance] removeTrackCommentByID:self.track.itemId commentID:comment.itemId successBlock:^{


    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

    }];
}

- (void) didSelectEditComment:(MFNewCommentTableViewCell *)cell{
//    CGFloat offset = [self.commentsTableView rectForRowAtIndexPath:[self.commentsTableView indexPathForCell:cell]].origin.y;
//
//    cell.commentField.editable = YES;
//    [cell.commentField becomeFirstResponder];
//    self.commentsTableView.scrollEnabled = NO;
////    self.scrollBlocker = YES;
//    self.scrollBlockerOffset = -130 - 9 + offset;
//
//    [self.commentsTableView setContentOffset:CGPointMake(0.0, -130 - 9 + offset) animated:YES];
//    self.commentTextView = cell.commentField;
//    cell.commentField.delegate = self;
//
//    //[UIView animateWithDuration:0.25 animations:^{
//        self.darkHeaderView.alpha = 0.7;
//        self.darkPostersView.alpha = 0.7;
//        self.commentsTableView.backgroundColor = [UIColor colorWithRGBHex:0x454545];
//        for (MFNewCommentTableViewCell* tablecell in self.commentsTableView.visibleCells) {
//            if (tablecell != cell) {
//                tablecell.darkView.alpha = 0.7;
//            }
//        }
//        cell.underlyingDarkView.alpha = 0.7;
//    //}];


    NSIndexPath* ip = [self.commentsTableView indexPathForCell:cell];
    MFActivityItem* comment = self.comments[ip.row];
    if (!comment) {
        return;
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit comment"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];

    alert.alertViewStyle = UIAlertViewStylePlainTextInput;

    [alert show];

    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = cell.commentField.text;
    self.editedComment = comment;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        NSInteger index = [self.comments indexOfObject:self.editedComment];
        if (index != NSNotFound) {
            MFNewCommentTableViewCell* cell = [self.commentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
            UITextField *field = [alertView textFieldAtIndex:0];
            cell.commentField.text = field.text;
            [[IRNetworkClient sharedInstance] editTrackCommentByID:self.track.itemId commentID:self.editedComment.itemId text:field.text successBlock:^{

            } failureBlock:^(NSString *errorMessage) {
                [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

            }];
        }

    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _commentsTableView) {
        if (self.scrollBlocker) {
            [scrollView setContentOffset:CGPointMake(0, self.scrollBlockerOffset) animated:NO];
        }
        
        CGFloat offset = scrollView.contentOffset.y;
        _postersContainerToTop.constant = - offset - 155;
        CGFloat height = - offset - 155;
        if (height < 130) {
            height = 130;
        }
        _headerContainerHeight.constant = height;
        CGFloat maxHeight = _headerContainer.bounds.size.width;
        self.musicControlView.alpha = (height - maxHeight*0.75)/(maxHeight*0.25);
    }
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    id newObject = [change objectForKey:NSKeyValueChangeNewKey];

    if ([NSNull null] == (NSNull*)newObject)
        newObject = nil;

    if ([kTrackStateKeyPath isEqualToString:keyPath]) {
        [self trackStateChanged:[newObject integerValue]];
    }
}

- (void)trackStateChanged:(NDMusicConrolStateType)state {
    switch (state) {
        case NDMusicConrolStateTypeNotStarted:
            self.playButton.hidden = NO;
            self.playingIndicatorView.hidden = YES;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypeLoading:
            self.playButton.hidden = YES;
            self.playingIndicatorView.hidden = YES;
            [self.activityIndicator startAnimating];
            break;
        case NDMusicConrolStateTypeFailed:
            self.playButton.hidden = NO;
            self.playingIndicatorView.hidden = YES;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypePaused:
            self.playButton.hidden = YES;
            self.playingIndicatorView.hidden = NO;
            [self.playingIndicatorView stopAnimating];
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypePlaying:
            self.playButton.hidden = YES;
            self.playingIndicatorView.hidden = NO;
            [self.playingIndicatorView startAnimating];
            [self.activityIndicator stopAnimating];

            break;
        default:
            break;
    }
}

- (IBAction)trackTapped:(id)sender {

    if (![playerManager.currentTrack isEqual:self.track]) {
        [playerManager playSingleTrack:self.track];
    }
    else if ([playerManager playing]) {
        [playerManager pauseTrack];
    }
    else {
        [playerManager resumeTrack];
    }
}

- (void)dealloc
{
    if (self.isViewLoaded) {
        [self removeObserver:self
                  forKeyPath:kTrackStateKeyPath
                     context:nil];
    }
    [self.playingIndicatorView stopAnimating];
}

- (void)didKeyboardShow:(NSNotification*)notification
{


}

- (void)didKeyboardHide:(NSNotification*)notification
{

}

- (void)postComment:(NSString*)comment{
    [[IRNetworkClient sharedInstance]postTrackCommentById:self.track.itemId
                                                  comment:comment
                                                withEmail:userManager.userInfo.email
                                                    token:userManager.fbToken
                                             successBlock:^{
                                                 BOOL notFirstComment = NO;
                                                 for (MFActivityItem* item in _comments){
                                                     if ((item.type == IRActivityTypeComment)&&[item.userFacebookId isEqualToString:userManager.userInfo.facebookID]) notFirstComment = YES;
                                                 }

                                                 if (!notFirstComment) {

                                                     [[Mixpanel sharedInstance] track:@"Track commented" properties:@{@"track": self.track.trackName,
                                                                                                                      @"author" : self.track.authorName,
                                                                                                                      @"trackID": self.track.itemId,
                                                                                                                      @"authorID": self.track.authorId}];
                                                     [FBSDKAppEvents logEvent:@"Track commented" parameters:@{@"track": self.track.trackName,
                                                                                                              @"author" : self.track.authorName,
                                                                                                              @"trackID": self.track.itemId,
                                                                                                              @"authorID": self.track.authorId}];
                                                 }

                                                 [self.track addComment];
                                                 [MFNotificationManager postCommentsCountChangedNotification:self.track];
                                                 [self downloadActivities];

                                             } failureBlock:^(NSString *errorMessage) {
                                                 [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

                                                 [self updateUI];
                                             }];
}

- (IBAction)imagePanned:(UIPanGestureRecognizer *)sender {

    CGPoint loc1 = [sender locationInView:_imageContainer];


    if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled) {

        CGFloat maxSize = _headerContainer.bounds.size.width*0.81;
        CGFloat phase = _imageToLeading.constant/maxSize;

        if (_buttonsShown) {
            if (phase<1.0) {
                if (_velocity<150) {
                    CGFloat time = ABS(phase*maxSize/((CGFloat)_velocity));
                    if (time>0.3) time = 0.3f;
                    [self hideButtons:time];
                } else {
                    CGFloat time = ABS((1.0f-phase)*maxSize/(CGFloat)_velocity);
                    if (time>0.3) time = 0.3f;
                    [self showButtons:time];
                }
            } else {
                [self showButtons:0.3f];
            }
        } else {
            if (phase>0.0) {
                if (_velocity<-150) {
                    CGFloat time = ABS(phase*maxSize/((CGFloat)_velocity));
                    if (time>0.3) time = 0.3f;
                    [self hideButtons:time];
                } else {
                    CGFloat time = ABS((1.0f-phase)*maxSize/(CGFloat)_velocity);
                    if (time>0.3) time = 0.3f;
                    [self showButtons:time];
                }
            } else {
                [self hideButtons:0.3f];
            }
        }
        _velocity=0;
        _isDragging = NO;

    } else {
        CGPoint loc2 = [sender locationInView:_headerContainer];
        if (!_isDragging) {
            _isDragging = YES;
            _anchorPoint = loc1.x;
        }
        CGFloat currentHeight = loc2.x - _anchorPoint;
        if (currentHeight<0) {
            currentHeight=0;
        }
        CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
        _velocity = (currentHeight - _lastHeight)/(currentTime - _lastTime);
        _lastTime = currentTime;
        _lastHeight = currentHeight;
        _imageToLeading.constant = currentHeight;
    }

}

- (void) showButtons:(CGFloat)time{
    _buttonsShown = YES;
    [self.headerContainer layoutIfNeeded];
    _imageToLeading.constant = _headerContainer.bounds.size.width*0.81;
    [UIView animateWithDuration:time delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.headerContainer layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void) hideButtons:(CGFloat)time{
    _buttonsShown = NO;
    [self.headerContainer layoutIfNeeded];
    _imageToLeading.constant = 0.0;
    [UIView animateWithDuration:time delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.headerContainer layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self.headerContainer];
    return fabs(velocity.y) < fabs(velocity.x);
}

- (IBAction)moreButtonTapped:(id)sender {
    [self showButtons:0.3];
}

- (IBAction)postButtonTapped:(id)sender {
    //[[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Our server doesn't support posting yet" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];

    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }
    [[IRNetworkClient sharedInstance] publishTrackByID:self.track.itemId SuccessBlock:^(NSDictionary *dictionary) {
        [[MFMessageManager sharedInstance] showTrackRepostedMessageInViewController:self.tabBarController];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

    }];

    [self hideButtons:0.3];
}

- (IBAction)addButtonTapped:(id)sender {
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }
    PlaylistsViewController *playlistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
    playlistsVC.container = self.container;
    playlistsVC.trackToAdd = self.track;
    [self.navControllerToPush pushViewController:playlistsVC animated:YES];
    [self hideButtons:0.3];
}

- (IBAction)shareButtonTapped:(id)sender {
    if (!userManager.isLoggedIn) {
        [MFNotificationManager postUserUnauthorizedNotification];
        return;
    }
    [self showSharing];
    [self hideButtons:0.3];
}

- (IBAction)addCommentTapped:(id)sender {
    if (!self.isInCommentAddingState) {

        self.scrollBlocker = YES;
        self.scrollBlockerOffset = -130 - 9;
        UIEdgeInsets insets = self.commentsTableView.contentInset;
        insets.bottom = 1380;
        self.commentsTableView.contentInset = insets;
        [self.commentsTableView setContentOffset:CGPointMake(0.0, -130 - 9) animated:NO];
        self.isInCommentAddingState = YES;
        if (_buttonsShown) {
            [self hideButtons:0.3];
        }
        self.headerContainer.userInteractionEnabled = NO;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.addCommentTopHeaderTop.constant = -40.0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {

        }];
        self.darkHeaderView.alpha = 0.7;
        self.darkPostersView.alpha = 0.7;
        self.commentsTableView.backgroundColor = [UIColor colorWithRGBHex:0x454545];
        for (MFNewCommentTableViewCell* cell in self.commentsTableView.visibleCells) {
            if ([_commentsTableView indexPathForCell:cell].section != 0) {
                cell.darkView.alpha = 0.7;
            }
        }
        ((MFNewCommentTableViewCell*)[_commentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]).underlyingDarkView.alpha = 0.7;


        [self.commentsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.darkHeaderView.alpha = 0.7;
        self.darkPostersView.alpha = 0.7;
        self.commentsTableView.backgroundColor = [UIColor colorWithRGBHex:0x454545];
        for (MFNewCommentTableViewCell* cell in self.commentsTableView.visibleCells) {
            if ([_commentsTableView indexPathForCell:cell].section != 0) {
                cell.darkView.alpha = 0.7;
            }
        }

    }
}

- (void)cancelComment{
    if (self.isInCommentAddingState) {
        self.isInCommentAddingState = NO;
        self.darkHeaderView.alpha = 0.0;
        self.darkPostersView.alpha = 0.0;
        self.commentsTableView.backgroundColor = [UIColor colorWithRGBHex:0xE5E5E5];
        for (MFNewCommentTableViewCell* cell in self.commentsTableView.visibleCells) {
            cell.darkView.alpha = 0.0;
            cell.underlyingDarkView.alpha = 0.0;
        }
        [self.commentsTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.scrollBlocker = NO;
        [self leaveAddCommentState];
    }
}

- (void)sendComment{
    if (self.isInCommentAddingState && ![_commentTextView.text isEqualToString:@""]) {
        self.scrollBlocker = NO;
        [self leaveAddCommentState];
        [UIView animateWithDuration:0.25 animations:^{
            self.darkHeaderView.alpha = 0.0;
            self.darkPostersView.alpha = 0.0;
            self.commentsTableView.backgroundColor = [UIColor colorWithRGBHex:0xE5E5E5];
            for (MFNewCommentTableViewCell* cell in self.commentsTableView.visibleCells) {
                cell.darkView.alpha = 0.0;
                cell.underlyingDarkView.alpha = 0.0;
            }
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self postComment:_commentTextView.text];
        });

    }
}

- (void)leaveAddCommentState{
    _commentTextView.editable = NO;
    [_commentTextView resignFirstResponder];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [[UIApplication sharedApplication] setStatusBarStyle: self.preferredStatusBarStyle animated:YES];
    UIEdgeInsets insets = self.commentsTableView.contentInset;
    insets.bottom = 50 + self.tabBarController.tabBar.bounds.size.height;
    self.commentsTableView.contentInset = insets;

    self.addCommentTopHeaderTop.constant = -125.0;
    self.headerContainer.userInteractionEnabled = YES;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void) textViewDidChange:(UITextView *)textView{
    [self.commentsTableView beginUpdates];
    [self.commentsTableView endUpdates];
}
- (IBAction)postCommentButtonTapped:(id)sender {
    [self sendComment];
}

- (IBAction)cancelCommentButtonTapped:(id)sender {
    [self cancelComment];
}

- (void)didLikeTrack:(MFTrackItem *)track
{


    [[IRNetworkClient sharedInstance]likeTrackById:self.track.itemId
                                         withEmail:userManager.userInfo.email
                                             token:[userManager fbToken]
                                      successBlock:^{
                                          [self.track likeTrackItem];

                                          NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.track
                                                                                               forKey:@"trackItem"];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:PlayerLikeNotificationEvent
                                                                                              object:self
                                                                                            userInfo:userInfo];
                                          [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
                                          [MFNotificationManager postTrackLikedNotification:track];
                                          [self hideTopErrorViewWithMessage:self.kConnectedMessage];
                                      }
                                      failureBlock:^(NSString *errorMessage){
                                          [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                          self.likeButton.selected = NO;
                                      }];
    self.likeButton.selected = YES;
    //[self setTrackInfo:self.track];
}

- (void)didUnlikeTrack:(MFTrackItem *)track
{



    [[IRNetworkClient sharedInstance]unlikeTrackById:self.track.itemId
                                           withEmail:userManager.userInfo.email
                                               token:[userManager fbToken]
                                        successBlock:^{
                                            [self.track dislikeTrackItem];

                                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.track
                                                                                                 forKey:@"trackItem"];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:PlayerUnlikeNotificationEvent
                                                                                                object:self
                                                                                              userInfo:userInfo];
                                            [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
                                            [MFNotificationManager postTrackDislikedNotification:track];

                                            [self hideTopErrorViewWithMessage:self.kConnectedMessage];
                                        }
                                        failureBlock:^(NSString *errorMessage){
                                            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                            self.likeButton.selected = YES;
                                        }];
    
    //[self setTrackInfo:self.track];
    self.likeButton.selected = NO;
}

- (void)like:(NSNotification *)notification {
    NSString *trackID = notification.userInfo[@"trackID"];
    if ([self.track.itemId isEqual:trackID]) {
        self.likeButton.selected = YES;
    }
}

- (void)unlike:(NSNotification *)notification {
    NSString *trackID = notification.userInfo[@"trackID"];
    if ([self.track.itemId isEqual:trackID]) {
        self.likeButton.selected = NO;
    }
}

- (IBAction)likeTapped:(id)sender {
    if (self.likeButton.selected) {
        [self didUnlikeTrack:self.track];
    } else {
        [self didLikeTrack:self.track];
    }
}

@end
