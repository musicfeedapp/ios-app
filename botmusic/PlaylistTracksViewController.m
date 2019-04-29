//
//  PlaylistTracksViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/26/15.
//
//

#import "PlaylistTracksViewController.h"
#import <UIColor+Expanded.h>
#import "PlaylistsViewController.h"
#import "CommentsViewController.h"
#import "PlaylistTrackCell.h"
#import "MFPlaylistItem+Behavior.h"
#import "TrackInfoViewController.h"
#import "MFNotificationManager.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MFNewProfileViewController.h"
#import "MFNumberOfTracksTableViewCell.h"
#import "MFSingleTrackViewController.h"
#import "MFEditPlaylistViewController.h"
#import "UIImageView+WebCache_FadeIn.h"
#import <UIScrollView+SVInfiniteScrolling.h>

@interface PlaylistTracksViewController () <PlaylistTrackCellDelegate, TrackInfoPlayDelegate, PlaylistViewControllerTrackAdditionDelegate, MFEditPlaylistViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *tracks;

@property (nonatomic, weak) IBOutlet UITextField *editTextField;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *playlistNameLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerSeparatorHeightConstraint;
@property (strong, nonatomic) NSMutableArray* undoRemoveArray;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIImageView *ownerAvatar;

@end

@implementation PlaylistTracksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    self.undoRemoveArray = [NSMutableArray array];
    if (!_isDefaultPlaylist && [_userExtId isEqual:userManager.userInfo.extId]) {
        UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAtNameLabel:)];
        [self.playlistNameLabel addGestureRecognizer:nameTap];
    }
    if (_playlist.user == userManager.userInfo && [_playlist.itemId isEqualToString:@"likes"]) {
        NSString *notificationTypeUpdateLovedTracksPlaylist = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateLovedTracksPlaylist];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showTracks)
                                                     name:notificationTypeUpdateLovedTracksPlaylist
                                                   object:nil];
    }

    NSString *notificationStatusBarTappedName = [MFNotificationManager nameForNotification:MFNotificationTypeStatusBarTapped];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(didTapOnHeader:)
                                                 name:notificationStatusBarTappedName
                                               object:nil];
    self.tableViewBelowMessageBar = self.tracksTableView;
    if (self.playlist) {
        [self showTracks];
    }
    int topInset = 0;
    int botInset = 0;
    topInset = 64.0 + 20.0;
    botInset += self.tabBarController.tabBar.bounds.size.height;
    [self.tracksTableView setContentInset:UIEdgeInsetsMake(topInset, 0, botInset, 0)];
    //[self.tracksTableView setScrollIndicatorInsets:UIEdgeInsetsMake(topInset, 0, botInset, 0)];
    
    if (self.parentViewController && [self.parentViewController isKindOfClass:[MFNewProfileViewController class]]) {
        [self.tracksTableView setContentOffset:CGPointMake(0, -topInset)];
        [self scrollViewDidScroll:self.tracksTableView];
    }
    if (self.isUpNextPlaylist) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTracks) name:@"MFUpdateTrackHistory" object:nil];
    }
    if (!self.isUpNextPlaylist && !self.isHistoryPlaylist) {

        [self.tracksTableView addInfiniteScrollingWithActionHandler:^
         {
             [self nextPageTriggered];
         }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    if (self.parentViewController && [self.parentViewController isKindOfClass:[MFNewProfileViewController class]]) {
    } else {
        playerManager.videoPlayer.currentViewController = self;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSMutableArray* ids = [NSMutableArray array];
    for (MFTrackItem* track in self.undoRemoveArray) {
        [ids addObject:track.itemId];
        if(track && [self.tracks containsObject:track]){
            [self.tracks removeObject:track];
    
            NSInteger tracksCount = [self.playlist.tracksCount integerValue];
            self.playlist.tracksCount = @(--tracksCount);
    
            if ([self.playlist.itemId isEqualToString: @"default"]) {
                track.isFeedTrack = NO;

                MFUserInfo* userInfo;
                if (userManager.isLoggedIn) {
                    userInfo = userManager.userInfo;
                } else {
                    userInfo = dataManager.getAnonUserInfo;
                }
                [userInfo removeTracksObject:track];
            }
        }
        self.playlist.songs = [NSOrderedSet orderedSetWithArray:self.tracks];
        if (self.playlist.songs.count > 0) {
            self.playlist.playlistArtwork = ((MFTrackItem *)self.playlist.songs[0]).trackPicture;
        }
        else {
            self.playlist.playlistArtwork = nil;
        }
    }
    [self.tracksTableView reloadData];
    [self.undoRemoveArray removeAllObjects];
    if (ids.count>0) {
        [[IRNetworkClient sharedInstance] deleteSongsWithPlaylistId:self.playlist.itemId songsIds:ids email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
            
            //NSIndexPath *indexPath = [self indexPathForTrackWithId:track.itemId];
            [MFNotificationManager postUpdatePlaylistNotification:self.playlist];
            [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
            
        } failureBlock:^(NSString *errorMessage) {
            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
        }];
    }
}

#pragma mark - Properties

#pragma mark - Caching methods


#pragma mark - Helpers

- (void)updateTracks{
    [self showTracks];
    [self.tracksTableView reloadData];
}

- (void)showTracks
{
    NSMutableArray* a = [[NSMutableArray alloc] initWithArray:[self.playlist.songs array]];
    _tracks = a;
    if (!self.isUpNextPlaylist && !self.isHistoryPlaylist) {
        [self downloadDefaultTracksData];
    }
}

- (void)setUI
{
    if (!self.isMyMusic || [self.playlist.itemId isEqualToString:@"likes"] || [self.playlist.itemId isEqualToString:@"default"]) {
        self.editButton.hidden = YES;
    }
    if (self.shouldShowOwnerAvatar) {
        [self.ownerAvatar sd_setAvatarWithUrl:[NSURL URLWithString:self.playlist.user.profileImage] name:self.playlist.user.name];
    }
    self.headerSeparatorHeightConstraint.constant = 1.0/[UIScreen mainScreen].scale;
    [self setPlaylistNameLabelText:self.playlist.title];
    if (self.parentViewController && [self.parentViewController isKindOfClass:[MFNewProfileViewController class]]){
        self.headerViewHeightConstraint.constant = 0.0;
        self.headerView.hidden = YES;
    }

//    if (self.headerImage) {
//        [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    } else {
//        [self.backButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    }

    self.headerImageView.image = self.headerImage;
    UINib *playlistTrackCellNib = [UINib nibWithNibName:@"PlaylistTrackCell" bundle:nil];
    [self.tracksTableView registerNib:playlistTrackCellNib forCellReuseIdentifier:@"PlaylistTrackCell"];
    
    
}

- (void)setPlaylistNameLabelText:(NSString *)text
{
    self.playlistNameLabel.text = NSLocalizedString(text,nil);
    if (self.headerImage) {
        self.playlistNameLabel.textColor = [UIColor whiteColor];
    }
    //[self.playlistNameLabel sizeToFit];
    
    self.playlistNameLabelHeightConstraint.constant = self.playlistNameLabel.frame.size.height;
    self.headerViewHeightConstraint.constant = self.playlistNameLabel.frame.size.height + 10.f > 40.f ? self.playlistNameLabel.frame.size.height + 10.f : 40.f;
    if (self.parentViewController && [self.parentViewController isKindOfClass:[MFNewProfileViewController class]]) {
        self.headerViewHeightConstraint.constant = 0.0;
    }
    [self.view layoutIfNeeded];
}

- (void)downloadDefaultTracksData
{
    
    [[IRNetworkClient sharedInstance] getPlaylistsWithId:self.playlist.itemId extId:self.userExtId lastTimelineId:nil successBlock:^(NSDictionary *dictionary) {
        //ASYNC MR

        NSArray *tracks = [dataManager convertAndAddTracksToDatabase:dictionary[@"songs"]];
//        [dataManager convertAndAddTracksToDatabaseAsync:dictionary[@"songs"] playlist:self.playlist completion:^(NSArray *array) {
//            NSArray *tracks = array;
        self.playlist.title = dictionary[@"title"];
        //[[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

        [self setPlaylistNameLabelText:self.playlist.title];
        self.playlist.songs = [NSOrderedSet orderedSetWithArray:tracks];
        self.tracks = [[NSMutableArray alloc] initWithArray:[self.playlist.songs array]];

        if (_tracks.count > 0 && [_userExtId isEqual:userManager.userInfo.extId]) {
            [MFNotificationManager postUpdatePlaylistNotification:self.playlist];
        }
        
        [self.tracksTableView reloadData];
//        }];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];

}

- (void) nextPageTriggered{
    if (!self.tracks.count) {
        [self.tracksTableView.infiniteScrollingView stopAnimating];
        return;
    }
    NSString* lastTimelineID = ((MFTrackItem*)[self.tracks lastObject]).itemId;
    [[IRNetworkClient sharedInstance] getPlaylistsWithId:self.playlist.itemId extId:self.userExtId lastTimelineId:lastTimelineID successBlock:^(NSDictionary *dictionary) {

        NSArray *tracks = [dataManager convertAndAddTracksToDatabase:dictionary[@"songs"]];
        NSMutableOrderedSet * set = [NSMutableOrderedSet orderedSetWithArray:[self.tracks arrayByAddingObjectsFromArray:tracks]];
        self.tracks = [[NSMutableArray alloc] initWithArray:[set array]];
        [self.tracksTableView reloadData];
        [self.tracksTableView.infiniteScrollingView stopAnimating];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
        [self.tracksTableView.infiniteScrollingView stopAnimating];

    }];
}

- (NSIndexPath *)indexPathForTrackWithId:(NSString *)trackId
{
    for (int i = 0; i < self.tracks.count; i++) {
        MFTrackItem *trackItem = self.tracks[i];
        if ([trackId isEqual:trackItem.itemId]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

#pragma mark - TableView Delegate & Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tracks.count==0) {
        return 0;
    }
    return self.tracks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==self.tracks.count) {
        MFNumberOfTracksTableViewCell *numberCell = (MFNumberOfTracksTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MFNumberOfTracksTableViewCell"];
        if (numberCell == nil) {
            numberCell = [[[NSBundle mainBundle] loadNibNamed:@"MFNumberOfTracksTableViewCell" owner:nil options:nil] lastObject];
        }
        numberCell.numberLabel.text = [NSString stringWithFormat:@"%lu tracks", self.tracks.count];
        numberCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return numberCell;
    } else {
        static NSString *cellID = @"PlaylistTrackCell";
        
        PlaylistTrackCell *cell = (PlaylistTrackCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PlaylistTrackCell" owner:nil options:nil] lastObject];
        }
        cell.playlistTrackCellDelegate = self;
        [cell setIsDefaultTrack:_isDefaultPlaylist];
        cell.isFromLovedTracks = [self.playlist.itemId isEqualToString:@"likes"];
        [cell setIsMyMusic:self.isMyMusic];
        MFTrackItem* track = self.tracks[indexPath.row];
        [cell setTrack:track];
        
        if ([self.undoRemoveArray containsObject:track]) {
            cell.undoRemoveView.alpha = 1.0;
        } else {
            cell.undoRemoveView.alpha = 0.0;
        }
        if (indexPath.row==0) {
            cell.separatorView.hidden = YES;
        } else {
            cell.separatorView.hidden = NO;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.tracks.count) {
        MFTrackItem* track = self.tracks[indexPath.row];
        
        if ([self.undoRemoveArray containsObject:track]) {
            [self.undoRemoveArray removeObject:track];
            [UIView animateWithDuration:0.3 animations:^{
                [[(PlaylistTrackCell*)[tableView cellForRowAtIndexPath:indexPath] undoRemoveView] setAlpha:0.0];
            }];
        } else {
            //[self didSelectPlay:track onlyOne:NO];
            [self shouldOpenTrackInfo:self.tracks[indexPath.row]];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Button Touches

- (IBAction)didTouchUpBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTouchUpCloseButton:(id)sender
{
    [self.editTextField resignFirstResponder];
    
    self.editTextField.hidden = YES;
    self.closeButton.hidden = YES;
    self.editButton.hidden = NO;
    self.playlistNameLabel.hidden = NO;
}

#pragma mark - PlaylistTrackCell Delegate methods
- (void)didTouchThumb:(MFTrackItem *)track
{
    [self didSelectPlay:track onlyOne:NO];
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
    }];
}

- (void)didAddTrackToPlaylist:(MFTrackItem *)track
{
    PlaylistsViewController *playlistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
    playlistsVC.container = self.container;
    playlistsVC.trackToAdd = track;
    playlistsVC.additionDelegate = self;
    
    [self.navControllerToPush pushViewController:playlistsVC animated:YES];
}

- (void)didRemoveTrackFromPlaylist:(MFTrackItem *)track
{
    if (![self.undoRemoveArray containsObject:track]) {
        [self.undoRemoveArray addObject:track];
        NSIndexPath* ip = [NSIndexPath indexPathForItem:[self.tracks indexOfObject:track] inSection:0];
        [UIView animateWithDuration:0.3 animations:^{
            [[(PlaylistTrackCell*)[self.tracksTableView cellForRowAtIndexPath:ip] undoRemoveView] setAlpha:1.0];
        }];
    }
//    if(track && [self.tracks containsObject:track]){
//        [self.tracks removeObject:track];
//        [self.tracksTableView reloadData];
//        
//        self.playlist.songs = [NSOrderedSet orderedSetWithArray:self.tracks];
//        NSInteger tracksCount = [self.playlist.tracksCount integerValue];
//        self.playlist.tracksCount = @(--tracksCount);
//        self.tracks = _tracks;
//        if (self.playlist.songs.count > 0) {
//            self.playlist.playlistArtwork = ((MFTrackItem *)self.playlist.songs[0]).trackPicture;
//        }
//        else {
//            self.playlist.playlistArtwork = nil;
//        }
//        
//        if ([self.playlist.itemId isEqualToString: @"default"]) {
//            track.isFeedTrack = NO;
//        }
//    }
//    [[IRNetworkClient sharedInstance] deleteSongsWithPlaylistId:self.playlist.itemId songsIds:@[track.itemId] email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
//        
//        //NSIndexPath *indexPath = [self indexPathForTrackWithId:track.itemId];
//        [MFNotificationManager postUpdatePlaylistNotification:self.playlist];
//        [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
//        
//    } failureBlock:^(NSString *errorMessage) {
//        // TODO: handle error
//    }];
}

- (void)didRestoreTrack:(MFTrackItem *)track
{
    
}

- (void)shouldShowTrackInfo:(MFTrackItem *)track
{
    self.trackItem = track;
    [self showSharing];
//    [self shouldOpenTrackInfo:track];
}

- (void)didRepostTrack:(MFTrackItem *)track{
    [[IRNetworkClient sharedInstance] publishTrackByID:track.itemId SuccessBlock:^(NSDictionary *dictionary) {
        [[MFMessageManager sharedInstance] showTrackRepostedMessageInViewController:self.tabBarController];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

    }];
}

- (void)shouldShowComments:(MFTrackItem *)track
{
//    CommentsViewController *commentsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
//    [commentsVC setTrackItem:track];
//    [commentsVC setDelegate:self];
//    commentsVC.container = self.container;
//    
//    [self.navControllerToPush pushViewController:commentsVC animated:YES];
    MFSingleTrackViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = track;
    trackInfoVC.container = self.container;
    [self.navControllerToPush pushViewController:trackInfoVC animated:YES];

}

#pragma mark - TextField Methods

- (IBAction)didTextFieldSelectDone:(id)sender
{
    [self.editTextField resignFirstResponder];
    
    NSString *playlistTitle = self.editTextField.text;
    self.playlistNameLabel.text = playlistTitle;
    self.editTextField.hidden = YES;
    self.closeButton.hidden = YES;
    self.editButton.hidden = NO;
    self.playlistNameLabel.hidden = NO;
    
    [[IRNetworkClient sharedInstance] putPlaylistWithId:self.playlist.itemId newTitle:playlistTitle email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
        self.playlist.title = playlistTitle;
        [MFNotificationManager postUpdatePlaylistNotification:_playlist];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

#pragma mark - Taps

- (void)didTapAtNameLabel:(id)sender
{
    self.editTextField.text = self.playlist.title;
    self.playlistNameLabel.hidden = YES;
    self.editTextField.hidden = NO;
    self.closeButton.hidden = NO;
    self.editButton.hidden = YES;
    [self.editTextField becomeFirstResponder];
}

#pragma mark - TrackInfoPlayDelegate methods

- (void)didSelectPlay:(MFTrackItem *)trackItem
{
    [self didSelectPlay:trackItem onlyOne:YES];
}

- (void)didSelectPlay:(MFTrackItem *)trackItem onlyOne:(BOOL)one
{
    [self.container setPlayerViewHidden:NO];

    if (self.isUpNextPlaylist) {
        one = YES;
    }

    NSUInteger index = [self.tracks indexOfObject:trackItem];
    if (![playerManager.currentTrack isEqual:self.tracks[index]]) {
        if (one) {
            [playerManager playSingleTrack:trackItem];
        } else {
            [playerManager playPlaylist:self.tracks fromIndex:index];
            
            if (self.isMyMusic) {
                playerManager.currentSourceName = NSLocalizedString(self.playlist.title, nil);
            } else {
                playerManager.currentSourceName = [NSString stringWithFormat:@"%@ — %@", self.playlist.user.name, NSLocalizedString(self.playlist.title, nil)];
                if (self.isHistoryPlaylist) {
                    playerManager.currentSourceName = [NSString stringWithFormat:@"IDENTIFICATION HISTORY"];
                }
            }
        }
    }
    else if ([playerManager playing]) {
        [playerManager pauseTrack];
    }
    else {
        [playerManager resumeTrack];
    }
}

#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender
{
    if ([self.tracksTableView numberOfRowsInSection:0] > 0) {
        [self.tracksTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - PlaylistViewControllerTrackAdditionDelegate

- (void)didAddTrack:(MFTrackItem *)trackItem toPlaylist:(MFPlaylistItem *)playlist
{
//    if (![playlist isEqual:self.playlist]) {
//        [self didRemoveTrackFromPlaylist:trackItem];
//    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_scrollDelegate) {
        [self.scrollDelegate scrollViewDidScroll:(UIScrollView *)scrollView];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.parentViewController && [self.parentViewController isKindOfClass:[MFNewProfileViewController class]]) {
        return self.parentViewController.preferredStatusBarStyle;
    }
    if (self.headerImage) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (IBAction)editButtonTapped:(id)sender {
    MFEditPlaylistViewController* vc = [[MFEditPlaylistViewController alloc] init];
    vc.playlist = self.playlist;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];

}

- (void)editPlaylistController:(MFEditPlaylistViewController *)controller didFinishedWithName:(NSString *)name private:(BOOL)isPrivate{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [[IRNetworkClient sharedInstance] putPlaylistWithId:self.playlist.itemId newTitle:name private:isPrivate email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
        self.playlist.title = name;
        self.playlist.isPrivate = isPrivate;
        [self setPlaylistNameLabelText:self.playlist.title];
        [MFNotificationManager postUpdatePlaylistNotification:_playlist];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

- (void)editPlaylistControllerDidCancel:(MFEditPlaylistViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)editPlaylistControllerDidDelete:(MFEditPlaylistViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [[IRNetworkClient sharedInstance] deletePlaylistWithId:self.playlist.itemId email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
        [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}
@end
