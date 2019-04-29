//
//  MenuViewController.m
//  botmusic
//
//  Created by Supervisor on 08.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "MenuViewController.h"
#import "MFNotificationManager.h"
#import "SearchViewController.h"
#import "PlaylistsViewController.h"
#import "MFNewProfileViewController.h"
#import "MFNavigationBar.h"
#import "MFSettingsContainerViewController.h"

static NSString *const MENU_PLIST=@"Menu.plist";
static NSString *const kLabels=@"Labels";
static NSString *const kImages=@"Images";
static NSInteger const SEARCH_OFFSET=70;

@interface MenuViewController () <MenuCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, weak) IBOutlet UILabel *startTypingLabel;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;


@property(nonatomic,strong)         NSDictionary *menuInfoDictionary;

@property(nonatomic,assign)         BOOL isSearchMode;

@property(nonatomic,strong)         NSArray *searchResultArray;

@property(nonatomic,strong)         NSNumber *feedBadgeNumber;


@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedIndex = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateBadgeNumber];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadge:)
                                                 name:notificationName
                                               object:nil];
    
    self.menuInfoDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:MENU_PLIST ofType:nil]];
    
    UINib *trackCellNib = [UINib nibWithNibName:@"MenuCell" bundle:nil];
    [self.tableView registerNib:trackCellNib
         forCellReuseIdentifier:@"MenuCell"];
    
    UINib *followCellNib = [UINib nibWithNibName:@"SuggestionCell" bundle:nil];
    [self.tableView registerNib:followCellNib
         forCellReuseIdentifier:@"SuggestionCell"];
    
    UINib *settingsCellNib = [UINib nibWithNibName:@"MenuSettingsCell" bundle:nil];
    [self.tableView registerNib:settingsCellNib
         forCellReuseIdentifier:@"MenuSettingsCell"];
    
    [self initErrorView];
    
    UITapGestureRecognizer *logoTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnLogo:)];
    [self.logoImageView addGestureRecognizer:logoTapRecognizer];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initErrorView
{
    self.errorView = [[UIView alloc] initWithFrame:CGRectMake(0, -30, 320, 30)];
    self.errorView.backgroundColor = [UIColor colorWithRGBHex:kAppMainColor];
    self.errorMessage = [[UILabel alloc] initWithFrame:self.errorView.bounds];
    self.errorMessage.textColor = [UIColor whiteColor];
    self.errorMessage.textAlignment = NSTextAlignmentCenter;
    [self.errorView addSubview:self.errorMessage];
    self.errorView.hidden = YES;
    [self.view addSubview:self.errorView];
}

#pragma mark - Set Reachability notifications

- (void)setReachabilityNotifications
{
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self showAndKeepTopErrorViewWithMessage:self.kErrorMessage autohide:NO];
    } else {
        [self hideTopErrorViewAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [networkReachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *) notification
{
    Reachability *reachability = [notification object];
    if ([reachability isReachable]) {
        [self hideTopErrorViewWithMessage:self.kConnectedMessage];
    }
    else {
        [self showAndKeepTopErrorViewWithMessage:self.kErrorMessage autohide:NO];
    }
}

#pragma mark - TableView Delegate & Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isSearchMode) {
        return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearchMode) {
        return self.searchResultArray.count;
    }
    else {
        if (section == 0) {
            return [self.menuInfoDictionary[kLabels] count];
        }
        else {
            return 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearchMode) {
        return 46.0f;
    }
    else {
        if (indexPath.section == 0) {
            return 60.0f;
        }
        else {
            return 40.0f;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0f;
    }
    else {
        return 50.0f;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearchMode) {
        static NSString *cellID = @"SuggestionCell";
        
        SuggestionCell *cell = (SuggestionCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SuggestionCell" owner:nil options:nil]lastObject];
        }
        
        if (self.searchResultArray && self.searchResultArray.count > 0) {
            IRSuggestion *suggestion = self.searchResultArray[indexPath.row];
            [cell setSuggestionInfo:suggestion];
            [cell setIsMenuSearch:YES];
        }
        
        return cell;
    }
    else {
        if (indexPath.section == 0) {
            static NSString *cellID = @"MenuCell";
            
            MenuCell *cell = (MenuCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:nil options:nil]lastObject];
            }
            
            cell.delegate = self;
            cell.indexPath = indexPath;
            
            if (indexPath.row == 0) {
                [cell setBadgeNumber:[self.feedBadgeNumber unsignedIntegerValue]];
            }
            
            [cell setTitle:self.menuInfoDictionary[kLabels][indexPath.row]];
            
            if (indexPath.row != 3) {
                [cell setIsProfileCell:NO];
            }
            else {
                [cell.image sd_setImageWithURL:[NSURL URLWithString:userManager.userInfo.profileImage relativeToURL:BASE_URL]];
                [cell setIsProfileCell:YES];
            }
            
            if (indexPath.row == self.selectedIndex) {
                [cell setIsSelected:YES];
            }
            else {
                [cell setIsSelected:NO];
            }
            
            return cell;
        }
        else {
            static NSString *cellID = @"MenuSettingsCell";
            
            MenuSettingsCell *cell = (MenuSettingsCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"MenuSettingsCell" owner:nil options:nil]lastObject];
            }
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL needToToggle = YES;
    
    [self.textField resignFirstResponder];
    
    if (self.isSearchMode) {
        if (self.searchResultArray && self.searchResultArray.count > indexPath.row) {
            IRSuggestion *suggestion = self.searchResultArray[indexPath.row];
            
            if (suggestion.username && ![suggestion.username isEqualToString:@""]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
                MFNewProfileViewController *profileVC = [storyboard instantiateViewControllerWithIdentifier:@"newProfileViewController"];
                
                profileVC.container=self.container;
                MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
                userInfo.username = suggestion.username;
                userInfo.profileImage = suggestion.avatar_url;
                userInfo.facebookID = suggestion.facebook_id;
                userInfo.extId = suggestion.ext_id;
                userInfo.name = suggestion.name;
                profileVC.userInfo = userInfo;
                
                MBProgressHUD *progressView = [[MBProgressHUD alloc]initWithView:self.view];
                [progressView setMode:MBProgressHUDModeIndeterminate];
                [progressView setLabelText:NSLocalizedString(@"Loading...",nil)];
                
                [[IRNetworkClient sharedInstance] userProfileWithUsername:suggestion.username
                                                             successBlock:^(NSDictionary *dictionary)
                 {
                     if(dictionary)
                     {
                         UINavigationController *navigationVC=[[UINavigationController alloc] initWithRootViewController:profileVC];
                         [navigationVC setNavigationBarHidden:YES];
                         
                         self.container.centerViewController=navigationVC;
                         
                         [self.container toggleLeftSideMenuCompletion:nil];
                     }
                     else
                     {
                         [self showAndKeepTopErrorViewWithMessage:self.kNetworkErrorMessage autohide:YES];
                     }
                     
                     
                     [progressView hide:YES];
                 }
                                                            failureBlock:^(NSString *errorMessage)
                 {
                     [progressView hide:YES];
                     [self showAndKeepTopErrorViewWithMessage:self.kNetworkErrorMessage autohide:YES];
                 }];
            }
            else
            {
                [self showErrorMessage:NSLocalizedString(@"Internal error", nil)];
            }
        }
    }
    else {
        if (indexPath.section == 0) {
            MenuCell *cell = (MenuCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
            [cell setIsSelected:NO];
            self.selectedIndex = indexPath.row;
            cell = (MenuCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
            [cell setIsSelected:YES];
            
            if (indexPath.row == 3) {
                UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Profile" bundle:nil];
                MFNewProfileViewController *profileVC=[storyboard instantiateViewControllerWithIdentifier:@"newProfileViewController"];
                profileVC.userInfo=userManager.userInfo;
                profileVC.container=self.container;
                
                UINavigationController *navigationVC=[[UINavigationController alloc] initWithRootViewController:profileVC];
                [navigationVC setNavigationBarHidden:YES];
                
                self.container.centerViewController=navigationVC;
            }
            else if (indexPath.row == 1) {
                PlaylistsViewController *playlistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
                playlistsVC.container = self.container;
                
                UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:playlistsVC];
                [navigationVC setNavigationBarHidden:YES];
                
                self.container.centerViewController = navigationVC;
            }
            else if (indexPath.row == 0) {
                FeedViewController *feedVC=[self.storyboard instantiateViewControllerWithIdentifier:@"feedViewController"];
                feedVC.container=self.container;
                feedVC.isMyMusic=NO;
                
                UINavigationController *navigationVC=[[UINavigationController alloc]initWithRootViewController:feedVC];
                [navigationVC setNavigationBarHidden:YES];
                
                self.container.centerViewController=navigationVC;
            }
            else if (indexPath.row == 2) {
                SuggestionsViewController *suggestionsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"suggestionsViewController"];
                suggestionsVC.container=self.container;
                
                UINavigationController *navigationVC=[[UINavigationController alloc]initWithRootViewController:suggestionsVC];
                [navigationVC setNavigationBarHidden:YES];
                
                self.container.centerViewController=navigationVC;
            }
            else if (indexPath.row == 4) {
                MFSettingsContainerViewController *settingsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"];
                settingsVC.container=self.container;
                
                [self.container.centerViewController pushViewController:settingsVC animated:NO];
            }
            else if (indexPath.row == 5) {
                needToToggle=NO;
                //[self openSendReview];
            }
        }
        else {
            if (indexPath.row == 0) {
                MFSettingsContainerViewController *settingsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"];
                settingsVC.container=self.container;
                
                [self.container.centerViewController pushViewController:settingsVC animated:NO];
            }
        }
        
        if (needToToggle) {
            [self.container toggleLeftSideMenuCompletion:nil];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Menu events notifications
- (void)menuStateEventOccurred:(NSNotification *)notification {
    MFSideMenuStateEvent event = [[[notification userInfo] objectForKey:@"eventType"] intValue];
    
    if (event == MFSideMenuStateEventMenuWillClose) {
        for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
            MenuCell *menuCell = (MenuCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (i == self.selectedIndex) {
                [menuCell setIsSelected:YES];
            } else {
                [menuCell setIsSelected:NO];
            }
        }

        [_textField resignFirstResponder];
    }
}

#pragma mark - Keyboard notifications
- (void)keyboardWillShow:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame=self.startTypingLabel.frame;
    frame.origin.y=(CGRectGetHeight(self.view.frame)-CGRectGetHeight(keyboardFrame)-SEARCH_OFFSET)/2+SEARCH_OFFSET;
    [self.startTypingLabel setFrame:frame];
}

#pragma mark - Badge notification

- (void)updateBadge:(NSNotification *)notification
{
    self.feedBadgeNumber = [notification.userInfo objectForKey:@"number"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Error message methods





#pragma mark - MFNewProfileViewControllerDelegate
- (void)menuButonTapped
{
    [self.container toggleLeftSideMenuCompletion:nil];
}
- (BOOL)showBackButton
{
    return NO;
}

#pragma mark - MenuCellDelegate methods

- (void)didHighlightCellAtIndexPath:(NSIndexPath *)indexPath
{
    MenuCell *cell = (MenuCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
    [cell setIsSelected:NO];
    cell = (MenuCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    [cell setIsSelected:YES];
}

#pragma mark - Tap events

- (void)didTapOnLogo:(id)sender
{
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

@end
