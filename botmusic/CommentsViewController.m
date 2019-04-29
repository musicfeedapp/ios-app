//
//  CommentsViewController.m
//  botmusic
//
//  Created by Supervisor on 05.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "CommentsTrackView.h"
#import "MFCommentTableCell.h"
#import "MFNotificationManager.h"
#import "MGSwipeButton.h"
#import "MFCommentsTrackView.h"
#import <Mixpanel.h>
#import "UIImageView+WebCache_FadeIn.h"
#import "MagicalRecord/MagicalRecord.h"

#define TRACK_VIEW_FRAME CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), COMMENTS_TRACK_VIEW_HEIGHT)

@interface CommentsViewController () <UITextFieldDelegate, MFCommentViewDelegate>


@property (nonatomic, weak) IBOutlet UITableView *commentsTableView;
@property (nonatomic, weak) IBOutlet UIView *trackInfoView;
@property (nonatomic, weak) IBOutlet UIView *inputView;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet MFCommentsTrackView *commentsTrackView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UITextField *commentTextField;
@property (nonatomic, weak) IBOutlet UIView *shadowView;
@property (nonatomic, weak) IBOutlet UIView *swipeView;
@property (nonatomic, weak) IBOutlet UIView *topGradientView;
@property (nonatomic, weak) IBOutlet UIView *bottomGradientView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputViewBottomSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputViewHeightConstraint;

@property (nonatomic, strong) CommentsTrackView *trackView;

@property(nonatomic,strong)NSIndexPath *selectedIndexPath;

@property(nonatomic,copy)NSMutableArray *comments;
@property(nonatomic,copy)NSArray *usernames;
@property(nonatomic,copy)NSArray *mentions;

@property(nonatomic,assign)BOOL isMentionEnter;

- (void)downloadComments;

- (IBAction)didSelectSend:(id)sender;
- (IBAction)didSelectBack:(id)sender;

@end

@implementation CommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCommentsFromCache];
    [self downloadComments];
    
    [self addToObserver];
    
    [self prepareTrackView];
    
    self.usernames=[[NSMutableArray alloc] init];
    
    //[self.userImageView setImageSquareCropAndCacheWithURL:[NSURL URLWithString:userManager.userInfo.profileImage relativeToURL:BASE_URL]];
    [self.userImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:userManager.userInfo.profileImage relativeToURL:BASE_URL]];

    [self.userImageView.layer setCornerRadius:(self.userImageView.frame.size.width / 2)];
    [self.userImageView setClipsToBounds:YES];
    [self.sendButton setEnabled:NO];
    [self setGradientLayers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    playerManager.videoPlayer.currentViewController = self;
    
    
    
    self.inputViewBottomSpaceConstraint.constant = PLAYER_VIEW_HEIGHT;

}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup methods

- (void)setGradientLayers {
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    CGRect frame = CGRectMake(_topGradientView.bounds.origin.x, _topGradientView.bounds.origin.y, [UIScreen mainScreen].bounds.size.width, _topGradientView.bounds.size.height);
    topGradient.frame = frame;
    UIColor *startColour = [UIColor colorWithWhite:0.0 alpha:0.0];
    UIColor *endColour = [UIColor colorWithWhite:0.0 alpha:0.08];
    [topGradient setStartPoint:CGPointMake(0.5, 1.0)];
    [topGradient setEndPoint:CGPointMake(0.5, 0.0)];
    topGradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [self.topGradientView.layer insertSublayer:topGradient atIndex:0];
    
    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    frame = CGRectMake(_bottomGradientView.bounds.origin.x, _bottomGradientView.bounds.origin.y, [UIScreen mainScreen].bounds.size.width, _bottomGradientView.bounds.size.height);
    bottomGradient.frame = frame;
    startColour = [UIColor colorWithWhite:0.0 alpha:0.0];
    endColour = [UIColor colorWithWhite:0.0 alpha:0.08];
    [bottomGradient setStartPoint:CGPointMake(0.5, 0.0)];
    [bottomGradient setEndPoint:CGPointMake(0.5, 1.0)];
    bottomGradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    [self.bottomGradientView.layer insertSublayer:bottomGradient atIndex:0];
}

- (void)addToObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    NSString *notificationStatusBarTappedName = [MFNotificationManager nameForNotification:MFNotificationTypeStatusBarTapped];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didTapOnHeader:)
                                                 name:notificationStatusBarTappedName
                                               object:nil];
}

- (void)updateTrackInfoViewFrame {
//    CGFloat commentsHeight = self.commentsTableView.contentSize.height - CGRectGetHeight(self.trackInfoView.frame);
//    if (commentsHeight + MIN_TRACK_INFO_VIEW_HEIGHT < CGRectGetHeight(self.commentsTableView.frame)) {
//        CGFloat trackInfoViewFrameHeight = CGRectGetHeight(self.commentsTableView.frame) - commentsHeight > MAX_TRACK_INFO_VIEW_HEIGHT ? MAX_TRACK_INFO_VIEW_HEIGHT : CGRectGetHeight(self.commentsTableView.frame) - commentsHeight;
//        [self.commentsTableView setContentInset:UIEdgeInsetsMake(trackInfoViewFrameHeight - MIN_TRACK_INFO_VIEW_HEIGHT, 0, 0, 0)];
//    } else {
//        [self.commentsTableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
//    }
    
    if ([self.commentsTableView numberOfRowsInSection:0]) {
        [self.commentsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Caching methods

- (void)setCommentsFromCache {
    _comments = [[self.trackItem.allComments allObjects] mutableCopy];
    [self sortComments];
}

- (void)setCachedComments:(NSArray *)comments {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
}

- (void)sortComments{
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"creationTime" ascending:NO];
    [_comments sortUsingDescriptors:@[sortOrder]];
}
#pragma mark - Set Reachability notifications



- (void)prepareTrackView {
    [self.commentsTrackView setTrackInfo:self.trackItem];
}

#pragma mark - UITableView Source && Delegate Methods

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        [[UIPasteboard generalPasteboard] setString:((MFCommentItem*)_comments[indexPath.row]).comment];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CommentCell";
    
    MFCommentTableCell *cell = [self.commentsTableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[MFCommentTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    MFCommentItem *commentItem;
    if (_comments && _comments.count > indexPath.row) {
        commentItem = _comments[indexPath.row];
    }
    
    if (_isMentionEnter) {
        [cell setProposalInfo:_mentions[indexPath.row]];
    } else {
        if (commentItem) {
            [cell setCommentInfo:commentItem];
        }
    }
    
    if (indexPath.row == 0) {
        [cell setSeparatorViewHidden:YES];
    } else {
        [cell setSeparatorViewHidden:NO];
    }

    [cell setCommentDelegate:self];
    
    if ([commentItem.userExtId isEqualToString:userManager.userInfo.extId]) {
        MGSwipeButton *swipeButtonRemove = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"remove",nil)
                                                          backgroundColor:[UIColor colorWithRGBHex:kOffWhiteColor]
                                                                 callback:^BOOL(MGSwipeTableCell *sender) {
                                                                     [self didDeleteCommentItem:commentItem];
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
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_isMentionEnter)
    {
        return _mentions.count;
    }
    else
    {
        if(_comments)
        {
            return _comments.count;
        }
        else
        {
            return 0;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_isMentionEnter && _comments && [_comments count]>0)
    {
        return [MFCommentTableCell heightForComment:_comments[indexPath.row]];
    }
    
    return 46.0f;
    //TODO: return COMMENT_CELL_HEIGHT;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isMentionEnter) {
        MFFollowItem *followItem=_mentions[indexPath.row];
        NSString *username=[NSString stringWithFormat:@"%@ ",followItem.username];
        
        NSString *comment=_commentTextField.text;
        NSString *prefixUsername=[self isMentionEntred:comment];
        
        comment=[comment stringByReplacingOccurrencesOfString:prefixUsername withString:username];
        [_commentTextField setText:comment];
        
        [self textFieldDidChange:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    
    CGRect frame=TRACK_VIEW_FRAME;
    
    frame.size.height -= scrollView.contentOffset.y;
    
    if (scrollView.contentSize.height + COMMENTS_TRACK_VIEW_HEIGHT < self.view.frame.size.height && frame.size.height < COMMENTS_TRACK_VIEW_HEIGHT) {
        [self.commentsTableView setScrollEnabled:NO];
    }
    else {
        [self.trackView setFrame:frame];
        [self.trackView setTrackViewHeight:frame.size.height];
        [self.commentsTableView setScrollEnabled:YES];
    }
}
- (BOOL)canEditCellForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index=indexPath.row;
    
    if(_comments && _comments.count>index)
    {
        MFCommentItem *commentItem=_comments[index];
        
        if([commentItem.user_name isEqualToString:userManager.userInfo.username])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}
- (BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction{
    
    NSInteger index=[self.commentsTableView indexPathForCell:cell].row;
    
    if(_comments && _comments.count>index)
    {
        MFCommentItem *commentItem=_comments[index];
        
        if([commentItem.user_name isEqualToString:userManager.userInfo.username])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}
- (BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    NSIndexPath *indexPath=[self.commentsTableView indexPathForCell:cell];
    MFCommentItem *commentItem=_comments[indexPath.row];
    
    if(self.trackItem.itemId && commentItem.commentId)
    {
        [[IRNetworkClient sharedInstance]removeTrackCommentByID:self.trackItem.itemId
                                                      commentID:commentItem.commentId
                                                   successBlock:^{
                                                       [_comments removeObjectAtIndex:indexPath.row];
                                                       [_commentsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                       
                                                       if(self.delegate && [self.delegate respondsToSelector:@selector(didRemoveComment)])
                                                       {
                                                           [self.delegate didRemoveComment];
                                                       }
                                                   }
                                                   failureBlock:^(NSString *errorMessage){}];
        
        
    }
    
    return YES;
}

#pragma mark - Notification center



#pragma mark - Keyboard methods

- (void)willKeyboardShow:(NSNotification*)notification {
    self.shadowView.alpha = 0.0f;
    
    NSDictionary* info = [notification userInfo];
    CGRect keyRect;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyRect];
    CGFloat height = keyRect.size.height;
    
    self.inputViewBottomSpaceConstraint.constant = height;
    self.inputViewHeightConstraint.constant = 44.f;
    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
        if ([self.commentsTableView numberOfRowsInSection:0]) {
            [self.commentsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        self.shadowView.alpha = 0.8f;
    }];
    self.swipeView.hidden = NO;
}

- (void)willKeyboardHide:(NSNotification*)notification {
    self.shadowView.alpha = 0.8f;

    [self textFieldDidEndEditing:self.commentTextField];
    
    if (!self.container.isPlayerViewHidden) {
        self.inputViewBottomSpaceConstraint.constant = PLAYER_VIEW_HEIGHT;
    } else {
        self.inputViewBottomSpaceConstraint.constant = 0;
    }
    self.inputViewHeightConstraint.constant = 44.f;
    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
        if ([self.commentsTableView numberOfRowsInSection:0]) {
            [self.commentsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        self.shadowView.alpha = 0.0f;
    }];
    self.swipeView.hidden = YES;
}

#pragma mark - Comment Requests

- (void)downloadComments
{
//    [_commentsActivityView startAnimating];
    
    [[IRNetworkClient sharedInstance]getTrackCommentById:self.trackItem.itemId
                                               withEmail:userManager.userInfo.email
                                                   token:[userManager fbToken]
                                            successBlock:^(NSArray *commentArray)
     {
         NSMutableArray *tempArray = [[dataManager convertAndAddCommentItemsToDatabase:commentArray] mutableCopy];
         
         self.trackItem.allComments = [NSSet setWithArray:tempArray];
         
         _comments = tempArray;
         
         [self sortComments];

         [self setCachedComments:_comments];
         
         [_commentsTableView reloadData];
         
         if (self.comments && self.comments.count > 0) {
             [self.commentsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.commentsTableView numberOfRowsInSection:0] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
         }
         
         // Setup trackInfoView frame
         [self updateTrackInfoViewFrame];
         
         [self hideTopErrorViewWithMessage:self.kConnectedMessage];
     }
     failureBlock:^(NSString *errorMessage)
     {
//         [_commentsActivityView stopAnimating];
         [self showAndKeepTopErrorViewWithMessage:self.kNetworkErrorMessage autohide:YES];
     }];
}

#pragma mark - Comment Cell Delegate methods

- (void)didSelectDelete:(CommentCell *)cell
{
    MFCommentItem *commentItem=_comments[self.selectedIndexPath.row];
    
    if(self.trackItem.itemId && commentItem.commentId)
    {
        [[IRNetworkClient sharedInstance]removeTrackCommentByID:self.trackItem.itemId
                                                      commentID:commentItem.commentId
                                                   successBlock:^{
                                                       
                                                       [_comments removeObjectAtIndex:self.selectedIndexPath.row];
                                                       [_commentsTableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                       
                                                       self.selectedIndexPath=nil;
                                                       
                                                       if(self.delegate && [self.delegate respondsToSelector:@selector(didRemoveComment)])
                                                       {
                                                           [self.delegate didRemoveComment];
                                                       }
                                                   }
                                                   failureBlock:^(NSString *errorMessage){}];
    }
    
}
- (void)didOpenDelete:(CommentCell *)cell{
    
    if(self.selectedIndexPath)
    {
        CommentCell *lastSelectedCell=(CommentCell*)[self.commentsTableView cellForRowAtIndexPath:self.selectedIndexPath];
        [lastSelectedCell.sliderView closeSliderAnimated:YES];
    }
    
    self.selectedIndexPath=[self.commentsTableView indexPathForCell:cell];
}
- (void)didCloseDelete:(CommentCell *)cell{
    
    NSIndexPath *indexPath=[self.commentsTableView indexPathForCell:cell];

    if(self.selectedIndexPath && self.selectedIndexPath.row==indexPath.row){
        
        self.selectedIndexPath=nil;
    }
}

#pragma mark - IBActions

- (IBAction)didSelectSend:(id)sender {
    NSString *comment = self.commentTextField.text;
    [self.commentTextField setText:@""];
    [self.commentTextField resignFirstResponder];
    [self.sendButton setEnabled:NO];
    
    [[IRNetworkClient sharedInstance]postTrackCommentById:self.trackItem.itemId comment:comment withEmail:userManager.userInfo.email token:[userManager fbToken] successBlock:^{
        BOOL notFirstComment = NO;
        for (MFCommentItem* item in _comments){
            if ([item.autorFacebookId isEqualToString:userManager.userInfo.facebookID]) notFirstComment = YES;
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

        [self downloadComments];
        if (_delegate && [_delegate respondsToSelector:@selector(didAddComment)]) {
            [_delegate didAddComment];
        }
        
        [self hideTopErrorViewWithMessage:self.kConnectedMessage];
        
    } failureBlock:^(NSString *errorMessage) {
        [self showAndKeepTopErrorViewWithMessage:self.kNetworkErrorMessage autohide:YES];
        
    }];
}

- (IBAction)didSelectBack:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(willCloseCommentController)]) {
        [_delegate willCloseCommentController];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Swipe Actions

- (IBAction)didSwipeCommentDown:(id)sender {
    [self.commentTextField resignFirstResponder];
}

#pragma mark - Enter mention methods

- (void)checkMention:(NSString*)textFieldText
{
    NSString *prefixUsername=[self isMentionEntred:textFieldText];
    
    if(prefixUsername)
    {
        [self setMentionsWithPrefixUsername:prefixUsername];
        
        if(_mentions.count)
        {
            _isMentionEnter=YES;
        }
        else
        {
            _isMentionEnter=NO;
        }
    }
    else
    {
        _isMentionEnter=NO;
    }
    
    [_commentsTableView reloadData];
    if ([self.commentsTableView numberOfRowsInSection:0] > 0 && _isMentionEnter) {
        [_commentsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.commentsTableView numberOfRowsInSection:0] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (NSString*)isMentionEntred:(NSString*)comment
{
    NSError *error;
    NSRegularExpression *regExp=[[NSRegularExpression alloc]initWithPattern:@"(?<=@)[a-zA-Z0-9_]+$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if(!error)
    {
        NSArray *matches=[regExp matchesInString:comment options:0 range:NSMakeRange(0, [comment length])];
        
        for(NSTextCheckingResult *match in matches)
        {
            return [comment substringWithRange:[match range]];
        }
    }
    
    return nil;
}

- (void)setMentionsWithPrefixUsername:(NSString*)username
{
    NSMutableArray *array=[NSMutableArray array];
    
    for(MFFollowItem *followItem in _usernames)
    {
        if([[followItem.username lowercaseString] hasPrefix:[username lowercaseString]])
        {
            [array addObject:followItem];
        }
    }
    
    _mentions=array;
}

#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender {
    if ([self.commentsTableView numberOfRowsInSection:0]) {
        [self.commentsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.commentsTableView numberOfRowsInSection:0] - 1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - MGSwipeButton actions

- (void)didDeleteCommentItem:(MFCommentItem *)commentItem {
    NSIndexPath *indexPath = [self indexPathForCommentItem:commentItem];

    if (self.trackItem.itemId && commentItem.commentId) {
        [[IRNetworkClient sharedInstance] removeTrackCommentByID:self.trackItem.itemId
                                                       commentID:commentItem.commentId
                                                    successBlock:^{
                                                        [self hideTopErrorViewWithMessage:self.kConnectedMessage];
                                                        [_comments removeObjectAtIndex:indexPath.row];
                                                        [_commentsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                        
                                                        if (self.delegate && [self.delegate respondsToSelector:@selector(didRemoveComment)]) {
                                                            [self.delegate didRemoveComment];
                                                        }
                                                    }
                                                    failureBlock:^(NSString *errorMessage) {
                                                        [self showAndKeepTopErrorViewWithMessage:self.kNetworkErrorMessage autohide:YES];
                                                    }];
    }
    
    
}

#pragma mark - Pan handler

-(void)panHandler:(UIPanGestureRecognizer *)gesture {
    MGSwipeTableCell *tableCell = (MGSwipeTableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:gesture.view.tag inSection:0]];
    [tableCell panHandler:gesture];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textView {
    if ([textView.text isEqualToString:@""]||[textView.text isEqualToString:NSLocalizedString(@"comment...",nil)]) {
        textView.text = @"";
        textView.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        textView.textColor = [UIColor colorWithRGBHex:kDarkColor];
        [self.sendButton setEnabled:NO];
    } else {
        [self.sendButton setEnabled:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = NSLocalizedString(@"comment...",nil);
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        textView.textColor = [UIColor colorWithRGBHex:kLightColor];
        [self.sendButton setEnabled:NO];
        [self.view layoutIfNeeded];
    } else {
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        [self.sendButton setEnabled:YES];
    }
}

- (void)textFieldDidChange:(UITextField *)textView {
    if ([textView.text isEqualToString:@""]) {
        [self.sendButton setEnabled:NO];
    } else {
        [self.sendButton setEnabled:YES];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField.text isEqualToString:@""]&&[string isEqualToString:@""]) {
        [self.sendButton setEnabled:NO];
    } else {
        [self.sendButton setEnabled:YES];
    }
    return YES;
}
#pragma mark - Helpers

- (NSIndexPath *)indexPathForCommentItem:(MFCommentItem *)commentItem {
    for (int i = 0; i < _comments.count; i++) {
        MFCommentItem *comment = _comments[i];
        if ([comment.commentId isEqual:commentItem.commentId]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

#pragma mark - MFCommentViewDelegate methods

- (void)shouldOpenUserProfileWithUserInfo:(MFUserInfo *)userInfo {
    [self showUserProfileWithUserInfo:userInfo];
}

@end
