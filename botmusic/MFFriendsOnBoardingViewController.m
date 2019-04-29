//
//  MFFriendsOnBoardingViewController.m
//  botmusic
//
//  Created by Panda Systems on 8/27/15.
//
//

#import "MFFriendsOnBoardingViewController.h"
#import "MFOnBoardingFriendsAddTableViewCell.h"
#import "MFOnBoardingFriendTableViewCell.h"
#import "CPHContactsManager.h"
#import "MFNotificationManager.h"
#import "JLContactsPermission.h"

@interface MFFriendsOnBoardingViewController () <UITableViewDataSource, UITableViewDelegate, MFOnBoardingFriendTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *connectContactsView;
@property (weak, nonatomic) IBOutlet UIView *connectFacebookView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property(nonatomic, weak) UITextField* addField;
@property (nonatomic, strong) NSArray* unfollowedFriends;
@end

@implementation MFFriendsOnBoardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.showListOfGivenArtistsMode) {
        self.friends = [NSArray array];
        self.unfollowedFriends = [NSArray array];
        [self friendsRequest];

        if (self.friendsType == MFFriendsTypeImportedArtists) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshArtists) name:@"MFArtistsSent" object:nil];
        }
    } else {
        [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, self.tabBarController.tabBar.bounds.size.height, 0)];
        [self.tableView setContentOffset:CGPointMake(0, -(64))];
        self.headerView.hidden = NO;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)friendsRequest{
    if (self.friendsType == MFFriendsTypeContacts) {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined || status == kABAuthorizationStatusAuthorized) {
            [self contactsRequest];
        } else {
            self.connectContactsView.hidden = NO;
        }
    } else if (self.friendsType == MFFriendsTypeFacebook) {
        if (userManager.userInfo.facebookLink.length) {
            [self facebookRequest];
        } else {
            [self showConnectButton];
        }
    } else if (self.friendsType == MFFriendsTypeImportedArtists){
        [self artistsRequest];
    }
}

- (void) showConnectButton{
    self.connectFacebookView.hidden = NO;
}

-(void)contactsRequest{
    NSString* message = @"Search for You Friends? We need access to Contacts to see if any of your friends use Musicfeed.";
    [[JLContactsPermission sharedInstance] authorizeWithTitle:nil message:message cancelTitle:@"Later" grantTitle:@"Take me there" completion:^(bool granted, NSError *error) {
        if (granted) {
            [self completeContactsRequest];
            self.connectContactsView.hidden = YES;
        } else {
            if (error.code == JLPermissionSystemDenied){
                NSString* message = @"Musicfeed needs permission to access your address book";
                UIAlertController* ac = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
                [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [ac addAction:[UIAlertAction actionWithTitle:@"Go to settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }]];
                [self presentViewController:ac animated:YES completion:nil];
                self.connectContactsView.hidden = NO;
            } else if (error.code == JLPermissionUserDenied) {
                self.connectContactsView.hidden = NO;
            }
        }
    }];
}

- (void) completeContactsRequest{
    self.friends = [[userManager.userInfo.contacts array] copy];
    if (!self.friends.count) {
        [self.activityIndicator startAnimating];
        self.tableView.hidden = YES;
    }
    NSArray* contacts = [CPHContactsManager getAllContacts];
    NSMutableArray* formattedContacts = [NSMutableArray array];
    for (NSDictionary* contact in contacts) {
        NSMutableDictionary* fc = [NSMutableDictionary dictionary];
        if ([(NSArray*)contact[@"phones"] count]>0) {
            [fc setObject:contact[@"phones"][0][@"phone"] forKey:@"contact_number"];
        }
        if (contact[@"contactEmail"]) {
            [fc setObject:contact[@"contactEmail"] forKey:@"email"];
        }
        [formattedContacts addObject:fc];

    }
    if (!formattedContacts.count) {
        self.friends = [NSArray array];
        [self.activityIndicator stopAnimating];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        return;
    }
    [[IRNetworkClient sharedInstance] postContactList:formattedContacts
                                         successBlock:^(NSDictionary *dictionary) {
                                             //self.friends = [dictionary[@"users"] mutableCopy];
                                             NSMutableArray* friends = [[dataManager convertAndAddUserInfosToDatabase:dictionary[@"users"] userInfoType:MFUserInfoTypeContacts] mutableCopy];
                                             userManager.userInfo.contacts = [NSOrderedSet orderedSetWithArray:friends];

                                             for (MFUserInfo* ui in self.unfollowedFriends) {
                                                 if ([friends containsObject:ui]) {
                                                     [friends removeObject:ui];
                                                 }
                                             }

                                             self.friends = [friends copy];

                                             [self.activityIndicator stopAnimating];
                                             self.tableView.hidden = NO;
                                             [self.tableView reloadData];
                                         } failureBlock:^(NSString *errorMessage) {
                                             [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.onBoardingViewController];
                                             [self.activityIndicator stopAnimating];
                                             self.tableView.hidden = NO;
                                         }];
}
-(void)facebookRequest {
    self.friends = [[userManager.userInfo.facebookFriends array] copy];
    if (!self.friends.count) {
        [self.activityIndicator startAnimating];
        self.tableView.hidden = YES;
    }

    [[IRNetworkClient sharedInstance] getFacebookFriendsWithSuccessBlock:^(NSArray *array) {
        NSMutableArray* friends = [[dataManager convertAndAddUserInfosToDatabase:array userInfoType:MFUserInfoTypeFacebook] mutableCopy];
        userManager.userInfo.facebookFriends = [NSOrderedSet orderedSetWithArray: friends];

        for (MFUserInfo* ui in self.unfollowedFriends) {
            if ([friends containsObject:ui]) {
                [friends removeObject:ui];
            }
        }
        self.friends = [friends copy];

        [self.activityIndicator stopAnimating];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.onBoardingViewController];
        [self.activityIndicator stopAnimating];
        self.tableView.hidden = NO;
    }];
}

-(void)artistsRequest {
    self.friends = [[userManager.userInfo.importedArtists array] copy];

    if (!self.friends.count) {
        [self.activityIndicator startAnimating];
        self.tableView.hidden = YES;
    }

    [[IRNetworkClient sharedInstance] getPhoneArtistsSuccessBlock:^(NSArray *array) {

        NSMutableArray* friends = [[dataManager convertAndAddUserInfosToDatabase:array userInfoType:MFUserInfoTypeImportedArtists] mutableCopy];
        userManager.userInfo.importedArtists = [NSOrderedSet orderedSetWithArray: friends];

        for (MFUserInfo* ui in self.unfollowedFriends) {
            if ([friends containsObject:ui]) {
                [friends removeObject:ui];
            }
        }
        self.friends = [friends copy];

        [self.activityIndicator stopAnimating];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.onBoardingViewController];
        [self.activityIndicator stopAnimating];
        self.tableView.hidden = NO;
    }];
}

- (void)refreshArtists{
    [[IRNetworkClient sharedInstance] getPhoneArtistsSuccessBlock:^(NSArray *array) {

        self.friends = [dataManager convertAndAddUserInfosToDatabase:array userInfoType:MFUserInfoTypeImportedArtists];
        userManager.userInfo.importedArtists = [NSOrderedSet orderedSetWithArray: self.friends];

        [self.tableView reloadData];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.onBoardingViewController];

    }];
}

- (void) cellDidChangeFollowedState:(MFOnBoardingFriendTableViewCell *)cell{
    if (!cell.contact.isFollowed) {
        cell.followedMark.hidden = NO;
        cell.followButton.hidden = YES;
        cell.contact.isFollowed = YES;
        NSDictionary *proposalsDictionary = @{@"ext_id" : cell.contact.extId,
                                              @"followed" : @"true"};
        MFUserInfo* contact = cell.contact;

        [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                          token:[userManager fbToken]
                                                      proposals:@[proposalsDictionary]
                                                   successBlock:^{
                                                       [MFNotificationManager postUpdateUserFollowingNotification:contact];

                                                   }
                                                   failureBlock:^(NSString *errorMessage){
                                                       [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.onBoardingViewController];

//                                                       cell.followedMark.hidden = YES;
//                                                       cell.followButton.hidden = NO;

                                                       contact.isFollowed = NO;
                                                   }];

    } else {

        cell.followedMark.hidden = YES;
        cell.followButton.hidden = NO;
        cell.contact.isFollowed = NO;

        NSMutableArray* newFriends = [self.friends mutableCopy];
        NSMutableArray* newUnfollowedFriends = [self.unfollowedFriends mutableCopy];

        MFUserInfo* contact = cell.contact;

        if ([newFriends containsObject:contact]) {
            [newFriends removeObject:contact];
            [newUnfollowedFriends addObject:contact];
            NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            [newUnfollowedFriends sortUsingDescriptors:@[sortOrder]];
            self.friends = [newFriends copy];
            self.unfollowedFriends = [newUnfollowedFriends copy];
            [self.tableView reloadData];
        }

        NSDictionary *proposalsDictionary = @{@"ext_id" : cell.contact.extId,
                                              @"followed" : @"false"};

        [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                          token:[userManager fbToken]
                                                      proposals:@[proposalsDictionary]
                                                   successBlock:^{
                                                       [MFNotificationManager postUpdateUserFollowingNotification:contact];
                                                   }
                                                   failureBlock:^(NSString *errorMessage){
                                                       [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.onBoardingViewController];

//                                                       cell.followedMark.hidden = NO;
//                                                       cell.followButton.hidden = YES;
                                                       contact.isFollowed = YES;
                                                   }];
    }

}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MFOnBoardingFriendTableViewCell* artistCell = (MFOnBoardingFriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];

    if (self.showListOfGivenArtistsMode) {

        [self showUserProfileWithUserInfo:artistCell.contact];

    } else {
        if (indexPath.row==0) {

            if (self.friendsType == MFFriendsTypeContacts) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MFShowShareSheet" object:nil];
            } else if (self.friendsType == MFFriendsTypeFacebook) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MFShowFacebookInvite" object:nil];
            }
        } else {
            if (self.onBoardingViewController.presentationMode == MFOnBoardingViewControllerPresentationModeFull) {
                [self cellDidChangeFollowedState:artistCell];
            } else {
                [self.onBoardingViewController showUserProfileWithUserInfo:artistCell.contact];
            }
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        if (self.showListOfGivenArtistsMode) {
            return 0;
        }
        return 45;
    } else {
        return 45;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1+self.friends.count + self.unfollowedFriends.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell;
    if (indexPath.row == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"MFOnBoardingFriendsAddTableViewCell"];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"MFOnBoardingFriendsAddTableViewCell" owner:self options:nil][0];
            [[(MFOnBoardingFriendsAddTableViewCell*)cell searchButton] addTarget:self action:@selector(addButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            self.addField = [(MFOnBoardingFriendsAddTableViewCell*)cell textField];
            [self.addField addTarget:self action:@selector(addButtonTapped) forControlEvents:UIControlEventEditingDidEndOnExit];
        }
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"MFOnBoardingFriendTableViewCell"];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"MFOnBoardingFriendTableViewCell" owner:self options:nil][0];
        }
        MFOnBoardingFriendTableViewCell* artistCell = (MFOnBoardingFriendTableViewCell*)cell;
        NSArray* allFriends = [self.friends arrayByAddingObjectsFromArray:self.unfollowedFriends];
        [artistCell setUserInfo:allFriends[indexPath.row-1]];
        artistCell.delegate = self;
        if (indexPath.row == self.friends.count + self.unfollowedFriends.count) {
            artistCell.separatorView.hidden = YES;
        } else {
            artistCell.separatorView.hidden = NO;
        }
    }
    return cell;
}

- (void)addButtonTapped{
    [self.addField resignFirstResponder];
}

- (IBAction)connectFB:(id)sender {
    /*
    if (!userManager.fbSession || (userManager.fbSession.state != FBSessionStateCreated))
    {
        // Create a new, logged out session.

        NSLogExt(@"Creating new fb session");
        userManager.fbSession = [[FBSession alloc] initWithPermissions:@[@"email", @"user_posts", @"user_likes",@"user_friends",@"user_actions.music",@"public_profile",@"user_birthday"]];
    }
    else
    {
        [self fbLoggedIn];
    }

    // if the session isn't open, let's open it now and present the login UX to the user
    [FBSession setActiveSession:userManager.fbSession];
    // if the session isn't open, let's open it now and present the login UX to the user
    [userManager.fbSession openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent fromViewController:self.onBoardingViewController completionHandler:^(FBSession *session,
                                                                                                                                        FBSessionState status,
                                                                                                                                        NSError *error) {
        if (status == FBSessionStateOpen)
        {
            [self fbLoggedIn];
        }
        else
        {

        }
    }];
     */
}

/*
- (void)fbLoggedIn{
    self.connectFacebookView.hidden = YES;
    [self.activityIndicator startAnimating];
    if (userManager.fbSession.accessTokenData.userID && userManager.fbSession.accessTokenData.accessToken) {
        [[IRNetworkClient sharedInstance] connectToFacebookID:userManager.fbSession.accessTokenData.userID withEmail:userManager.userInfo.email facebookToken:userManager.fbSession.accessTokenData.accessToken token:userManager.fbToken successBlock:^(NSDictionary *userData) {
            [self.activityIndicator stopAnimating];
            [self facebookRequest];
        } failureBlock:^(NSString *errorMessage) {
            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.onBoardingViewController];

            [self.activityIndicator stopAnimating];
            self.connectFacebookView.hidden = NO;
        }];
    } else {
        [self.activityIndicator stopAnimating];
        self.connectFacebookView.hidden = NO;
    }
}
*/

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)connectToContactsButtonTapped:(id)sender {
    [self contactsRequest];
}

@end
