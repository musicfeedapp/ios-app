//
//  NewSearchViewController.m
//  botmusic
//
//  Created by Panda Systems on 10/8/15.
//
//

#import "NewSearchViewController.h"
#import "PlaylistTrackCell.h"
#import "MFNewSearchHeaderView.h"
#import "MFFollowingTableCell.h"
#import "MFNotificationManager.h"
#import "PlaylistsViewController.h"
#import "MFSuggestionSmallCollectionViewCell.h"
#import "UIImageView+WebCache_FadeIn.h"
#import "MFSuggestionTrackCollectionViewCell.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MFSuggestion+Behavior.h"
#import "MFSuggestionTableViewCell.h"
#import "UIColor+Expanded.h"
#import "MFRecentSearchTableViewCell.h"
#import "MFSuggestionsFilterTypeTableViewCell.h"
#import "MFDirectLinkOverlay.h"
#import "MFFollowersViewController.h"

typedef enum : NSUInteger {
    NewSearchViewControllerFilteredTypeArtists,
    NewSearchViewControllerFilteredTypeUsers,
    NewSearchViewControllerFilteredTypeTracks,
    NewSearchViewControllerFilteredTypeSuggestions,
    NewSearchViewControllerFilteredTypeRecentSearches,
    NewSearchViewControllerFilteredTypeFilterCategories,
} NewSearchViewControllerFilteredType;

NSString * const MFRecentSearchesUserDefaultsKey = @"MFRecentSearchesUserDefaultsKey";

@interface NewSearchViewController () <PlaylistTrackCellDelegate, MFFollowingTableCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, MFSuggestionTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) NSArray* trackResults;
@property (strong, nonatomic) NSArray* artistsResults;
@property (strong, nonatomic) NSArray* usersResults;

@property (weak, nonatomic) IBOutlet UIView *darkenView;

@property (weak, nonatomic) IBOutlet UILabel *filteredLabel;
@property (weak, nonatomic) IBOutlet UITableView *filteredTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categorizedViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categorizedViewWidth;
@property (nonatomic) NewSearchViewControllerFilteredType type;
@property (weak, nonatomic) IBOutlet UIView *suggestionsView;
@property (nonatomic, strong) NSArray* suggestions;
@property (nonatomic, strong) NSArray* trendingArtists;
@property (nonatomic, strong) NSArray* suggestionTracks;

@property (weak, nonatomic) IBOutlet UICollectionView *suggestionsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *suggestionCollectionViewFlowLayout;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *suggestionTracksCollectionViewFlowLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *suggestionsTracksCollectionView;
@property (nonatomic) NSInteger selectedFilterIndex;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (nonatomic, strong) NSTimer* savingKeywordTimer;
@property (nonatomic, strong) NSArray* suggestionsCategories;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) MFDirectLinkOverlay* instructionalOverlay;

@end

@implementation NewSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"MFUserLoggedIn" object:nil];
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
                                             selector:@selector(statusBarTapped:)
                                                 name:notificationStatusBarTappedName
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(suggestionsLoaded)
                                                 name:@"MFSuggestionsLoadedAfterLogin"
                                               object:nil];

    // Do any additional setup after loading the view from its nib.
    self.searchField.delegate = self;
    UINib *playlistTrackCellNib = [UINib nibWithNibName:@"PlaylistTrackCell" bundle:nil];
    [self.resultsTableView registerNib:playlistTrackCellNib forCellReuseIdentifier:@"PlaylistTrackCell"];
    [self.filteredTableView registerNib:playlistTrackCellNib forCellReuseIdentifier:@"PlaylistTrackCell"];
    UINib *followCellNib = [UINib nibWithNibName:@"MFFollowingTableCell" bundle:nil];
    [self.resultsTableView registerNib:followCellNib forCellReuseIdentifier:@"MFFollowingTableCell"];
    [self.filteredTableView registerNib:followCellNib forCellReuseIdentifier:@"MFFollowingTableCell"];

    self.filteredTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.resultsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    UINib *suggestionSmall = [UINib nibWithNibName:@"MFSuggestionSmallCollectionViewCell" bundle:nil];
    [self.suggestionsCollectionView registerNib:suggestionSmall forCellWithReuseIdentifier:@"MFSuggestionSmallCollectionViewCell"];
    
    UINib *trackSmall = [UINib nibWithNibName:@"MFSuggestionTrackCollectionViewCell" bundle:nil];
    [self.suggestionsTracksCollectionView registerNib:trackSmall forCellWithReuseIdentifier:@"MFSuggestionTrackCollectionViewCell"];
    
    UINib *suggestionsCellNib = [UINib nibWithNibName:@"MFSuggestionTableViewCell" bundle:nil];
    [self.filteredTableView registerNib:suggestionsCellNib forCellReuseIdentifier:@"MFSuggestionTableViewCell"];
    
    UINib *searchrecentCellNib = [UINib nibWithNibName:@"MFRecentSearchTableViewCell" bundle:nil];
    [self.filteredTableView registerNib:searchrecentCellNib forCellReuseIdentifier:@"MFRecentSearchTableViewCell"];

    UINib *filtertypeCellNib = [UINib nibWithNibName:@"MFSuggestionsFilterTypeTableViewCell" bundle:nil];
    [self.filteredTableView registerNib:filtertypeCellNib forCellReuseIdentifier:@"MFSuggestionsFilterTypeTableViewCell"];

    self.resultsTableView.hidden = YES;
    self.suggestionsView.hidden = NO;

    self.suggestionCollectionViewFlowLayout.itemSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width - 20.0)/4.0, 91);
    self.suggestionTracksCollectionViewFlowLayout.itemSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width - 20.0)/4.0, 88);
    self.categorizedViewWidth.constant = [UIScreen mainScreen].bounds.size.width;
    [self setCachedData];
    [self suggestionRequest];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setCachedData{
    if (userManager.isLoggedIn) {
        self.suggestions = [[userManager.userInfo.suggestions array] copy];
        self.trendingArtists = [[userManager.userInfo.trendingArtists array] copy];
        self.suggestionTracks = [[userManager.userInfo.trendingTracks array] copy];
    } else {
        self.suggestions = [[[dataManager getAnonUserInfo].suggestions array] copy];
        self.trendingArtists = [[[dataManager getAnonUserInfo].trendingArtists array] copy];
        self.suggestionTracks = [[[dataManager getAnonUserInfo].trendingTracks array] copy];
    }
}

- (void)updateData{
    [self setCachedData];
    [self.suggestionsCollectionView reloadData];
    [self.suggestionsTracksCollectionView reloadData];
    [self.filteredTableView reloadData];
    [self suggestionRequest];
}

- (void)reloadData{
    if (self.isViewLoaded) {
        [self suggestionRequest];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self suggestionRequest];
    UIEdgeInsets insets = self.resultsTableView.contentInset;
    insets.bottom = self.tabBarController.tabBar.bounds.size.height;
    self.resultsTableView.contentInset = insets;
    
    UIEdgeInsets insets2 = self.filteredTableView.contentInset;
    insets2.bottom = self.tabBarController.tabBar.bounds.size.height;
    self.filteredTableView.contentInset = insets2;

    if (self.shouldNavigateToSuggestionsAfterViewLoaded) {
        [self showAllSuggestionsAnimated:NO];
        self.shouldNavigateToSuggestionsAfterViewLoaded = NO;
    }

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
    NSNumber* overlayShown = [userDefauls objectForKey:@"DirectLinkTutorialOverlayWasShown"];
    if (!overlayShown) {
        [self showTutorialOverlay];
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"DirectLinkTutorialOverlayWasShown"];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldEditingChanged:(id)sender {
    if (self.searchField.text.length>0) {
        [self searchWithString:self.searchField.text];
        self.resultsTableView.hidden = NO;
        self.suggestionsView.hidden = YES;
    } else {
        self.resultsTableView.hidden = YES;
        self.suggestionsView.hidden = NO;
    }
}

- (void)makeSearchRequestWithKeyword:(NSString *)keyword
{
    [FBSDKAppEvents logEvent:FBSDKAppEventNameSearched parameters:@{FBSDKAppEventParameterNameSearchString : keyword}];
    userManager.lastSearchKeyword = keyword;
    [[IRNetworkClient sharedInstance] searchWithKeyword:keyword searchType:@"all" success:^(NSDictionary *dictionary) {
        NSMutableArray *tempTracks = [[dataManager convertAndAddTracksToDatabase:dictionary[@"timelines"]]mutableCopy];
        self.trackResults = tempTracks;
        NSArray* allArtistsArray = [NSArray arrayWithArray:[DataConverter convertSuggestions:dictionary[@"artists"]]];
        NSArray* allPeopleArray = [NSArray arrayWithArray:[DataConverter convertSuggestions:dictionary[@"users"]]];
        self.artistsResults = allArtistsArray;
        self.usersResults = allPeopleArray;
        [self.resultsTableView reloadData];
        [self.filteredTableView reloadData];
        if ((self.type == NewSearchViewControllerFilteredTypeSuggestions || self.type == NewSearchViewControllerFilteredTypeRecentSearches || self.type == NewSearchViewControllerFilteredTypeFilterCategories) && self.categorizedViewLeadingConstraint.constant != 0.0) {
            [self backToCategorizedButtonTapped:nil];
        }
    } failure:^(NSString *errorMessage) {
        
    }];
}

- (void)makeSearchRequestWithLink:(NSString *)url
{
    [[IRNetworkClient sharedInstance] findTrackByUrl:url SuccessBlock:^(NSDictionary *dictionary) {
        NSMutableArray *tempTracks = [[dataManager convertAndAddTracksToDatabase:@[dictionary]]mutableCopy];
        self.trackResults = tempTracks;
        self.artistsResults = [NSArray array];
        self.usersResults = [NSArray array];
        [self.resultsTableView reloadData];
        [self.filteredTableView reloadData];
        if ((self.type == NewSearchViewControllerFilteredTypeSuggestions || self.type == NewSearchViewControllerFilteredTypeRecentSearches || self.type == NewSearchViewControllerFilteredTypeFilterCategories) && self.categorizedViewLeadingConstraint.constant != 0.0) {
            [self backToCategorizedButtonTapped:nil];
        }
    } failureBlock:^(NSString *errorMessage) {
        if ([errorMessage containsString:@"We can't find record by requested params."]) {
            self.trackResults = [NSArray array];
            self.artistsResults = [NSArray array];
            self.usersResults = [NSArray array];
            [self.resultsTableView reloadData];
            [self.filteredTableView reloadData];
        } else {
            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
        }
    }];
}


- (void)searchWithString:(NSString*)string{
    if ([string hasPrefix:@"http://"] || [string hasPrefix:@"https://"] || [string hasPrefix:@"HTTP://"] || [string hasPrefix:@"HTTPS://"]) {
        [self makeSearchRequestWithLink:string];
    } else {
        [self makeSearchRequestWithKeyword:string];
        [self didSearchWithKeyword:string];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.filteredTableView) {
        return 1;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.filteredTableView) {
        if (self.type == NewSearchViewControllerFilteredTypeTracks) {
            return self.trackResults.count;
        }
        if (self.type == NewSearchViewControllerFilteredTypeArtists) {
            return self.artistsResults.count;
        }
        if (self.type == NewSearchViewControllerFilteredTypeUsers) {
            return self.usersResults.count;
        }
        if (self.type == NewSearchViewControllerFilteredTypeSuggestions) {
            return self.suggestions.count;
        }
        if (self.type == NewSearchViewControllerFilteredTypeRecentSearches) {
            return [self recentSearches].count;
        }
        if (self.type == NewSearchViewControllerFilteredTypeFilterCategories) {
            return [self suggestionsCategories].count;
        }
    }
    if (section == 0) {
        if (self.trackResults.count>5) {
            return 5;
        } else {
            return self.trackResults.count;
        }
    } else if (section == 1){
        if (self.artistsResults.count>5) {
            return 5;
        } else {
            return self.artistsResults.count;
        }
    } else if (section == 2){
        if (self.usersResults.count>5) {
            return 5;
        } else {
            return self.usersResults.count;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _filteredTableView && _type == NewSearchViewControllerFilteredTypeSuggestions) {
        return 275.0;
    }
    if (tableView == _filteredTableView && _type == NewSearchViewControllerFilteredTypeRecentSearches) {
        return 44.0;
    }
    if (tableView == _filteredTableView && _type == NewSearchViewControllerFilteredTypeFilterCategories) {
        return 45.0;
    }
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.filteredTableView) {
        return 0;
    }
    if (section == 0 && self.trackResults.count == 0) {
        return 0;
    }
    if (section == 1 && self.artistsResults.count == 0){
        return 0;
    }
    if (section == 2 && self.usersResults.count == 0){
        return 0;
    }
    return 40.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30.0)];
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    
//    gradient.frame = view.bounds;
//    UIColor *startColour = [UIColor colorWithWhite:0.0 alpha:0.0];
//    UIColor *endColour = [UIColor colorWithWhite:0.0 alpha:0.05];
//    [gradient setStartPoint:CGPointMake(0.5, 0.0)];
//    [gradient setEndPoint:CGPointMake(0.5, 1.0)];
//    gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
//    [view.layer addSublayer:gradient];
//    return view;
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == self.filteredTableView) {
        return nil;
    }
    MFNewSearchHeaderView* header = [[[NSBundle mainBundle] loadNibNamed:@"MFNewSearchHeaderView" owner:nil options:nil] lastObject];
    if (section == 0) {
        header.label.text = NSLocalizedString(@"TRACKS", nil);
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allTracksTapped)];
        [header addGestureRecognizer:recognizer];
    } else if (section == 1){
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allArtistsTapped)];
        [header addGestureRecognizer:recognizer];
        header.label.text = NSLocalizedString(@"ARTISTS", nil);
    } else if (section == 2){
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allUsersTapped)];
        [header addGestureRecognizer:recognizer];
        header.label.text = NSLocalizedString(@"PEOPLE", nil);
    }
    return header;
}

- (void)allArtistsTapped{
    self.filteredLabel.text = NSLocalizedString(@"Artists", nil);
    self.type = NewSearchViewControllerFilteredTypeArtists;
    [self.filteredTableView reloadData];
    self.filteredTableView.backgroundColor = [UIColor whiteColor];
    self.filterButton.hidden = YES;
    [self showFilteredTable];
}

- (void)allUsersTapped{
    self.filteredLabel.text = NSLocalizedString(@"Users", nil);
    self.type = NewSearchViewControllerFilteredTypeUsers;
    [self.filteredTableView reloadData];
    self.filteredTableView.backgroundColor = [UIColor whiteColor];
    self.filterButton.hidden = YES;
    [self showFilteredTable];
}


- (void)allTracksTapped{
    self.filteredLabel.text = NSLocalizedString(@"Tracks", nil);
    self.type = NewSearchViewControllerFilteredTypeTracks;
    [self.filteredTableView reloadData];
    self.filteredTableView.backgroundColor = [UIColor whiteColor];
    self.filterButton.hidden = YES;
    [self showFilteredTable];
}

- (IBAction)allSuggestionsTapped{
    [self showAllSuggestionsAnimated:YES];
}

- (void) showAllSuggestionsAnimated:(BOOL)animated{
    if (self.suggestionsCategories.count) {
        self.filteredLabel.text = NSLocalizedString(self.suggestionsCategories[_selectedFilterIndex][0], nil);
    } else {
        self.filteredLabel.text = NSLocalizedString(@"All Suggestions", nil);
    }
    self.type = NewSearchViewControllerFilteredTypeSuggestions;
    [self.filteredTableView reloadData];
    self.filteredTableView.backgroundColor = [UIColor colorWithRGBHex:0xE5E5E5];
    self.filterButton.hidden = NO;
    [self showFilteredTableAnimated:animated];
}

- (IBAction)recentSearchesTapped{
    self.filteredLabel.text = NSLocalizedString(@"Recent Searches", nil);
    self.type = NewSearchViewControllerFilteredTypeRecentSearches;
    [self.filteredTableView reloadData];
    self.filteredTableView.backgroundColor = [UIColor colorWithRGBHex:0xE5E5E5];
    self.filterButton.hidden = YES;
    [self showFilteredTable];
}

- (void)showFilteredTable{
    [self showFilteredTableAnimated:YES];
}

- (void)showFilteredTableAnimated:(BOOL)animated{
    [self.view layoutIfNeeded];
    self.categorizedViewLeadingConstraint.constant = - [UIScreen mainScreen].bounds.size.width;
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    } else {
        [self.view layoutIfNeeded];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ((tableView == self.resultsTableView && indexPath.section == 2) || (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeUsers)) {
        static NSString *cellID = @"MFFollowingTableCell";

        MFFollowingTableCell *cell = (MFFollowingTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];

        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MFFollowingTableCell" owner:nil options:nil] lastObject];
        }

        cell.cellDelegate = self;
        [cell setSearchResult:self.usersResults[indexPath.row]];
        if (indexPath.row == self.usersResults.count - 1) {
            cell.separatorView.hidden = YES;
        } else {
            cell.separatorView.hidden = NO;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    } else if ((tableView == self.resultsTableView && indexPath.section == 1) || (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeArtists)) {
        static NSString *cellID = @"MFFollowingTableCell";
        
        MFFollowingTableCell *cell = (MFFollowingTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MFFollowingTableCell" owner:nil options:nil] lastObject];
        }
        
        cell.cellDelegate = self;
        [cell setSearchResult:self.artistsResults[indexPath.row]];
        if (indexPath.row == self.artistsResults.count - 1) {
            cell.separatorView.hidden = YES;
        } else {
            cell.separatorView.hidden = NO;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    } else if ((tableView == self.resultsTableView && indexPath.section == 0) || (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeTracks)){
        static NSString *cellID = @"PlaylistTrackCell";
        
        PlaylistTrackCell *cell = (PlaylistTrackCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PlaylistTrackCell" owner:nil options:nil] lastObject];
            
        }
        [cell setIsDefaultTrack:NO];
        [cell setIsMyMusic:NO];
        cell.playlistTrackCellDelegate = self;
        cell.undoRemoveView.hidden = YES;
        MFTrackItem* track = self.trackResults[indexPath.row];
        
        [cell setTrack:track];
        [cell checkIsPostedState];
        if (indexPath.row == 0) {
            cell.separatorView.hidden = YES;
        } else {
            cell.separatorView.hidden = NO;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    } else if (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeSuggestions){
        MFSuggestionTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MFSuggestionTableViewCell"];
        [cell setSuggestion:_suggestions[indexPath.row]];
        cell.delegate = self;
        return cell;
    } else if (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeRecentSearches){
        MFRecentSearchTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MFRecentSearchTableViewCell"];
        cell.label.text = [self recentSearches][indexPath.row];
        return cell;
    } else if (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeFilterCategories){
        MFSuggestionsFilterTypeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MFSuggestionsFilterTypeTableViewCell"];
        cell.label.text = [self suggestionsCategories][indexPath.row][0];
        if (_selectedFilterIndex == indexPath.row) {
            cell.label.textColor = [UIColor colorWithRGBHex:0x007AFF];
            cell.mark.hidden = NO;
        } else {
            cell.label.textColor = [UIColor blackColor];
            cell.mark.hidden = YES;
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((tableView == self.resultsTableView && indexPath.section == 2) || (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeUsers)) {
        IRSuggestion* suggestion = self.usersResults[indexPath.row];
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
        userInfo.username = suggestion.username;
        userInfo.name = suggestion.name;
        userInfo.profileImage = [suggestion.avatar_url stringByReplacingOccurrencesOfString:@" " withString:@""];
        userInfo.facebookID = suggestion.facebook_id;
        userInfo.extId = suggestion.ext_id;
        [self showUserProfileWithUserInfo:userInfo];
    } else if ((tableView == self.resultsTableView && indexPath.section == 1) || (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeArtists)) {
        IRSuggestion* suggestion = self.artistsResults[indexPath.row];
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
        userInfo.username = suggestion.username;
        userInfo.name = suggestion.name;
        userInfo.profileImage = [suggestion.avatar_url stringByReplacingOccurrencesOfString:@" " withString:@""];
        userInfo.facebookID = suggestion.facebook_id;
        userInfo.extId = suggestion.ext_id;
        [self showUserProfileWithUserInfo:userInfo];
    } else if ((tableView == self.resultsTableView && indexPath.section == 0) || (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeTracks)){
        if (indexPath.row < self.trackResults.count) {
            MFTrackItem* track = self.trackResults[indexPath.row];
            [self shouldOpenTrackInfo:track];
        }
    } else if (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeSuggestions){
        MFSuggestion* suggestion = _suggestions[indexPath.row];
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
        userInfo.username = suggestion.username;
        userInfo.name = suggestion.name;
        userInfo.profileImage = [suggestion.avatar_url stringByReplacingOccurrencesOfString:@" " withString:@""];
        userInfo.facebookID = suggestion.facebook_id;
        userInfo.extId = suggestion.ext_id;
        [self showUserProfileWithUserInfo:userInfo];
    } else if (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeRecentSearches){
        MFRecentSearchTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        self.searchField.text = cell.label.text;
        [self textFieldEditingChanged:self.searchField];
    } else if (tableView == self.filteredTableView && self.type == NewSearchViewControllerFilteredTypeFilterCategories){
        if (indexPath.row == _selectedFilterIndex) {
            [self hideFilterTable];
        } else {
            _selectedFilterIndex = indexPath.row;
            self.filteredLabel.text = _suggestionsCategories[indexPath.row][0];
            [self applyFilteringWith:_suggestionsCategories[indexPath.row][1]];
        }
    }

}

- (void)hideFilterTable{
    if (self.type == NewSearchViewControllerFilteredTypeFilterCategories) {
        self.type = NewSearchViewControllerFilteredTypeSuggestions;
        [self.filteredTableView reloadData];
        self.filteredTableView.backgroundColor = [UIColor colorWithRGBHex:0xE5E5E5];
    }
}

- (void)applyFilteringWith:(NSString*)string{
    self.filteredTableView.hidden = YES;
    [self.activityIndicator startAnimating];
    [[IRNetworkClient sharedInstance]
     getSuggestionsFilteredWithEmail:userManager.userInfo.email
     token:[userManager fbToken]
     filterType:string
     successBlock:^(NSDictionary *suggestionArray) {
         NSArray* rawSuggestions = suggestionArray[@"artists"];
         _suggestions = [dataManager processSuggestions: rawSuggestions];

         userManager.userInfo.suggestions = [NSOrderedSet orderedSetWithArray:_suggestions];

         [self hideTopErrorViewWithMessage:self.kConnectedMessage];

         [self hideFilterTable];
         self.filteredTableView.hidden = NO;
         [self.activityIndicator stopAnimating];

     } failureBlock:^(NSString *errorMessage) {
         self.filteredTableView.hidden = NO;
         [self.activityIndicator stopAnimating];
         [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

     }];
}

- (void)didTouchThumb:(MFTrackItem *)track{
    [self.container setPlayerViewHidden:NO];
    
    UIEdgeInsets insets = self.resultsTableView.contentInset;
    insets.bottom = PLAYER_VIEW_HEIGHT;
    self.resultsTableView.contentInset = insets;
    
    UIEdgeInsets insets2 = self.filteredTableView.contentInset;
    insets2.bottom = PLAYER_VIEW_HEIGHT;
    self.filteredTableView.contentInset = insets2;
    
    NSUInteger index = [self.trackResults indexOfObject:track];
    if (![playerManager.currentTrack isEqual:self.trackResults[index]]) {
        //[playerManager playSingleTrack:self.trackResults[index]];
        [playerManager playPlaylist:self.trackResults fromIndex:(int)index];
        playerManager.currentSourceName = NSLocalizedString(@"Search results", nil);
    }
    else if ([playerManager playing]) {
        [playerManager pauseTrack];
    }
    else {
        [playerManager resumeTrack];
    }
}

- (void)shouldShowTrackInfo:(MFTrackItem *)track{
    self.trackItem = track;
    [self showSharing];
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self.searchField resignFirstResponder];
//}

- (IBAction)searchFieldDidEnd:(id)sender {
    [self.searchField resignFirstResponder];
}
- (IBAction)darkViewTapped:(id)sender {
    [self.searchField resignFirstResponder];

}

- (void)didSelectFollow:(MFFollowingTableCell *)cell{
    IRSuggestion* suggestion = cell.suggestion;
//    NSIndexPath* indexPath = [self.resultsTableView indexPathForCell:cell];
    suggestion.is_followed = !suggestion.is_followed;
    NSDictionary *proposalsDictionary = @{@"ext_id" : suggestion.ext_id,
                                          @"followed" : suggestion.is_followed ? @"true" : @"false"};
    
    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
    userInfo.username = suggestion.username;
    userInfo.profileImage = [suggestion.avatar_url stringByReplacingOccurrencesOfString:@" " withString:@""];
    userInfo.facebookID = suggestion.facebook_id;
    userInfo.extId = suggestion.ext_id;

    
    [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                      token:[userManager fbToken]
                                                  proposals:@[proposalsDictionary]
                                               successBlock:^{
                                                   [MFNotificationManager postUpdateUserFollowingNotification:userInfo];
                                               }
                                               failureBlock:^(NSString *errorMessage){
                                                   [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                               }];

//    [self.resultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didAddTrackToPlaylist:(MFTrackItem *)track
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlaylistsViewController *playlistsVC = [storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
    playlistsVC.container = self.container;
    playlistsVC.trackToAdd = track;
    
    [self.navControllerToPush pushViewController:playlistsVC animated:YES];
}

- (void)didRepostTrack:(MFTrackItem *)track{
    [[IRNetworkClient sharedInstance] publishTrackByID:track.itemId SuccessBlock:^(NSDictionary *dictionary) {
        [[MFMessageManager sharedInstance] showTrackRepostedMessageInViewController:self.tabBarController];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

- (IBAction)backToCategorizedButtonTapped:(id)sender {
    [self.view layoutSubviews];
    self.categorizedViewLeadingConstraint.constant = 0.0;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

-(void)suggestionRequest
{
    [[IRNetworkClient sharedInstance] getSuggestionsCategoriesWithSuccessBlock:^(NSArray* array) {

        NSMutableArray* newArray = [NSMutableArray array];
        [newArray addObject:@[@"All Suggestions", @""]];
        for (NSDictionary* dict in array) {
            [newArray addObject:@[dict[@"title"], dict[@"key"]]];
        }
        self.suggestionsCategories = [newArray copy];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];

    BOOL anonymousRequest = !userManager.isLoggedIn;

    [[IRNetworkClient sharedInstance]
     getSuggestionsFilteredWithEmail:userManager.userInfo.email
                        token:[userManager fbToken]
                    filterType:nil
                    successBlock:^(NSDictionary *suggestionArray) {
                        NSArray* rawSuggestions = suggestionArray[@"artists"];

                        NSArray* suggestions = [dataManager processSuggestions:rawSuggestions];

                        _suggestions = suggestions;

                        _trendingArtists = [dataManager convertAndAddSuggestionItemsToDatabase: suggestionArray[@"trending_artists"]];

                        _suggestionTracks = [dataManager convertAndAddTracksToDatabase:suggestionArray[@"trending_tracks"]];
                        if (userManager.isLoggedIn && !anonymousRequest) {
                            userManager.userInfo.suggestions = [NSOrderedSet orderedSetWithArray:suggestions];
                            userManager.userInfo.trendingArtists = [NSOrderedSet orderedSetWithArray:_trendingArtists];
                            userManager.userInfo.trendingTracks = [NSOrderedSet orderedSetWithArray:_suggestionTracks];
                        } else if (!userManager.isLoggedIn && anonymousRequest){
                            [dataManager getAnonUserInfo].suggestions = [NSOrderedSet orderedSetWithArray:suggestions];
                            [dataManager getAnonUserInfo].trendingArtists = [NSOrderedSet orderedSetWithArray:_trendingArtists];
                            [dataManager getAnonUserInfo].trendingTracks = [NSOrderedSet orderedSetWithArray:_suggestionTracks];
                        }
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
                        [self.suggestionsCollectionView reloadData];
                        [self.suggestionsTracksCollectionView reloadData];
                        if (self.type == NewSearchViewControllerFilteredTypeSuggestions) {
                            [self.filteredTableView reloadData];
                        }
                        [self hideTopErrorViewWithMessage:self.kConnectedMessage];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

- (void) suggestionsLoaded{
    [self setCachedData];
    [self.suggestionsCollectionView reloadData];
    [self.suggestionsTracksCollectionView reloadData];
    if (self.type == NewSearchViewControllerFilteredTypeSuggestions) {
        [self.filteredTableView reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == _suggestionsCollectionView) {
        if (_trendingArtists.count<4) {
            return _trendingArtists.count;
        } else {
            return 4;
        }
    } else {
        if (_suggestionTracks.count<4) {
            return _suggestionTracks.count;
        } else {
            return 4;
        }

    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _suggestionsCollectionView) {
        MFSuggestionSmallCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MFSuggestionSmallCollectionViewCell" forIndexPath:indexPath];
        MFSuggestion* suggestion = _trendingArtists[indexPath.row];
        
        cell.nameLabel.text = suggestion.name;
        [cell.avatarImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:suggestion.avatar_url]];
        return cell;
    } else {
        MFSuggestionTrackCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MFSuggestionTrackCollectionViewCell" forIndexPath:indexPath];
        MFTrackItem* track = _suggestionTracks[indexPath.row];
        
        cell.trackNameLabel.text = track.trackName;
        [cell.trackImage sd_setImageAndFadeOutWithURL:[NSURL URLWithString:track.trackPicture] placeholderImage:[UIImage imageNamed:@"DefaultArtwork"]];
        cell.track = track;
        return cell;

    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _suggestionsCollectionView) {
        MFSuggestion* suggestion = _trendingArtists[indexPath.row];
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
        userInfo.username = suggestion.username;
        userInfo.name = suggestion.name;
        userInfo.profileImage = [suggestion.avatar_url stringByReplacingOccurrencesOfString:@" " withString:@""];
        userInfo.facebookID = suggestion.facebook_id;
        userInfo.extId = suggestion.ext_id;
        [self showUserProfileWithUserInfo:userInfo];
    } else if (collectionView == _suggestionsTracksCollectionView){
        
        MFTrackItem* track = self.suggestionTracks[indexPath.row];
        if (![playerManager.currentTrack isEqual:track]) {
            [playerManager playPlaylist:self.suggestionTracks fromIndex:(int)indexPath.row];
            playerManager.currentSourceName = NSLocalizedString(@"Trending Tracks", nil);
        }
        else if ([playerManager playing]) {
            [playerManager pauseTrack];
        }
        else {
            [playerManager resumeTrack];
        }
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (NSArray*)recentSearches{
    NSArray* recentSearches;
    if (userManager.isLoggedIn) {
        recentSearches = userManager.userInfo.recentSearches;
    } else {
        recentSearches = [dataManager getAnonUserInfo].recentSearches;
    }
    if (!recentSearches) {
        recentSearches = [NSArray array];
    }
    return [recentSearches copy];
}

- (void)didSearchWithKeyword:(NSString*)keyword{
    [self.savingKeywordTimer invalidate];
    self.savingKeywordTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(saveSearch:) userInfo:@{@"keyword": keyword} repeats:NO];
}

- (void)saveSearch:(NSTimer*)timer{
    NSString* keyword = timer.userInfo[@"keyword"];
    NSMutableArray* recentSearches = [[self recentSearches] mutableCopy];

    if ([recentSearches containsObject:keyword]) {
        [recentSearches removeObject:keyword];
    }
    [recentSearches insertObject:keyword atIndex:0];
    if (recentSearches.count>5) {
        [recentSearches removeLastObject];
    }

    if (userManager.isLoggedIn) {
        userManager.userInfo.recentSearches = recentSearches;
    } else {
        [dataManager getAnonUserInfo].recentSearches = recentSearches;
    }
    
}

- (IBAction)filterButtonTapped:(id)sender {
    if (self.type == NewSearchViewControllerFilteredTypeFilterCategories){
        [self hideFilterTable];
    } else if (self.type == NewSearchViewControllerFilteredTypeSuggestions){
        self.type = NewSearchViewControllerFilteredTypeFilterCategories;
        [self.filteredTableView reloadData];
        if (_suggestionsCategories.count) {
            [self.filteredTableView  scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];

        }
        self.filteredTableView.backgroundColor = [UIColor whiteColor];
    }
}

- (void) showTutorialOverlay{
    self.instructionalOverlay = [[[NSBundle mainBundle] loadNibNamed:@"MFDirectLinkOverlay" owner:nil options:nil] firstObject];
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

- (BOOL)textFieldShouldClear:(UITextField *)textField{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.searchField resignFirstResponder];
//    });

    return YES;
}

- (void)didLikeTrack:(MFTrackItem *)track
{
    __block MFTrackItem *trackItem = track;
    [[IRNetworkClient sharedInstance] likeTrackById:track.itemId withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^{
        [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:trackItem
                                                             forKey:@"trackItem"];
        [[NSNotificationCenter defaultCenter] postNotificationName:PlaylistLikeNotificationEvent
                                                            object:self
                                                          userInfo:userInfo];
    } failureBlock:^(NSString *errorMessage) {
        trackItem.isLiked = NO;
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
        // TODO: handle error
    }];
}

- (void)didUnlikeTrack:(MFTrackItem *)track
{
    __block MFTrackItem *trackItem = track;
    [[IRNetworkClient sharedInstance] unlikeTrackById:track.itemId withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^{
        [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:trackItem
                                                             forKey:@"trackItem"];
        [[NSNotificationCenter defaultCenter] postNotificationName:PlaylistUnlikeNotificationEvent
                                                            object:self
                                                          userInfo:userInfo];
    } failureBlock:^(NSString *errorMessage) {
        trackItem.isLiked = YES;
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
        // TODO: handle error
    }];
}

- (void)suggestionTableViewCellDidSelectCommonFollowers:(MFSuggestionTableViewCell *)cell{
    MFFollowersViewController* followersVC = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"followersViewController"];
    followersVC.followers = [[cell.suggestion.commonFollowers array] mutableCopy];
    followersVC.isMyFollowItems = NO;
    followersVC.headerImage = cell.background.image;
    followersVC.shouldJustDisplayGivenFollowItems = YES;
    followersVC.numberOfTotalFollowers = (int)cell.suggestion.followersCount;
    [self.navigationController pushViewController:followersVC animated:YES];
}

- (void) suggestionTableViewCellDidSelectFollow:(MFSuggestionTableViewCell *)cell{
    MFSuggestion* suggestion = cell.suggestion;
    suggestion.is_followed = !suggestion.is_followed;
    NSDictionary *proposalsDictionary = @{@"ext_id" : suggestion.ext_id,
                                          @"followed" : suggestion.is_followed ? @"true" : @"false"};

    MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
    userInfo.username = suggestion.username;
    userInfo.profileImage = [suggestion.avatar_url stringByReplacingOccurrencesOfString:@" " withString:@""];
    userInfo.facebookID = suggestion.facebook_id;
    userInfo.extId = suggestion.ext_id;
    cell.followButton.hidden = suggestion.is_followed;

    MFUserInfo* myUserInfo;
    if (userManager.isLoggedIn) {
        myUserInfo = userManager.userInfo;
    } else {
        myUserInfo = dataManager.getAnonUserInfo;
    }
    if (suggestion.is_followed) {
        NSMutableOrderedSet* set = [myUserInfo.suggestions mutableCopy];
        if ([set containsObject:suggestion]) {
            [set removeObject:suggestion];
            myUserInfo.suggestions = [set copy];
            self.suggestions = [set array];
            NSIndexPath* ip = [self.filteredTableView indexPathForCell:cell];
            if (ip) {
                [self.filteredTableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }

    [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                      token:[userManager fbToken]
                                                  proposals:@[proposalsDictionary]
                                               successBlock:^{
                                                   [MFNotificationManager postUpdateUserFollowingNotification:userInfo];

                                               }
                                               failureBlock:^(NSString *errorMessage){
                                                   [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
                                                   suggestion.is_followed = !suggestion.is_followed;
                                                   cell.followButton.hidden = suggestion.is_followed;
                                               }];

}

- (void)didKeyboardShow:(NSNotification*)notification
{

    self.darkenView.hidden = NO;
    self.darkenView.userInteractionEnabled = YES;
    self.darkenView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.darkenView.alpha = 1.0;
    } completion:nil];


}

- (void)didKeyboardHide:(NSNotification*)notification
{

    self.darkenView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.darkenView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.darkenView.hidden = YES;
    }];

}

- (IBAction)statusBarTapped:(id)sender {
    [self.filteredTableView setContentOffset:(CGPoint){0.0, 0.0} animated:YES];
}

@end
