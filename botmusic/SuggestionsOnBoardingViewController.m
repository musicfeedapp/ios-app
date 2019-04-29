//
//  SuggestionsOnBoardingViewController.m
//  botmusic
//
//  Created by Panda Systems on 8/25/15.
//
//

#import "SuggestionsOnBoardingViewController.h"
#import "MFOnBoardingSuggestionsSearchTableViewCell.h"
#import "MFOnBoardingSuggestionTableViewCell.h"
#import "MFSuggestion+Behavior.h"
#import "MFNotificationManager.h"
#import "MFFollowersViewController.h"

@interface SuggestionsOnBoardingViewController () <UITableViewDataSource, UITableViewDelegate, MFOnBoardingSuggestionTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray* suggestions;
@property(nonatomic, strong) NSArray* unfollowedSuggestions;
@property(nonatomic, strong) NSArray* searchedSuggestions;
@property(nonatomic) BOOL isInSearchMode;
@property(nonatomic, weak) UITextField* searchField;
@end

@implementation SuggestionsOnBoardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.suggestions = [userManager.userInfo.suggestions array];
    self.unfollowedSuggestions = [NSArray array];
    [self suggestionRequest];
    NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateUserFollowing];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateFollowing:)
                                                 name:notificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(suggestionsLoaded)
                                                 name:@"MFSuggestionsLoadedAfterLogin"
                                               object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)suggestionRequest
{
    if (!self.suggestions.count) {
        [self.activityIndicator startAnimating];
        self.tableView.hidden = YES;
    }
    [[IRNetworkClient sharedInstance] getSuggestionsFilteredWithEmail:userManager.userInfo.email
                                                                token:[userManager fbToken]
                                                           filterType:nil
                                                         successBlock:^(NSDictionary *suggestionArray){

                                                             NSArray *allSuggestions = suggestionArray[@"artists"];
                                                             NSMutableArray* suggestions = [[dataManager processSuggestions:allSuggestions] mutableCopy];
                                                             userManager.userInfo.suggestions = [NSOrderedSet orderedSetWithArray:suggestions];

                                                             if (!self.isInSearchMode) {
                                                                 for (MFSuggestion* suggestion in self.unfollowedSuggestions) {
                                                                     if ([suggestions containsObject:suggestion]) {
                                                                         [suggestions removeObject:suggestion];
                                                                     }
                                                                 }
                                                                 
                                                             }

                                                             self.suggestions = [suggestions copy];

                                                             if (!self.isInSearchMode) {
                                                                 [self.activityIndicator stopAnimating];
                                                                 self.tableView.hidden = NO;
                                                                 if ([self.searchField isFirstResponder]) {
                                                                     [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                                                                 } else {
                                                                     [self.tableView reloadData];
                                                                 }
                                                             }

                                                         } failureBlock:^(NSString *errorMessage) {
                                                             [self.activityIndicator stopAnimating];
                                                             self.tableView.hidden = NO;
         
                                                         }];
}

- (void)suggestionsLoaded{
    self.suggestions = [userManager.userInfo.suggestions array];
    if (!self.isInSearchMode) {
        [self.activityIndicator stopAnimating];
        self.tableView.hidden = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}
- (void)makeSearchRequestWithKeyword:(NSString *)keyword
{
    [FBSDKAppEvents logEvent:FBSDKAppEventNameSearched parameters:@{FBSDKAppEventParameterNameSearchString : keyword}];
    userManager.lastSearchKeyword = keyword;
    [[IRNetworkClient sharedInstance] searchWithKeyword:keyword searchType:@"all" success:^(NSDictionary *dictionary) {

        NSArray* allArtistsArray = [NSArray arrayWithArray:[DataConverter convertSuggestions:dictionary[@"artists"]]];
        self.searchedSuggestions = allArtistsArray;
        if (self.isInSearchMode) {
            [self.activityIndicator stopAnimating];
            self.tableView.hidden = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }

    } failure:^(NSString *errorMessage) {

    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 45;
    } else {
        return 45;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else {
        if (self.isInSearchMode) {
            return self.searchedSuggestions.count;
        } else {
            return self.suggestions.count + self.unfollowedSuggestions.count;
        }
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell;
    if (indexPath.section == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"MFOnBoardingSuggestionsSearchTableViewCell"];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"MFOnBoardingSuggestionsSearchTableViewCell" owner:self options:nil][0];
            [[(MFOnBoardingSuggestionsSearchTableViewCell*)cell searchButton] addTarget:self action:@selector(searchButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            self.searchField = [(MFOnBoardingSuggestionsSearchTableViewCell*)cell textField];
            [self.searchField addTarget:self action:@selector(searchButtonTapped) forControlEvents:UIControlEventEditingDidEndOnExit];
            [self.searchField addTarget:self action:@selector(searchFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"MFOnBoardingSuggestionTableViewCell"];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"MFOnBoardingSuggestionTableViewCell" owner:self options:nil][0];
        }
        MFOnBoardingSuggestionTableViewCell* artistCell = (MFOnBoardingSuggestionTableViewCell*)cell;
        if (self.isInSearchMode) {
            [artistCell setSearchResultInfo:self.searchedSuggestions[indexPath.row]];
        } else {
            NSArray* allSuggestions = [self.suggestions arrayByAddingObjectsFromArray:self.unfollowedSuggestions];
            [artistCell setSuggestionInfo:allSuggestions[indexPath.row]];
        }
        if (indexPath.row == self.suggestions.count + self.unfollowedSuggestions.count) {
            artistCell.separatorView.hidden = YES;
        } else {
            artistCell.separatorView.hidden = NO;
        }
        artistCell.delegate = self;
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MFOnBoardingSuggestionTableViewCell* cell = (MFOnBoardingSuggestionTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (self.onBoardingViewController.presentationMode == MFOnBoardingViewControllerPresentationModeFull) {
        [self shouldFollow:cell];
    } else {
        [self shouldOpenProfile:cell];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

//    if (!self.isInSearchMode && self.onBoardingViewController.presentationMode != MFOnBoardingViewControllerPresentationModeFull) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        MFFollowersViewController* followersVC = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"followersViewController"];
//        if ([cell.suggestion isKindOfClass:[MFSuggestion class]] && cell.suggestion.commonFollowers.count) {
//            followersVC.followers = [[cell.suggestion.commonFollowers array] mutableCopy];
//            followersVC.isMyFollowItems = NO;
//            followersVC.shouldJustDisplayGivenFollowItems = YES;
//            followersVC.numberOfTotalFollowers = (int)cell.suggestion.followersCount;
//            [self.onBoardingViewController.navigationController pushViewController:followersVC animated:YES];
//        }
//    }

//    if (indexPath.section!=0) {
//        MFOnBoardingSuggestionTableViewCell* artistCell = (MFOnBoardingSuggestionTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//        if (!artistCell.suggestion.is_followed) {
//            artistCell.followedMark.hidden = NO;
//            [[IRNetworkClient sharedInstance]followSuggestionWithArtistId:artistCell.suggestion.identifier
//                                                             successBlock:^{
//                                                                 artistCell.suggestion.is_followed = YES;
//                                                                 [MFNotificationManager postUpdateUserFollowingNotification:nil];
//                                                             }
//                                                             failureBlock:^(NSString *errorMessage){
//                                                                 artistCell.followedMark.hidden = YES;
//                                                             }];
//        } else {
//            NSDictionary *proposalsDictionary = @{@"ext_id" : artistCell.suggestion.ext_id,
//                                                  @"followed" : @"false"};
//            artistCell.followedMark.hidden = YES;
//            [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
//                                                              token:[userManager fbToken]
//                                                          proposals:@[proposalsDictionary]
//                                                       successBlock:^{
//                                                           artistCell.suggestion.is_followed = NO;
//                                                           [MFNotificationManager postUpdateUserFollowingNotification:nil];
//                                                       }
//                                                       failureBlock:^(NSString *errorMessage){
//                                                           artistCell.followedMark.hidden = NO;
//                                                       }];
//        }
//    }

}

- (void)shouldOpenProfile:(MFOnBoardingSuggestionTableViewCell *)cell{
    if (self.onBoardingViewController.presentationMode != MFOnBoardingViewControllerPresentationModeFull) {
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:cell.suggestion.ext_id];
        userInfo.profileImage = cell.suggestion.avatar_url;
        userInfo.name = cell.suggestion.name;
        [self.onBoardingViewController showUserProfileWithUserInfo:userInfo];
    }
}

- (void)shouldFollow:(MFOnBoardingSuggestionTableViewCell *)cell{

    cell.followedMark.hidden = NO;
    cell.followButton.hidden = !cell.followedMark.hidden;

    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:cell.suggestion.ext_id];
    MFSuggestion* suggestion = cell.suggestion;
    suggestion.is_followed = YES;

    [[IRNetworkClient sharedInstance]followSuggestionWithArtistId:suggestion.identifier
                                                     successBlock:^{
                                                         userInfo.isFollowed = YES;
                                                         [MFNotificationManager postUpdateUserFollowingNotification:userInfo];
                                                     }
                                                     failureBlock:^(NSString *errorMessage){
                                                         suggestion.is_followed = NO;
                                                         if (cell.suggestion == suggestion) {
                                                             cell.followedMark.hidden = YES;
                                                             cell.followButton.hidden = !cell.followedMark.hidden;
                                                         }
                                                         [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                                     }];
}

- (void) shouldUnFollow:(MFOnBoardingSuggestionTableViewCell *)cell{

    cell.followedMark.hidden = YES;
    cell.followButton.hidden = !cell.followedMark.hidden;

    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:cell.suggestion.ext_id];
    MFSuggestion* suggestion = cell.suggestion;
    suggestion.is_followed = NO;

    if (!self.isInSearchMode) {

        NSMutableArray* mutableSugg = [self.suggestions mutableCopy];
        if ([mutableSugg containsObject:suggestion]) {

            [mutableSugg removeObject:suggestion];
            self.suggestions = [mutableSugg copy];
            NSMutableArray* unfollowedSugg = [self.unfollowedSuggestions mutableCopy];
            [unfollowedSugg addObject:suggestion];
            NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            [unfollowedSugg sortUsingDescriptors:@[sortOrder]];

            self.unfollowedSuggestions = [unfollowedSugg copy];

            [self.tableView reloadData];

        }

    }

    NSDictionary *proposalsDictionary = @{@"ext_id" : suggestion.ext_id,
                                          @"followed" : @"false"};
    [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                      token:[userManager fbToken]
                                                  proposals:@[proposalsDictionary]
                                               successBlock:^{
                                                   userInfo.isFollowed = NO;
                                                   [MFNotificationManager postUpdateUserFollowingNotification:userInfo];
                                               }
                                               failureBlock:^(NSString *errorMessage){
                                                   suggestion.is_followed = YES;
                                                   if (cell.suggestion == suggestion) {
                                                       cell.followedMark.hidden = NO;
                                                       cell.followButton.hidden = !cell.followedMark.hidden;
                                                   }
                                                   [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                               }];


}

- (void)didUpdateFollowing:(NSNotification *)notification
{
    MFUserInfo* ui = notification.userInfo[@"user_info"];
    if (ui) {
        for (MFSuggestion* suggestion in self.suggestions) {
            if ([suggestion.ext_id isEqualToString:ui.extId]) {
                suggestion.is_followed = ui.isFollowed;
                NSIndexPath* ip = [NSIndexPath indexPathForItem:[self.suggestions indexOfObject:suggestion] inSection:1];
                [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (void)searchButtonTapped{
    [self.searchField resignFirstResponder];
}

- (void)searchFieldEditingChanged{
    if (self.searchField.text.length) {
        self.isInSearchMode = YES;
        [self makeSearchRequestWithKeyword:self.searchField.text];
    } else {
        self.isInSearchMode = NO;
        [self.activityIndicator stopAnimating];
        self.tableView.hidden = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end