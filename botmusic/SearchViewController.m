//
//  SearchViewController.m
//  botmusic
//
//  Created by Supervisor on 17.08.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "SearchViewController.h"
#import <UIColor+Expanded.h>
#import "ResultsTableHeaderView.h"
#import "ResultsTableFooterView.h"
#import "UserResultsTableCell.h"
#import "TrackResultsTableCell.h"
#import "TrackInfoViewController.h"
#import "MFPlaylistItem+Behavior.h"
#import "PlaylistTracksViewController.h"
#import "PlaylistResultsTableCell.h"
#import "PlaylistTracksViewController.h"
#import "PlaylistsViewController.h"
#import "MFNotificationManager.h"
#import "MFSingleTrackViewController.h"

static NSUInteger const kItemsNumberInSection = 4;

@interface SearchViewController () <ResultsTableFooterDelegate, TrackResultsCellDelegate, TrackInfoPlayDelegate, UserResultsTableCellDelegate>

@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation SearchViewController

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
    [super viewDidLoad];
    
    [self setUI];
    
    NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateUserFollowing];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateFollowing:)
                                                 name:notificationName
                                               object:nil];
    
    NSString *notificationStatusBarTappedName = [MFNotificationManager nameForNotification:MFNotificationTypeStatusBarTapped];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didTapOnHeader:)
                                                 name:notificationStatusBarTappedName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willKeyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    playerManager.videoPlayer.currentViewController = self;
    
    if (!self.container.isPlayerViewHidden) {
        [self.resultsTableView setContentInset:UIEdgeInsetsMake(0, 0, PLAYER_VIEW_HEIGHT, 0)];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Touches

- (IBAction)didTouchUpAllButton:(id)sender
{
    self.selectedIndex = 0;
    [self deselectButtons];
    [self.allButton setTitleColor:[UIColor colorWithRGBHex:kBrandPinkColor] forState:UIControlStateNormal];
}

- (IBAction)didTouchUpTracksButton:(id)sender
{
    self.selectedIndex = 1;
    [self deselectButtons];
    [self.tracksButton setTitleColor:[UIColor colorWithRGBHex:kBrandPinkColor] forState:UIControlStateNormal];
}

- (IBAction)didTouchUpArtistsButton:(id)sender
{
    self.selectedIndex = 2;
    [self deselectButtons];
    [self.artistsButton setTitleColor:[UIColor colorWithRGBHex:kBrandPinkColor] forState:UIControlStateNormal];
}

- (IBAction)didTouchUpPeopleButton:(id)sender
{
    self.selectedIndex = 3;
    [self deselectButtons];
    [self.peopleButton setTitleColor:[UIColor colorWithRGBHex:kBrandPinkColor] forState:UIControlStateNormal];
}

- (IBAction)didTouchUpPlaylistsButton:(id)sender
{
    self.selectedIndex = 4;
    [self deselectButtons];
    [self.playlistsButton setTitleColor:[UIColor colorWithRGBHex:kBrandPinkColor] forState:UIControlStateNormal];
}

- (IBAction)didTouchUpSearchButton:(id)sender
{
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
    else {
        [self.textField becomeFirstResponder];
    }
}

- (IBAction)didTouchUpCloseButton:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    if ([self.textField.text isEqualToString:@""]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSString* keyword = @"";
        [self makeSearchRequestWithKeyword:keyword];
        self.textField.text = keyword;
    }
    
}

#pragma mark - TextField Actions

- (IBAction)didTextFieldBeginEditting:(id)sender
{
    
}

- (IBAction)didTextFieldChangeEditting:(id)sender
{
    NSString *keyword = self.textField.text;
    
    if (keyword == nil) {
        keyword = @"";
    }
    
    self.allTracksArray = @[];
    self.youtubeTracksArray = [@[] mutableCopy];
    self.soundcloudTracksArray = [@[] mutableCopy];
    self.otherTracksArray = [@[] mutableCopy];
    
    self.allArtistsArray = @[];
    self.allPeopleArray = @[];
    self.allPlaylistsArray = @[];
    
    self.tracksArray = @[];
    self.artistsArray = @[];
    self.peopleArray = @[];
    self.playlistsArray = @[];
    
    [self.resultsTableView reloadData];
    
    [self makeSearchRequestWithKeyword:keyword];
}

- (IBAction)didTextFieldSelectDone:(id)sender
{
    [_textField resignFirstResponder];
}

#pragma mark - Helpers

- (void)deselectButtons
{
    [self.allButton setTitleColor:[UIColor colorWithRGBHex:kFaintColor] forState:UIControlStateNormal];
    [self.tracksButton setTitleColor:[UIColor colorWithRGBHex:kFaintColor] forState:UIControlStateNormal];
    [self.artistsButton setTitleColor:[UIColor colorWithRGBHex:kFaintColor] forState:UIControlStateNormal];
    [self.peopleButton setTitleColor:[UIColor colorWithRGBHex:kFaintColor] forState:UIControlStateNormal];
    [self.playlistsButton setTitleColor:[UIColor colorWithRGBHex:kFaintColor] forState:UIControlStateNormal];
    
    [self setArrays];
    
    [self.resultsTableView reloadData];
}

- (void)setArrays
{
    if (self.selectedIndex == 0) {
        self.tracksArray = [self.allTracksArray subarrayWithRange:NSMakeRange(0, self.allTracksArray.count > kItemsNumberInSection ? kItemsNumberInSection : self.allTracksArray.count)];
        self.artistsArray = [self.allArtistsArray subarrayWithRange:NSMakeRange(0, self.allArtistsArray.count > kItemsNumberInSection ? kItemsNumberInSection : self.allArtistsArray.count)];
        self.peopleArray = [self.allPeopleArray subarrayWithRange:NSMakeRange(0, self.allPeopleArray.count > kItemsNumberInSection ? kItemsNumberInSection : self.allPeopleArray.count)];
        self.playlistsArray = [self.allPlaylistsArray subarrayWithRange:NSMakeRange(0, self.self.allPlaylistsArray.count > kItemsNumberInSection ? kItemsNumberInSection : self.self.allPlaylistsArray.count)];
    }
    else if (self.selectedIndex == 1) {
        self.tracksArray = self.allTracksArray;
        self.youtubeTracksArray = [[self.allYoutubeTracksArray subarrayWithRange:NSMakeRange(0, self.allYoutubeTracksArray.count > kItemsNumberInSection ? kItemsNumberInSection : self.allYoutubeTracksArray.count)] mutableCopy];
        self.soundcloudTracksArray = [[self.allSoundcloudTracksArray subarrayWithRange:NSMakeRange(0, self.allSoundcloudTracksArray.count > kItemsNumberInSection ? kItemsNumberInSection : self.allSoundcloudTracksArray.count)] mutableCopy];
        self.otherTracksArray = [[self.allOtherTracksArray subarrayWithRange:NSMakeRange(0, self.allOtherTracksArray.count > kItemsNumberInSection ? kItemsNumberInSection : self.allOtherTracksArray.count)] mutableCopy];
        
    }
    else if (self.selectedIndex == 2) {
        self.artistsArray = self.allArtistsArray;
    }
    else if (self.selectedIndex == 3) {
        self.peopleArray = self.allPeopleArray;
    }
    else if (self.selectedIndex == 4) {
        self.playlistsArray = self.allPlaylistsArray;
    }
    
    [self updateNoResultsView];
}

- (void)updateNoResultsView
{
    if (self.selectedIndex == 0) {
//        self.noResultsTextLabel.text = @"search for tracks to add, playlists to listen to, or people to follow";
        if (self.tracksArray.count == 0 && self.artistsArray.count == 0 && self.peopleArray.count == 0 && self.playlistsArray.count == 0) {
            self.noResultsView.hidden = NO;
        }
        else {
            self.noResultsView.hidden = YES;
        }
    }
    else if (self.selectedIndex == 1) {
//        self.noResultsTextLabel.text = @"search for tracks to add";
        self.noResultsView.hidden = !(self.tracksArray.count == 0);
    }
    else if (self.selectedIndex == 2) {
//        self.noResultsTextLabel.text = @"search for artists to follow";
        self.noResultsView.hidden = !(self.artistsArray.count == 0);
    }
    else if (self.selectedIndex == 3) {
//        self.noResultsTextLabel.text = @"search for people to follow";
        self.noResultsView.hidden = !(self.peopleArray.count == 0);
    }
    else if (self.selectedIndex == 4) {
//        self.noResultsTextLabel.text = @"search for playlists to listen to";
        self.noResultsView.hidden = !(self.playlistsArray.count == 0);
    }
}

- (void)setUI
{
    [self setButtons];
    
    [self.textField setTintColor:[UIColor colorWithRGBHex:kAppMainColor]];
    [self.textField becomeFirstResponder];
    
    UINib *followCellNib = [UINib nibWithNibName:@"SuggestionCell" bundle:nil];
    [self.resultsTableView registerNib:followCellNib forCellReuseIdentifier:@"SuggestionCell"];
    
    UINib *userCellNib = [UINib nibWithNibName:@"UserResultsTableCell" bundle:nil];
    [self.resultsTableView registerNib:userCellNib forCellReuseIdentifier:@"UserResultsTableCell"];
    
    UINib *trackCellNib = [UINib nibWithNibName:@"TrackResultsTableCell" bundle:nil];
    [self.resultsTableView registerNib:trackCellNib forCellReuseIdentifier:@"TrackResultsTableCell"];
    
    UINib *playlistCellNib = [UINib nibWithNibName:@"PlaylistResultsTableCell" bundle:nil];
    [self.resultsTableView registerNib:playlistCellNib forCellReuseIdentifier:@"PlaylistResultsTableCell"];
    
    self.resultsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)setButtons
{
    [self didTouchUpAllButton:nil];
}

- (void)makeSearchRequestWithKeyword:(NSString *)keyword
{
    [FBSDKAppEvents logEvent:FBSDKAppEventNameSearched parameters:@{FBSDKAppEventParameterNameSearchString : keyword}];
    userManager.lastSearchKeyword = keyword;
    [[IRNetworkClient sharedInstance] searchWithKeyword:keyword searchType:@"all" success:^(NSDictionary *dictionary) {
        NSMutableArray *tempTracks = [[dataManager convertAndAddTracksToDatabase:dictionary[@"timelines"]]mutableCopy];
        self.allTracksArray = tempTracks;
        self.allYoutubeTracksArray = [[NSMutableArray alloc] init];
        self.allSoundcloudTracksArray = [[NSMutableArray alloc] init];
        self.allOtherTracksArray = [[NSMutableArray alloc] init];
        for (MFTrackItem* item in tempTracks) {
            if ([item.type isEqualToString:@"youtube"]) {
                [self.allYoutubeTracksArray addObject:item];
            } else if ([item.type isEqualToString:@"soundcloud"]){
                [self.allSoundcloudTracksArray addObject:item];
            } else {
                [self.allOtherTracksArray addObject:item];
            }
        }
        //self.allTracksArray = [NSArray arrayWithArray:[DataConverter convertSuggestions:dictionary[@"timelines"]]];
        self.allArtistsArray = [NSArray arrayWithArray:[DataConverter convertSuggestions:dictionary[@"artists"]]];
        self.allPeopleArray = [NSArray arrayWithArray:[DataConverter convertSuggestions:dictionary[@"users"]]];
        
        NSMutableArray* tempPlaylists = [[dataManager convertAndAddPlaylistsToDatabase:dictionary[@"playlists"] ofUser:nil]mutableCopy];
        
        self.allPlaylistsArray = tempPlaylists;
        //self.allPlaylistsArray = [NSArray arrayWithArray:[DataConverter convertSuggestions:dictionary[@"playlists"]]];
        
        [self setArrays];
        
        [self.resultsTableView reloadData];
    } failure:^(NSString *errorMessage) {
        
    }];
}

#pragma mark - TableView Delegate & Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.selectedIndex == 1) {
        return 3;
    }
    if (self.selectedIndex == 0) {
        return 4;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.selectedIndex == 0) {
        if (section == 0) {
            return self.tracksArray.count;
        }
        else if (section == 1) {
            return self.artistsArray.count;
        }
        else if (section == 2) {
            return self.peopleArray.count;
        }
        else if (section == 3) {
            return self.playlistsArray.count;
        }
    }
    else if (self.selectedIndex == 1) {
        //return self.tracksArray.count;
        if (section == 0) {
            return self.youtubeTracksArray.count;
        }
        else if (section == 1) {
            return self.soundcloudTracksArray.count;
        }
        else if (section == 2) {
            return self.otherTracksArray.count;
        }
    }
    else if (self.selectedIndex == 2) {
        return self.artistsArray.count;
    }
    else if (self.selectedIndex == 3) {
        return self.peopleArray.count;
    }
    else if (self.selectedIndex == 4) {
        return self.playlistsArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.selectedIndex == 0) {
        if (section == 0) {
            if (self.tracksArray && self.tracksArray.count > 0) {
                return 30.0f;
            }
        }
        else if (section == 1) {
            if (self.artistsArray && self.artistsArray.count > 0) {
                return 30.0f;
            }
        }
        else if (section == 2) {
            if (self.peopleArray && self.peopleArray.count > 0) {
                return 30.0f;
            }
        }
        else if (section == 3) {
            if (self.playlistsArray && self.playlistsArray.count > 0) {
                return 30.0f;
            }
        }
    }
    else if (self.selectedIndex == 1) {
//        if (self.tracksArray && self.tracksArray.count > 0) {
//            return 30.0f;
//        }
        if (section == 0) {
            if (self.youtubeTracksArray && self.youtubeTracksArray.count > 0) {
                return 30.0f;
            }
        }
        else if (section == 1) {
            if (self.soundcloudTracksArray && self.soundcloudTracksArray.count > 0) {
                return 30.0f;
            }
        }
        else if (section == 2) {
            if (self.otherTracksArray && self.otherTracksArray.count > 0) {
                return 30.0f;
            }
        }
        
    }
    else if (self.selectedIndex == 2) {
        if (self.artistsArray && self.artistsArray.count > 0) {
            return 30.0f;
        }
    }
    else if (self.selectedIndex == 3) {
        if (self.peopleArray && self.peopleArray.count > 0) {
            return 30.0f;
        }
    }
    else if (self.selectedIndex == 4) {
        if (self.playlistsArray && self.playlistsArray.count > 0) {
            return 30.0f;
        }
    }
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.selectedIndex == 0) {
        if (section == 0) {
            if (self.allTracksArray && self.allTracksArray.count > kItemsNumberInSection && self.tracksArray.count <= kItemsNumberInSection) {
                return 30.0f;
            }
        }
        else if (section == 1) {
            if (self.allArtistsArray && self.allArtistsArray.count > kItemsNumberInSection && self.artistsArray.count <= kItemsNumberInSection) {
                return 30.0f;
            }
        }
        else if (section == 2) {
            if (self.allPeopleArray && self.allPeopleArray.count > kItemsNumberInSection && self.peopleArray.count <= kItemsNumberInSection) {
                return 30.0f;
            }
        }
        else if (section == 3) {
            if (self.allPlaylistsArray && self.allPlaylistsArray.count > kItemsNumberInSection && self.playlistsArray.count <= kItemsNumberInSection) {
                return 30.0f;
            }
        }
    } else if (self.selectedIndex == 1) {
        if (section == 0) {
            if (self.allYoutubeTracksArray && self.allYoutubeTracksArray.count > kItemsNumberInSection && self.youtubeTracksArray.count <= kItemsNumberInSection) {
                return 30.0f;
            }
        }
        else if (section == 1) {
            if (self.allSoundcloudTracksArray && self.allSoundcloudTracksArray.count > kItemsNumberInSection && self.soundcloudTracksArray.count <= kItemsNumberInSection) {
                return 30.0f;
            }
        }
        else if (section == 2) {
            if (self.allOtherTracksArray && self.allOtherTracksArray.count > kItemsNumberInSection && self.otherTracksArray.count <= kItemsNumberInSection) {
                return 30.0f;
            }
        }
    }
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ResultsTableHeaderView *headerView = [ResultsTableHeaderView createResultsTableHeaderView];
    
    if (self.selectedIndex == 0) {
        if (section == 0) {
            if (self.tracksArray && self.tracksArray.count > 0) {
                [headerView.titleLabel setText:NSLocalizedString(@"tracks",nil)];
            }
            else {
                return [[UIView alloc] initWithFrame:CGRectZero];
            }
        }
        else if (section == 1) {
            if (self.artistsArray && self.artistsArray.count > 0) {
                [headerView.titleLabel setText:NSLocalizedString(@"artists",nil)];
            }
            else {
                return [[UIView alloc] initWithFrame:CGRectZero];
            }
        }
        else if (section == 2) {
            if (self.peopleArray && self.peopleArray.count > 0) {
                [headerView.titleLabel setText:NSLocalizedString(@"people",nil)];
            }
            else {
                return [[UIView alloc] initWithFrame:CGRectZero];
            }
        }
        else if (section == 3) {
            if (self.playlistsArray && self.playlistsArray.count > 0) {
                [headerView.titleLabel setText:NSLocalizedString(@"playlists",nil)];
            }
            else {
                return [[UIView alloc] initWithFrame:CGRectZero];
            }
        }
    }
    else if (self.selectedIndex == 1) {
//        if (self.tracksArray && self.tracksArray.count > 0) {
//            [headerView.titleLabel setText:NSLocalizedString(@"tracks",nil)];
//        }
//        else {
//            return [[UIView alloc] initWithFrame:CGRectZero];
//        }
        if (section == 0) {
            if (self.youtubeTracksArray && self.youtubeTracksArray.count > 0) {
                [headerView.titleLabel setText:NSLocalizedString(@"youtube",nil)];
            }
            else {
                return [[UIView alloc] initWithFrame:CGRectZero];
            }
        }
        else if (section == 1) {
            if (self.soundcloudTracksArray && self.soundcloudTracksArray.count > 0) {
                [headerView.titleLabel setText:NSLocalizedString(@"soundcloud",nil)];
            }
            else {
                return [[UIView alloc] initWithFrame:CGRectZero];
            }
        }
        else if (section == 2) {
            if (self.otherTracksArray && self.otherTracksArray.count > 0) {
                [headerView.titleLabel setText:NSLocalizedString(@"other",nil)];
            }
            else {
                return [[UIView alloc] initWithFrame:CGRectZero];
            }
        }
        
    }
    else if (self.selectedIndex == 2) {
        if (self.artistsArray && self.artistsArray.count > 0) {
            [headerView.titleLabel setText:NSLocalizedString(@"artists",nil)];
        }
        else {
            return [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    else if (self.selectedIndex == 3) {
        if (self.peopleArray && self.peopleArray.count > 0) {
            [headerView.titleLabel setText:NSLocalizedString(@"people",nil)];
        }
        else {
            return [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    else if (self.selectedIndex == 4) {
        if (self.playlistsArray && self.playlistsArray.count > 0) {
            [headerView.titleLabel setText:NSLocalizedString(@"playlists",nil)];
        }
        else {
            return [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    ResultsTableFooterView *footerView = [ResultsTableFooterView createResultsTableFooterView];
    footerView.section = section;
    footerView.delegate = self;
    
    if (self.selectedIndex == 0) {
        if (section == 0) {
            [footerView.moreTracksButton setTitle:NSLocalizedString(@"more tracks",nil) forState:UIControlStateNormal];
        }
        else if (section == 1) {
            [footerView.moreTracksButton setTitle:NSLocalizedString(@"more artists",nil) forState:UIControlStateNormal];
        }
        else if (section == 2) {
            [footerView.moreTracksButton setTitle:NSLocalizedString(@"more people",nil) forState:UIControlStateNormal];
        }
        else if (section == 3) {
            [footerView.moreTracksButton setTitle:NSLocalizedString(@"more playlists",nil) forState:UIControlStateNormal];
        }
    } else if (self.selectedIndex == 1) {
        if (section == 0) {
            [footerView.moreTracksButton setTitle:NSLocalizedString(@"more youtube tracks",nil) forState:UIControlStateNormal];
        }
        else if (section == 1) {
            [footerView.moreTracksButton setTitle:NSLocalizedString(@"more soundcloud tracks",nil) forState:UIControlStateNormal];
        }
        else if (section == 2) {
            [footerView.moreTracksButton setTitle:NSLocalizedString(@"more other tracks",nil) forState:UIControlStateNormal];
        }
        
    }
    
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"SuggestionCell";
    
    SuggestionCell *cell = (SuggestionCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SuggestionCell" owner:nil options:nil] lastObject];
    }
    
    if (self.selectedIndex == 0) {
        if (indexPath.section == 0) {
            static NSString *cellID = @"TrackResultsTableCell";
            TrackResultsTableCell *trackCell = (TrackResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (trackCell == nil) {
                trackCell = [[[NSBundle mainBundle] loadNibNamed:@"TrackResultsTableCell" owner:nil options:nil] lastObject];
            }
            
            if (self.tracksArray && self.tracksArray.count > 0) {
                MFTrackItem *track = self.tracksArray[indexPath.row];
                [trackCell setInfo:track];
                trackCell.trackResultsCellDelegate = self;
            }
            
            return trackCell;
        }
        if (indexPath.section == 1) {
            static NSString *cellID = @"UserResultsTableCell";
            UserResultsTableCell *userCell = (UserResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (userCell == nil) {
                userCell = [[[NSBundle mainBundle] loadNibNamed:@"UserResultsTableCell" owner:nil options:nil] lastObject];
            }
            
            userCell.delegate = self;
            userCell.isArtist = YES;
            
            if (self.artistsArray && self.artistsArray.count > 0) {
                IRSuggestion *suggestion = self.artistsArray[indexPath.row];
                [userCell setInfo:suggestion];
            }
            
            return userCell;
        }
        else if (indexPath.section == 2) {
            static NSString *cellID = @"UserResultsTableCell";
            UserResultsTableCell *userCell = (UserResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (userCell == nil) {
                userCell = [[[NSBundle mainBundle] loadNibNamed:@"UserResultsTableCell" owner:nil options:nil] lastObject];
            }
            
            userCell.delegate = self;
            userCell.isArtist = NO;
            
            if (self.peopleArray && self.peopleArray.count > 0) {
                IRSuggestion *suggestion = self.peopleArray[indexPath.row];
                [userCell setInfo:suggestion];
            }
            
            return userCell;
        }
        else if (indexPath.section == 3) {
            static NSString *cellID = @"PlaylistResultsTableCell";
            PlaylistResultsTableCell *playlistCell = (PlaylistResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (playlistCell == nil) {
                playlistCell = [[[NSBundle mainBundle] loadNibNamed:@"PlaylistResultsTableCell" owner:nil options:nil] lastObject];
            }
            
            if (self.playlistsArray && self.playlistsArray.count > 0) {
                MFPlaylistItem *playlist = self.playlistsArray[indexPath.row];
                [playlistCell setInfo:playlist];
            }
            
            return playlistCell;
        }
    }
    else if (self.selectedIndex == 1) {
        if (indexPath.section == 0) {
            static NSString *cellID = @"TrackResultsTableCell";
            TrackResultsTableCell *trackCell = (TrackResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (trackCell == nil) {
                trackCell = [[[NSBundle mainBundle] loadNibNamed:@"TrackResultsTableCell" owner:nil options:nil] lastObject];
            }
            
            if (self.youtubeTracksArray && self.youtubeTracksArray.count > 0) {
                MFTrackItem *track = self.youtubeTracksArray[indexPath.row];
                [trackCell setInfo:track];
                trackCell.trackResultsCellDelegate = self;
            }
            
            return trackCell;
        } else if (indexPath.section == 1){
            static NSString *cellID = @"TrackResultsTableCell";
            TrackResultsTableCell *trackCell = (TrackResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (trackCell == nil) {
                trackCell = [[[NSBundle mainBundle] loadNibNamed:@"TrackResultsTableCell" owner:nil options:nil] lastObject];
            }
            
            if (self.soundcloudTracksArray && self.soundcloudTracksArray.count > 0) {
                MFTrackItem *track = self.soundcloudTracksArray[indexPath.row];
                [trackCell setInfo:track];
                trackCell.trackResultsCellDelegate = self;
            }
            
            return trackCell;
        } else if (indexPath.section == 2){
            static NSString *cellID = @"TrackResultsTableCell";
            TrackResultsTableCell *trackCell = (TrackResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (trackCell == nil) {
                trackCell = [[[NSBundle mainBundle] loadNibNamed:@"TrackResultsTableCell" owner:nil options:nil] lastObject];
            }
            
            if (self.otherTracksArray && self.otherTracksArray.count > 0) {
                MFTrackItem *track = self.otherTracksArray[indexPath.row];
                [trackCell setInfo:track];
                trackCell.trackResultsCellDelegate = self;
            }
            
            return trackCell;
        }
        
        
    }
    else if (self.selectedIndex == 2) {
        static NSString *cellID = @"UserResultsTableCell";
        UserResultsTableCell *userCell = (UserResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (userCell == nil) {
            userCell = [[[NSBundle mainBundle] loadNibNamed:@"UserResultsTableCell" owner:nil options:nil] lastObject];
        }
        
        userCell.delegate = self;
        userCell.isArtist = YES;
        
        if (self.artistsArray && self.artistsArray.count > 0) {
            IRSuggestion *suggestion = self.artistsArray[indexPath.row];
            [userCell setInfo:suggestion];
        }
        
        return userCell;
    }
    else if (self.selectedIndex == 3) {
        static NSString *cellID = @"UserResultsTableCell";
        UserResultsTableCell *userCell = (UserResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (userCell == nil) {
            userCell = [[[NSBundle mainBundle] loadNibNamed:@"UserResultsTableCell" owner:nil options:nil] lastObject];
        }
        
        userCell.delegate = self;
        userCell.isArtist = NO;
        
        if (self.peopleArray && self.peopleArray.count > 0) {
            IRSuggestion *suggestion = self.peopleArray[indexPath.row];
            [userCell setInfo:suggestion];
        }
        
        return userCell;
    }
    else if (self.selectedIndex == 4) {
        static NSString *cellID = @"PlaylistResultsTableCell";
        PlaylistResultsTableCell *playlistCell = (PlaylistResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (playlistCell == nil) {
            playlistCell = [[[NSBundle mainBundle] loadNibNamed:@"PlaylistResultsTableCell" owner:nil options:nil] lastObject];
        }
        
        if (self.playlistsArray && self.playlistsArray.count > 0) {
            MFPlaylistItem *playlist = self.playlistsArray[indexPath.row];
            [playlistCell setInfo:playlist];
        }
        
        return playlistCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IRSuggestion *suggestion;
    
    if (self.selectedIndex == 0) {
        if (indexPath.section == 0) {
            MFTrackItem *track = self.tracksArray[indexPath.row];
            MFSingleTrackViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
            trackInfoVC.track = track;
            trackInfoVC.container = self.container;
            
            [self.container.centerViewController pushViewController:trackInfoVC animated:YES];
        }
        else if (indexPath.section == 1) {
            suggestion = self.artistsArray[indexPath.row];
            MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
            userInfo.username = suggestion.username;
            userInfo.profileImage = suggestion.avatar_url;
            userInfo.facebookID = suggestion.facebook_id;
            userInfo.extId = suggestion.ext_id;
            userInfo.name = suggestion.name;
            [self showUserProfileWithUserInfo:userInfo];
        }
        else if (indexPath.section == 2) {
            suggestion = self.peopleArray[indexPath.row];
            MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
            userInfo.username = suggestion.username;
            userInfo.profileImage = suggestion.avatar_url;
            userInfo.facebookID = suggestion.facebook_id;
            userInfo.extId = suggestion.ext_id;
            userInfo.name = suggestion.name;
            [self showUserProfileWithUserInfo:userInfo];
        }
        else if (indexPath.section == 3) {
            MFPlaylistItem *playlist = self.playlistsArray[indexPath.row];
            PlaylistTracksViewController *playlistTracksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
            playlistTracksVC.container = self.container;
            playlistTracksVC.playlist = playlist;
            playlistTracksVC.isDefaultPlaylist = NO;
            
            [self.container.centerViewController pushViewController:playlistTracksVC animated:YES];
        }
    }
    else if (self.selectedIndex == 1) {
        MFTrackItem *track;
        if (indexPath.section == 0) {
            track = self.youtubeTracksArray[indexPath.row];
        } else if (indexPath.section == 1){
            track = self.soundcloudTracksArray[indexPath.row];
        } else if (indexPath.section == 2){
            track = self.otherTracksArray[indexPath.row];
        }
        MFSingleTrackViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
        trackInfoVC.track = track;
        trackInfoVC.container = self.container;
        
        [self.container.centerViewController pushViewController:trackInfoVC animated:YES];
    }
    else if (self.selectedIndex == 2) {
        suggestion = self.artistsArray[indexPath.row];
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
        userInfo.username = suggestion.username;
        userInfo.profileImage = suggestion.avatar_url;
        userInfo.facebookID = suggestion.facebook_id;
        userInfo.extId = suggestion.ext_id;
        userInfo.name = suggestion.name;
        [self showUserProfileWithUserInfo:userInfo];
    }
    else if (self.selectedIndex == 3) {
        suggestion = self.peopleArray[indexPath.row];
        MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
        userInfo.username = suggestion.username;
        userInfo.profileImage = suggestion.avatar_url;
        userInfo.facebookID = suggestion.facebook_id;
        userInfo.extId = suggestion.ext_id;
        userInfo.name = suggestion.name;
        [self showUserProfileWithUserInfo:userInfo];
    }
    else if (self.selectedIndex == 4) {
        MFPlaylistItem *playlist = self.playlistsArray[indexPath.row];
        PlaylistTracksViewController *playlistTracksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
        playlistTracksVC.container = self.container;
        playlistTracksVC.playlist = playlist;
        playlistTracksVC.isDefaultPlaylist = NO;
        
        [self.container.centerViewController pushViewController:playlistTracksVC animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ResultsTableFooter Delegate methods

- (void)didSelectMoreTracks:(NSUInteger)section
{
    if (self.selectedIndex == 0) {
        if (section == 0) {
            self.tracksArray = self.allTracksArray;
        }
        else if (section == 1) {
            self.artistsArray = self.allArtistsArray;
        }
        else if (section == 2) {
            self.peopleArray = self.allPeopleArray;
        }
        else if (section == 3) {
            self.playlistsArray = self.allPlaylistsArray;
        }
    }
    else if (self.selectedIndex == 1) {
        self.tracksArray = self.allTracksArray;
        if (section == 0) {
            self.youtubeTracksArray = self.allYoutubeTracksArray;
        }
        else if (section == 1) {
            self.soundcloudTracksArray = self.allSoundcloudTracksArray;
        }
        else if (section == 2) {
            self.otherTracksArray = self.allOtherTracksArray;
        }

    }
    else if (self.selectedIndex == 2) {
        self.artistsArray = self.allArtistsArray;
    }
    else if (self.selectedIndex == 3) {
        self.peopleArray = self.allPeopleArray;
    }
    else if (self.selectedIndex == 4) {
        self.playlistsArray = self.allPlaylistsArray;
    }

    [self.resultsTableView reloadData];
}

#pragma mark - TrackResultsCell Delegate methods

- (void)didLikeTrack:(MFTrackItem *)track
{
    __block MFTrackItem *trackItem = track;
    [[IRNetworkClient sharedInstance] likeTrackById:track.itemId withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^{
        
    } failureBlock:^(NSString *errorMessage) {
        //trackItem.isLiked = NO;
        // TODO: handle error
    }];
}

- (void)didUnlikeTrack:(MFTrackItem *)track
{
    __block MFTrackItem *trackItem = track;
    [[IRNetworkClient sharedInstance] unlikeTrackById:track.itemId withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^{
        
    } failureBlock:^(NSString *errorMessage) {
        //trackItem.isLiked = YES;
        // TODO: handle error
    }];
}

-(void)didAddTrackToPlaylist:(MFTrackItem *)track
{
    PlaylistsViewController *playlistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
    playlistsVC.container = self.container;
    playlistsVC.trackToAdd = track;
    
    [self.container.centerViewController pushViewController:playlistsVC animated:YES];
}

- (void)shouldShowComments:(MFTrackItem *)track
{
//    CommentsViewController *commentsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
//    [commentsVC setTrackItem:track];
//    //    [commentsVC setDelegate:self];
//    commentsVC.container = self.container;
//    
//    [self.container.centerViewController pushViewController:commentsVC animated:YES];
    
//    TrackInfoViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"trackInfoViewController"];
//    trackInfoVC.container = self.container;
//    trackInfoVC.trackItem = track;
//    //    trackInfoVC.playDelegate = self;
//    trackInfoVC.isCommentsView = YES;
//    
//    [self.container.centerViewController pushViewController:trackInfoVC animated:YES];
    
    MFSingleTrackViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = track;
    trackInfoVC.container = self.container;
    
    [self.container.centerViewController pushViewController:trackInfoVC animated:YES];
}

- (void)shouldShowTrackInfo:(MFTrackItem *)track
{
    MFSingleTrackViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = track;
    trackInfoVC.container = self.container;
    
    [self.container.centerViewController pushViewController:trackInfoVC animated:YES];
}

#pragma mark - TrackInfoPlayDelegate methods

- (void)didSelectPlay:(MFTrackItem *)trackItem
{
    [self.container setPlayerViewHidden:NO];
    [self.resultsTableView setContentInset:UIEdgeInsetsMake(0, 0, PLAYER_VIEW_HEIGHT, 0)];
    
    if (![playerManager.currentTrack isEqual:trackItem]) {
        [playerManager playSingleTrack:trackItem];
    }
    else if ([playerManager playing]) {
        [playerManager pauseTrack];
    }
    else {
        [playerManager resumeTrack];
    }
}

#pragma mark - UserResultsTableCellDelegate methods

- (void)didChangeFollowing:(IRSuggestion *)suggestion
{
    suggestion.is_followed = !suggestion.is_followed;
    NSDictionary *proposalsDictionary = @{@"ext_id" : suggestion.ext_id,
                                          @"followed" : suggestion.is_followed ? @"true" : @"false"};
    
    [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                      token:[userManager fbToken]
                                                  proposals:@[proposalsDictionary]
                                               successBlock:^{
                                                   MFUserInfo *userInfo = [dataManager getUserInfoInContextbyExtID:suggestion.ext_id];
                                                   userInfo.facebookID = suggestion.facebook_id;
                                                   userInfo.isFollowed = suggestion.is_followed;
                                                   [MFNotificationManager postUpdateUserFollowingNotification:userInfo];
                                               }
                                               failureBlock:^(NSString *errorMessage){}];
}

#pragma mark - Notification Center

- (void)didUpdateFollowing:(NSNotification *)notification
{
    MFUserInfo *userInfo = [notification.userInfo valueForKey:@"user_info"];
    
    NSMutableArray *artists = [_allArtistsArray mutableCopy];
    NSMutableArray *friends = [_allPeopleArray mutableCopy];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebook_id == %@", userInfo.facebookID];
    NSArray *filteredArtists = [artists filteredArrayUsingPredicate:predicate];
    NSArray *filteredFriends = [friends filteredArrayUsingPredicate:predicate];
    
    if (filteredArtists.count > 0) {
        ((IRSuggestion *)filteredArtists[0]).is_followed = userInfo.isFollowed;
        _allArtistsArray = artists;
    }
    else if (filteredFriends.count > 0) {
        ((IRSuggestion *)filteredFriends[0]).is_followed = userInfo.isFollowed;
        _allPeopleArray = friends;
    }
    
    [self.resultsTableView reloadData];
    
}

#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender
{
    if ([self.resultsTableView numberOfRowsInSection:0] > 0) {
        [self.resultsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Keyboard actions

- (void)willKeyboardShow:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect keyRect;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyRect];
    CGFloat height = keyRect.size.height;
    
    self.resultsTableViewBottomSpaceConstraint.constant = height;
    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)willKeyboardHide:(NSNotification*)notification
{
    self.resultsTableViewBottomSpaceConstraint.constant = 0;
    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
