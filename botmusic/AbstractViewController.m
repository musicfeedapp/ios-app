//
//  PageItemAbstractViewController.m
//  botmusic
//
//  Created by Илья Романеня on 13.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "ProfileViewController.h"
#import "SearchViewController.h"
#import "MFPremiumProfileViewController.h"
#import "MFNotificationManager.h"
#import <Mixpanel.h>
#import "PlaylistTracksViewController.h"
#import "NewSearchViewController.h"
#import "MFSingleTrackViewController.h"


NSString * const PlayerLikeNotificationEvent = @"PlayerLikeNotificationEvent";
NSString * const PlayerUnlikeNotificationEvent = @"PlayerUnlikeNotificationEvent";
NSString * const FeedLikeNotificationEvent = @"FeedLikeNotificationEvent";
NSString * const FeedUnlikeNotificationEvent = @"FeedUnlikeNotificationEvent";
NSString * const PlaylistLikeNotificationEvent = @"PlaylistLikeNotificationEvent";
NSString * const PlaylistUnlikeNotificationEvent = @"PlaylistUnlikeNotificationEvent";

// Return nil when __INDEX__ is beyond the bounds of the array
#define NSArrayObjectMaybeNil(__ARRAY__, __INDEX__) ((__INDEX__ >= [__ARRAY__ count]) ? nil : [__ARRAY__ objectAtIndex:__INDEX__])

// Manually expand an array into an argument list
#define NSArrayToVariableArgumentsList(__ARRAYNAME__)\
NSArrayObjectMaybeNil(__ARRAYNAME__, 0),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 1),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 2),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 3),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 4),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 5),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 6),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 7),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 8),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 9),\
nil

@interface AbstractViewController () 

@property (nonatomic, assign) BOOL shouldResignResponder;
@property (nonatomic, strong) NSArray *currentButtonTitles;
@property (nonatomic, assign) BOOL isErrorMessageHidden;

@end

@implementation AbstractViewController

@synthesize kConnectedMessage;
@synthesize kNetworkErrorMessage;
@synthesize kErrorMessage;
@synthesize kSpotifyError;
@synthesize kTrackAdded;
@synthesize kProblemWithNetwork;

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
    
    kNetworkErrorMessage = NSLocalizedString(@"Network Error",nil);
    kErrorMessage = NSLocalizedString(@"No Internet Connection",nil);
    kConnectedMessage = NSLocalizedString(@"Connected",nil);
    kTrackAdded = NSLocalizedString(@"Track added!",nil);
    kSpotifyError = NSLocalizedString(@"You need Spotify Premium to stream this track",nil);
    kProblemWithNetwork = NSLocalizedString(@"There is a problem with your network.", nil);
    [super viewDidLoad];
    
    [self.searchTextField.layer setCornerRadius:13.0f];
    [self.searchTextField.layer setBorderWidth:0.5f];
    
    self.shouldResignResponder=YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideError:)
                                                 name: [MFNotificationManager nameForNotification:MFNotificationTypeHideTopError] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackAddedToPlaylist)
                                                 name: [MFNotificationManager nameForNotification:MFNotificationTypeAddedToPlaylist] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyError)
                                                 name:@"spotifyNotPremiumError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingTooLong)
                                                 name:[MFNotificationManager nameForNotification:MFNotificationTypeTrackLoagingTooLong] object:nil];
    NSString* notificationLoadName = [MFNotificationManager nameForNotification:MFNotificationTypeCantLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cantLoadNotification:)
                                                 name:notificationLoadName
                                               object:nil];
    [self setTableViews];
    //[self setReachabilityNotifications];
    //[self checkReachability];


    //[self initErrorView];
    
    _headerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnHeader:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self changesStatusBarStyle]) {
        [[UIApplication sharedApplication] setStatusBarStyle:self.preferredStatusBarStyle animated:YES];
    }
    NSString *notificationLoadName = [MFNotificationManager nameForNotification:MFNotificationTypeHidePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hidePlayerNotification)
                                                 name:notificationLoadName
                                               object:nil];
    
    
}

- (BOOL)changesStatusBarStyle{
    return YES;
}
- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    //[self checkReachability];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.parentViewController && [self.parentViewController respondsToSelector:@selector(preferredStatusBarStyle)]) {
        return self.parentViewController.preferredStatusBarStyle;
    }
    return UIStatusBarStyleDefault;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSString *notificationLoadName = [MFNotificationManager nameForNotification:MFNotificationTypeHidePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationLoadName object:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat constant = [self.parentViewController.topLayoutGuide length];
    //NSLog(@"Magic constant %f", constant);//do not remove magic leves here!
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification Center

- (void)hidePlayerNotification {
    [self.view setNeedsUpdateConstraints];
}

- (void)didReceiveUserUnathorizedNotification:(NSNotification *)notification {
}

#pragma mark - Preparation methods

-(void)setTableViews{

}

- (void)initErrorView
{
    _errorView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, 320, 30)];
    _errorView.backgroundColor = [UIColor colorWithRGBHex:kAppMainColor];
    _errorMessage = [[UILabel alloc] initWithFrame:_errorView.bounds];
    _errorMessage.textColor = [UIColor whiteColor];
    _errorMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    _errorMessage.textAlignment = NSTextAlignmentCenter;
    _errorMessage.hidden = YES;
    [_errorView addSubview:_errorMessage];
}

#pragma mark - Action sheet methods

- (void)showSharing
{
    NSArray* buttonTitles = [self buttonTitlesForSharing];
    [self showSharingWithButtonTitles:buttonTitles];
}

- (NSArray*)buttonTitlesForSharing{
    NSMutableArray *buttonTitles = [NSMutableArray arrayWithArray:@[@"Facebook", @"Tweet", @"Email", NSLocalizedString(@"Message",nil), NSLocalizedString(@"Copy Link",nil)]];
    //    [buttonTitles addObject:@"Twitter"];
    //    [buttonTitles addObjectsFromArray:@[@"Email", @"Message", @"Copy Link"]];
//    if ([self isITunesLinkAvailable]) {
//        [buttonTitles addObject:NSLocalizedString(@"Buy with ITunes",nil)];
//    }
//    if (![self.trackItem.authorExtId isEqualToString:userManager.userInfo.extId]){
//        if (self.trackItem.authorIsFollowed ) {
//            [buttonTitles addObject:NSLocalizedString(@"Unfollow",nil)];
//        } else {
//            [buttonTitles addObject:NSLocalizedString(@"Follow",nil)];
//        }
//    }
    return buttonTitles;
}

- (BOOL)isITunesLinkAvailable {
    return (_trackItem && _trackItem.iTunesLink && [_trackItem.iTunesLink length]);
}

- (void)showSharingWithButtonTitles:(NSArray*)buttonTitles{
    _currentButtonTitles = [buttonTitles copy];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSArrayToVariableArgumentsList(buttonTitles)];
    [actionSheet showInView:self.view];
}
-(void)didShareTrackItem { }

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < _currentButtonTitles.count) {
        NSString *menuItemTitle = _currentButtonTitles[buttonIndex];
        if ([menuItemTitle isEqualToString:@"Facebook"]) {
            [self shareOnFacebook];
        } else if ([menuItemTitle isEqualToString:@"Tweet"]) {
            [self shareOnTwitter];
        } else if ([menuItemTitle isEqualToString:@"Email"]) {
            [self sendEmail];
        } else if ([menuItemTitle isEqualToString:NSLocalizedString(@"Message",nil)]) {
            [self sendMessage];
        } else if ([menuItemTitle isEqualToString:NSLocalizedString(@"Copy Link",nil)]) {
            [self copyToClipboard];
        } else if ([menuItemTitle isEqualToString:NSLocalizedString(@"Buy with ITunes",nil)]) {
            [self buyWithITunes];
        } else if ([menuItemTitle isEqualToString:NSLocalizedString(@"Follow",nil)]){
            [self changeFollowingState];
        } else if ([menuItemTitle isEqualToString:NSLocalizedString(@"Unfollow",nil)]){
            [self changeFollowingState];
        }
        
        [self didShareTrackItem];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    UIColor *customTitleColor = [UIColor redColor];
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;

            if(button.tag==6)
            {
                [button setTitleColor:customTitleColor forState:UIControlStateHighlighted];
                [button setTitleColor:customTitleColor forState:UIControlStateNormal];
                [button setTitleColor:customTitleColor forState:UIControlStateSelected];
            }
        }
    }
}

#pragma mark - Action sheed point methods

- (void)addToFavorites
{
    _trackItem.favourite=YES;
    
    [[IRNetworkClient sharedInstance]addTrackByFeedItemId:_trackItem.itemId
                                                withEmail:userManager.userInfo.email
                                                    token:[userManager fbToken]
                                             successBlock:^(NSArray *feedArray){
                                             }
                                             failureBlock:^(NSString *errorMessage){
                                                 NSLogExt(@"%@",errorMessage);
                                             }];
}

- (void)removeFromFavorites
{
    _trackItem.favourite=NO;
    
    [[IRNetworkClient sharedInstance]removeTrackByFeedItemId:_trackItem.itemId
                                                   withEmail:userManager.userInfo.email
                                                       token:[userManager fbToken]
                                                successBlock:^(NSDictionary *dic)
     {
     }
                                                failureBlock:^(NSString *errorMessage)
     {
         NSLogExt(@"%@",errorMessage);
     }];
}

- (void)shareOnFacebook
{
    SLComposeViewController *socialSheet = [SLComposeViewController
                                            composeViewControllerForServiceType:SLServiceTypeFacebook];
    [socialSheet setInitialText:[_trackItem shareText]];
    
    UIImageView* imageView = [UIImageView new];
    //забираем только если закэширована
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_trackItem.trackPicture]
                                                       cachePolicy:NSURLRequestReturnCacheDataDontLoad
                                                   timeoutInterval:0]
                     placeholderImage:nil
                              success:nil
                              failure:nil];
    UIImage* image = imageView.image;
    if (image)
    {
        [socialSheet addImage:image];
    }
    
    _trackItem.facebookShared = YES;
    
    [self presentViewController:socialSheet animated:YES completion:nil];
}

- (void)shareOnTwitter
{
    SLComposeViewController *socialSheet = [SLComposeViewController
                                            composeViewControllerForServiceType:SLServiceTypeTwitter];
    [socialSheet setInitialText:[_trackItem shareText]];
    
    UIImageView* imageView = [UIImageView new];
    //забираем только если закэширована
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_trackItem.trackPicture]
                                                       cachePolicy:NSURLRequestReturnCacheDataDontLoad
                                                   timeoutInterval:0]
                     placeholderImage:nil
                              success:nil
                              failure:nil];
    UIImage* image = imageView.image;
    if (image)
    {
        [socialSheet addImage:image];
    }
    
    _trackItem.twitterShared = YES;
    
    [self presentViewController:socialSheet animated:YES completion:nil];
}

- (void)sendEmail
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailController=[[MFMailComposeViewController alloc]init];
        mailController.mailComposeDelegate=self;
        
        [mailController setSubject:NSLocalizedString(@"Musicfeed",nil)];
        [mailController setMessageBody:[_trackItem shareText] isHTML:NO];
        
        [self presentViewController:mailController animated:YES completion:nil];
    }
    else
    {
        [self showErrorMessage:NSLocalizedString(@"Email is not available!",nil)];
    }
}

- (void)sendMessage
{
    if([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageController=[[MFMessageComposeViewController alloc]init];
        messageController.messageComposeDelegate=self;
        
        [messageController setTitle:NSLocalizedString(@"Musicfeed",nil)];
        [messageController setBody:[_trackItem shareText]];
        
        
        [self presentViewController:messageController animated:YES completion:nil];
    }
    else
    {
        [self showErrorMessage:NSLocalizedString(@"Message is not available!",nil)];
    }
}

- (void)copyToClipboard
{
    if(_trackItem && _trackItem.shareLink) {
        [UIPasteboard generalPasteboard].string = _trackItem.shareLink;
    }
}

- (void)buyWithITunes
{
    if (_trackItem && _trackItem.iTunesLink && [_trackItem.iTunesLink length]) {
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_trackItem.iTunesLink,@"&app=itunes"]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            [[Mixpanel sharedInstance] track:@"Clicked 'Buy with itunes'" properties:@{@"trackID":_trackItem.itemId,
                                                                                      @"authorID":_trackItem.authorId}];
            [FBSDKAppEvents logEvent:@"Clicked 'Buy with itunes'" parameters:@{@"trackID":_trackItem.itemId,
                                                                               @"authorID":_trackItem.authorId}];
        } else {
            [self showErrorMessage:@"iTunes link is incorrect!"];
        }
    } else {
        [self showErrorMessage:@"iTunes link is not available!"];
    }
}
-(void) changeFollowingState{
    NSDictionary *proposalsDictionary = @{@"ext_id" : self.trackItem.authorExtId,
                                          @"followed" : self.trackItem.authorIsFollowed ? @"false" : @"true"};
    
    [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                      token:[userManager fbToken]
                                                  proposals:@[proposalsDictionary]
                                               successBlock:^{
                                                   [self.trackItem setAuthorIsFollowed:!self.trackItem.authorIsFollowed];
                                                   MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:self.trackItem.authorExtId];
                                                   userInfo.facebookID = self.trackItem.authorId;
                                                   userInfo.extId = self.trackItem.authorExtId;
                                                   userInfo.isFollowed = self.trackItem.authorIsFollowed;
                                                   [MFNotificationManager postUpdateUserFollowingNotification:userInfo];
                                               }
                                               failureBlock:^(NSString *errorMessage){
                                                   [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                                   
                                               }];

}

#pragma mark - MessageUI Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView Delegate & Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResultArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return 46.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"SuggestionCell";
    
    SuggestionCell *cell=(SuggestionCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"SuggestionCell" owner:nil options:nil]lastObject];
    }
    
    if(self.searchResultArray && self.searchResultArray.count>indexPath.row)
    {
        IRSuggestion *suggestion=self.searchResultArray[indexPath.row];
        [cell setSuggestionInfo:suggestion];
        [cell setIsMenuSearch:NO];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchTextField resignFirstResponder];
    
    if(self.searchResultArray && self.searchResultArray.count>indexPath.row)
    {
        IRSuggestion *suggestion=self.searchResultArray[indexPath.row];
        
        if(suggestion.username && ![suggestion.username isEqualToString:@""])
        {
            MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
            userInfo.username = suggestion.username;
            userInfo.profileImage = suggestion.avatar_url;
            userInfo.facebookID = suggestion.facebook_id;
            userInfo.extId = suggestion.ext_id;
            userInfo.name = suggestion.name;
            [self showUserProfileWithUserInfo:userInfo];
        }
        else
        {
            [self showErrorMessage:NSLocalizedString(@"Internal error", nil)];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - IBActions

- (IBAction)didTouchUpMenuButton:(id)sender
{
}

- (IBAction)didTouchUpBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTouchUpSearchButton:(id)sender
{
    [self showSearch];
}

- (IBAction)didTouchUpCancelButton:(id)sender
{
    [self hideSearch];
}

- (IBAction)didTextFieldEditChanged:(id)sender
{
    [self.startTypingLabel setHidden:YES];
    [self.searchingTableView setHidden:NO];
    [self.blurView setAlpha:0.7f];
    [self.blurView setBlurRadius:15.0f];
    
    NSString *keywords=[self.searchTextField text];
    
    if(keywords==nil)
    {
        keywords=@"";
    }
    
    self.searchResultArray=@[];
    [self.searchingTableView reloadData];
    
    [self.activityView startAnimating];
    
    [[IRNetworkClient sharedInstance]searchWithKeyword:keywords
                                            searchType:@"all"
                                               success:^(NSDictionary *searchResultDictionary){
                                                   
                                                   NSMutableArray *array=[@[] mutableCopy];
                                                   
                                                   [array addObjectsFromArray:[DataConverter convertSuggestions:searchResultDictionary[@"artists"]]];
                                                   [array addObjectsFromArray:[DataConverter convertSuggestions:searchResultDictionary[@"users"]]];
                                                   
                                                   [self.activityView stopAnimating];
                                                   
                                                   self.searchResultArray=array;
                                                   [self.searchingTableView reloadData];
                                               }
                                               failure:^(NSString *errorMessage)
                                               {
                                                   [self.activityView stopAnimating];
                                                   [self showErrorMessage:errorMessage];
                                               }];
}

- (IBAction)didTextFieldTapSearchButton:(id)sender{
    
    return;
    
//    NSString *searchKeyword=[self.searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
//    [self.searchTextField setText:@""];
//    
//    if(searchKeyword && ![searchKeyword isEqualToString:@""])
//    {
//        self.shouldResignResponder=YES;
//        
//        SearchViewController *searchVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
//        searchVC.searchKeyword=searchKeyword;
//        
//        [self.container setPanMode:MFSideMenuPanModeNone];
//        
//        [self.navigationController pushViewController:searchVC animated:YES];
//        
//        [self hideSearch];
//    }
//    else
//    {
//        self.shouldResignResponder=NO;
//    }
}

- (IBAction)topErrorButtonClicked:(id)sender {
    [MFNotificationManager postHideTopErrorNotification:self.topErrorViewLabel.text];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
{
    BOOL shouldResign=self.shouldResignResponder;
    self.shouldResignResponder=YES;
    
    [self.blurView setAlpha:0.0f];
    
    return shouldResign;
}

#pragma mark - Search methods

- (void)showSearch{

    [UIView animateWithDuration:0.5f animations:^{
        [self.menuButton setAlpha:0.0f];
        [self.headerLabel setAlpha:0.0f];
        [self.searchButton setAlpha:0.0f];
        [self.cancelButton setAlpha:1.0f];
        [self.searchTextField setAlpha:1.0f];
        [self.searchTextField setFrame:CGRectMake(16, 24, 260, 30)];
    }completion:^(BOOL finished){
        [self searchWillShow];
        [self.searchTextField becomeFirstResponder];
        [self.startTypingLabel setHidden:NO];
        
        self.isSearchMode=YES;
        [self.searchingTableView setDelegate:self];
        [self.searchingTableView setDataSource:self];
        [self.searchingTableView setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.9]];
    }];
}

- (void)hideSearch{
    
    [self.searchTextField resignFirstResponder];
    
    [self.searchingTableView setDelegate:nil];
    [self.searchingTableView setDataSource:nil];
    [self setIsSearchMode:NO];
    
    [self.searchingTableView setHidden:YES];
    [self.tableView reloadData];
    
    [UIView animateWithDuration:0.5f animations:^{
        [self.menuButton setAlpha:1.0f];
        [self.headerLabel setAlpha:1.0f];
        [self.searchButton setAlpha:1.0f];
        [self.cancelButton setAlpha:0.0f];
        [self.searchTextField setAlpha:0.0f];
        [self.searchTextField setFrame:CGRectMake(281, 24, 30, 30)];
    }completion:^(BOOL finished){
        [self.searchTextField setText:@""];
        
        [self searchWillHide];
    }];
}

- (void)searchWillShow{}

- (void)searchWillHide{}
#pragma mark - Profile

- (UINavigationController*)navControllerToPush{
    return self.navigationController;
}

- (void)showUserProfileWithUserInfo:(MFUserInfo*)userInfo
{
    if((userInfo.extId && ![userInfo.extId isEqualToString:@""]))
    {
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        MFPremiumProfileViewController *profileVC = [storyboard instantiateViewControllerWithIdentifier:@"MFPremiumProfileViewController"];
        profileVC.userInfo = userInfo;

        [self.navControllerToPush pushViewController:profileVC animated:YES];
        
        //TODO which of modes?
        playerManager.videoPlayer.currentViewController = profileVC;

        [self hideSearch];

    }
}

- (void)shouldOpenTrackInfo:(MFTrackItem *)trackItem
{
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MFSingleTrackViewController *trackInfoVC = [storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = trackItem;

    [self.navControllerToPush pushViewController:trackInfoVC animated:YES];
}

- (void)shouldOpenPlaylist:(MFPlaylistItem *)playlistItem ofUser:(MFUserInfo*)userInfo
{
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlaylistTracksViewController *playlistTracksVC = [storyboard instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
    playlistTracksVC.playlist = playlistItem;
    playlistTracksVC.isDefaultPlaylist = [playlistItem.itemId isEqualToString:@"default"] || [playlistItem.itemId isEqualToString:@"likes"];
    playlistTracksVC.userExtId = userInfo.extId;
    playlistTracksVC.isMyMusic = userInfo.isMyUserInfo;
    [self.navControllerToPush pushViewController:playlistTracksVC animated:YES];

}

#pragma mark - MFNewProfileViewControllerDelegate
- (void)menuButonTapped
{
    [self didTouchUpMenuButton:nil];
}
- (BOOL)showBackButton
{
    return YES;
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame=self.startTypingLabel.frame;
    frame.origin.y=(CGRectGetHeight(self.view.frame)-CGRectGetHeight(keyboardFrame)-60)/2+60;
    [self.startTypingLabel setFrame:frame];
}


#pragma mark - Actions

- (IBAction)didSelectSearch:(id)sender
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    SearchViewController *searchVC = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
//    searchVC.container = self.container;
    NewSearchViewController* searchVC = [[NewSearchViewController alloc] init];
    [self.navControllerToPush pushViewController:searchVC animated:YES];
}



#pragma mark - TopErrorView animations
- (void)cantLoadNotification:(NSNotification *) notification
{
    NSString* message = [notification.userInfo valueForKey:@"description"];
    [self showAndKeepTopErrorViewWithMessage:message autohide:YES];
}

- (void)trackAddedToPlaylist{
    [self showAndKeepTopErrorViewWithMessage:kTrackAdded autohide:YES];
}

- (void)spotifyError{
    [self showAndKeepTopErrorViewWithMessage:kSpotifyError autohide:NO];
}

-(void)loadingTooLong{
    [self showAndKeepTopErrorViewWithMessage:kProblemWithNetwork autohide:YES];
}

- (void)setReachabilityNotifications {
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [networkReachability startNotifier];
}

- (void)checkReachability
{
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable && ![MFErrorManager sharedInstance].isErrorMessageHidden) {
        //[self hideTopErrorViewAnimated:NO];
        //[self showAndKeepTopErrorViewWithMessage:kErrorMessage autohide:NO animated:NO];
        //[[MFMessageManager sharedInstance] showNoInternetConnectionInViewController:self];
    } else {
        //if([self.topErrorViewLabel.text isEqualToString:kErrorMessage])[self hideTopErrorViewAnimated:NO];
        
    }
}

- (void)reachabilityChanged:(NSNotification *) notification
{
    Reachability *reachability = [notification object];
    if ([reachability isReachable]) {
        [MFErrorManager sharedInstance].isErrorMessageHidden = NO;
        //[self hideTopErrorViewWithMessage:kConnectedMessage];
    }
    else {
        [MFErrorManager sharedInstance].isErrorMessageHidden = NO;
        //[self showAndKeepTopErrorViewWithMessage:kErrorMessage autohide:NO];
        //[[MFMessageManager sharedInstance] showNoInternetConnectionInViewController:self];
    }
}

- (void)hideError:(NSNotification *)notification{
    if ([notification.userInfo[@"error"] isEqualToString:kErrorMessage]) {
        [MFErrorManager sharedInstance].isErrorMessageHidden = YES;
    }
    if ([notification.userInfo[@"error"] isEqualToString:kProblemWithNetwork]) {
        [MFErrorManager sharedInstance].isProblemMessageHidden = YES;
    }
    [MFErrorManager sharedInstance].isErrorMessageHidden = YES;
    [self hideTopErrorViewAnimated:YES];
}

- (void)showAndKeepTopErrorViewWithMessage:(NSString *)message autohide:(BOOL)autohide
{
    [self showAndKeepTopErrorViewWithMessage:message autohide:autohide animated:YES];
}

- (void)showAndKeepTopErrorViewWithMessage:(NSString *)message autohide:(BOOL)autohide animated:(BOOL) animated{
    return;
    if(([MFErrorManager sharedInstance].isErrorMessageHidden)&&([message isEqualToString:kErrorMessage]||[message isEqualToString:kNetworkErrorMessage]))
    {
        return;
    }
    if(([MFErrorManager sharedInstance].isProblemMessageHidden)&&([message isEqualToString:kProblemWithNetwork]))
    {
        return;
    }
    if ((self.topErrorView.isHidden || [[MFErrorManager sharedInstance] isHighPriorityMessage:message])) {
        self.topErrorViewLabel.text = message;
        self.topErrorView.hidden = NO;
        if ([message isEqualToString:kNetworkErrorMessage]) {
            self.topErrorView.backgroundColor = [UIColor colorWithRGBHex:kDarkColor];
        } else {
            self.topErrorView.backgroundColor = [UIColor colorWithRGBHex:kAppMainColor];
        }
        
        if ([message isEqualToString:kTrackAdded]){
            
            self.topErrorView.backgroundColor = [UIColor colorWithRGBHex:kAppMainInverseColor];
        }
        
        if ([message isEqualToString:kErrorMessage]) {
            self.topErrorViewButton.hidden = NO;
        } else {
            self.topErrorViewButton.hidden = YES;
        }
        
        if ([message isEqualToString:kProblemWithNetwork]) {
            self.topErrorViewButton.hidden = NO;
            self.topErrorView.backgroundColor = [UIColor colorWithRGBHex:kDarkColor];
        }
        self.topErrorViewLabel.userInteractionEnabled = NO;
        if ([message isEqualToString:kSpotifyError]) {
            NSRange range = [message rangeOfString:@"Spotify Premium"];
            
            if (range.location == NSNotFound) {
                self.topErrorViewLabel.text = message;
            }
            else {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:kSpotifyError attributes:nil];
                NSRange linkRange = range; // for the word "link" in the string above
                
                NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0],
                                                  NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };
                [attributedString setAttributes:linkAttributes range:linkRange];
                
                self.topErrorViewLabel.attributedText = attributedString;
            }
            self.topErrorViewLabel.userInteractionEnabled = YES;
            [self.topErrorViewLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnErrorLabel:)]];
        }
        [self.view layoutIfNeeded];
        
        self.topErrorViewBottomAlignConstraint.constant = -CGRectGetHeight(self.topErrorView.frame);
        float duration;
        
        if (animated) duration = 0.25f;
        if (!animated) duration = 0.0f;
        CGFloat autohideTime = 3.0;
        if ([message isEqualToString:kTrackAdded]) {
            autohideTime = 1.0;
        } else if([message isEqualToString:kSpotifyError]) {
            autohideTime = 6.0;
        } else if ([message isEqualToString:kProblemWithNetwork]){
            autohideTime = 7.5;
        }
        
//        if (_tableViewBelowMessageBar) {
//            CGPoint offset = _tableViewBelowMessageBar.contentOffset;
//            UIEdgeInsets insets = _tableViewBelowMessageBar.contentInset;
//            insets.top = CGRectGetHeight(self.topErrorView.frame);
//            _tableViewBelowMessageBar.contentInset = insets;
//            _tableViewBelowMessageBar.contentOffset = offset;
//        }
        
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (autohide) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(autohideTime * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                                   [self hideTopErrorViewAnimated:YES];
                               });
            }
        }];
    }
}

- (void)hideTopErrorViewAnimated:(BOOL)animated
{
    if (!self.isTopErrorViewAnimating) {
        self.isTopErrorViewAnimating = YES;
        if (animated) {
            [self.view layoutIfNeeded];

            self.topErrorViewBottomAlignConstraint.constant = 0;
            [UIView animateWithDuration:0.25f animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.topErrorView.hidden = YES;
                self.isTopErrorViewAnimating = NO;
            }];
        } else {
            self.topErrorViewBottomAlignConstraint.constant = 0;
            self.topErrorView.hidden = YES;
            self.isTopErrorViewAnimating = NO;
        }
//        if (_tableViewBelowMessageBar) {
//            CGPoint offset = _tableViewBelowMessageBar.contentOffset;
//            UIEdgeInsets insets = _tableViewBelowMessageBar.contentInset;
//            insets.top = 0;
//            _tableViewBelowMessageBar.contentInset = insets;
//            _tableViewBelowMessageBar.contentOffset = offset;
//        }
    }
}

- (void)hideTopErrorViewWithMessage:(NSString *)message
{
    if (!self.isTopErrorViewAnimating) {
        self.topErrorViewLabel.text = message;
        self.topErrorView.backgroundColor = [UIColor colorWithRGBHex:kAppMainInverseColor];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [self hideTopErrorViewAnimated:YES];
                       });
    }
}

-(void)handleTapOnErrorLabel:(UITapGestureRecognizer *)tapGesture{
    NSURL* url = [NSURL URLWithString:@"https://www.spotify.com/int/purchase/product/premium/"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
@end
