//
//  PlaylistsViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/23/15.
//
//

#import "PlaylistsViewController.h"

#import <UIColor+Expanded.h>

#import "PlaylistCell.h"
#import "PlaylistTrackCell.h"
#import "MFPlaylistItem+Behavior.h"
#import "MFNotificationManager.h"
#import "PlaylistTracksViewController.h"
#import <Mixpanel.h>
#import "MagicalRecord/MagicalRecord.h"
#import "MFNewProfileViewController.h"
#import "MFAddPlaylistTableViewCell.h"
#import "MFAddPlaylistViewController.h"
#import "UIImageView+WebCache_FadeIn.h"

@interface PlaylistsViewController () <PlaylistCellDelegate, PlaylistTrackCellDelegate,UIAlertViewDelegate,MFAddPlaylistViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *playlists;

@property (nonatomic) BOOL isScrollToBottom;
@property (weak, nonatomic) IBOutlet UIButton *cancelDismissButton;
@property (weak, nonatomic) IBOutlet UIView *noPlaylistsView;
@property (nonatomic, strong) UITextField* addPlaylistTextField;
@end

@implementation PlaylistsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNotifications];
    [self setUI];
    if(!self.userInfo||self.userInfo.playlists.count>0)[self setDefaultPlaylists];
    [self downloadPlaylists];
    self.tableViewBelowMessageBar = self.playlistsTableView;
    
    int topInset = 0;
    int botInset = 0;
//    if (self.parentViewController && [self.parentViewController isKindOfClass:[MFNewProfileViewController class]]) {
//        topInset = self.topTableInset + 45;
//    }
    topInset = 64+20;
    botInset += self.tabBarController.tabBar.bounds.size.height;

    [self.playlistsTableView setContentInset:UIEdgeInsetsMake(topInset, 0, botInset, 0)];
    //[self.playlistsTableView setScrollIndicatorInsets:UIEdgeInsetsMake(topInset, 0, botInset, 0)];
    [self.playlistsTableView setContentOffset:CGPointMake(0, -topInset)];

//    if (self.parentViewController && [self.parentViewController isKindOfClass:[MFNewProfileViewController class]]) {
//        [self.playlistsTableView setContentOffset:CGPointMake(0, -topInset)];
//        [self scrollViewDidScroll:self.playlistsTableView];
//    }
    if (self.userInfo.isMyUserInfo) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTracks) name:@"MFUpdateTrackHistory" object:nil];
    }

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.parentViewController && [self.parentViewController isKindOfClass:[MFNewProfileViewController class]]) {
    } else {
        playerManager.videoPlayer.currentViewController = self;
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.playlistsTableView.delegate = nil;
}

- (void)updateTracks{
    [self.playlistsTableView reloadData];
}

#pragma mark - Helpers

- (void)setUserInfo:(MFUserInfo *)userInfo
{
    _userInfo = userInfo;
    [self setDefaultPlaylists];
}

- (NSArray *)cachedPlaylists
{
    return [userManager.userInfo.playlists array];
}

- (void)setNotifications
{
    NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUpdatePlaylist];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlaylist:)
                                                 name:notificationName
                                               object:nil];
    
    NSString *notificationStatusBarTappedName = [MFNotificationManager nameForNotification:MFNotificationTypeStatusBarTapped];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didTapOnHeader:)
                                                 name:notificationStatusBarTappedName
                                               object:nil];
    if (self.userInfo.isMyUserInfo) {
        NSString *notificationTypeUpdateLovedTracksPlaylist = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateLovedTracksPlaylist];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadPlaylists)
                                                     name:notificationTypeUpdateLovedTracksPlaylist
                                                   object:nil];

    }
}

- (void)setDefaultPlaylists
{
    if (!self.userInfo) {
        self.playlists = [[self cachedPlaylists] mutableCopy];
    } else {
        if(self.userInfo.playlists.count>2){
            self.playlists = [[self.userInfo.playlists array] mutableCopy];
            [self.playlistsTableView reloadData];
        }
    }
}

- (void)setUI
{
    self.menuButton.hidden = YES;
    self.backButton.hidden = NO;

    
//    if (self.userInfo) {
//        self.headerViewHeightConstraint.constant = 0;
//    }

    UINib *playlistCellNib = [UINib nibWithNibName:@"PlaylistCell" bundle:nil];
    [self.playlistsTableView registerNib:playlistCellNib forCellReuseIdentifier:@"PlaylistCell"];
    
    UINib *playlistTrackCellNib = [UINib nibWithNibName:@"PlaylistTrackCell" bundle:nil];
    [self.playlistsTableView registerNib:playlistTrackCellNib forCellReuseIdentifier:@"PlaylistTrackCell"];
    
    [_headerView addGestureRecognizer:self.headerTapRecognizer];
    if (self.trackToAdd && (!self.navigationController || self.navigationController.viewControllers[0] == self)) {
        self.backButton.hidden = YES;
        self.cancelDismissButton.hidden = NO;
    }
}

- (void)downloadPlaylists
{
    NSString *extId = _userInfo ? _userInfo.extId : userManager.userInfo.extId;
    [[IRNetworkClient sharedInstance] getPlaylistsWithEmail:userManager.userInfo.email token:userManager.fbToken extId:extId successBlock:^(NSArray *array) {
        
        MFUserInfo* ui = _userInfo;
        if(!ui) ui = userManager.userInfo;
        NSArray *playlists = [dataManager convertAndAddPlaylistsToDatabase:array ofUser:ui];
        
        if(_userInfo){
            _userInfo.playlists = [NSOrderedSet orderedSetWithArray:playlists];
        }
                
        self.playlists = [NSMutableArray arrayWithArray:playlists];
        [self.playlistsTableView reloadData];
        if (playlists.count == 2 && [[(MFPlaylistItem*)playlists[1] tracksCount] intValue] == 0 && (!self.userInfo || self.userInfo.isMyUserInfo)) {
            [self showNoPlaylistsView];
        }
        if (!_userInfo) {
            userManager.userInfo.playlists = [NSOrderedSet orderedSetWithArray: playlists];
        }

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

- (NSIndexPath *)indexPathForPlaylistWithId:(NSString *)playlistId
{
    if (self.playlists.count>1) {
        for (int i = 2; i < self.playlists.count; i++) {
            MFPlaylistItem *playlistItem = self.playlists[i];
            if ([playlistId isEqual:playlistItem.itemId]) {
                return [NSIndexPath indexPathForRow:i-1 inSection:1];
            }
        }
    }
    return nil;
}

- (void) showNoPlaylistsView{
    self.noPlaylistsView.hidden = NO;
    self.playlistsTableView.hidden = YES;
}

- (void) hideNoPlaylistsView{
    self.noPlaylistsView.hidden = YES;
    self.playlistsTableView.hidden = NO;
}

#pragma mark - TableView Delegate & Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        if (self.userInfo.isMyUserInfo||!self.userInfo) {
            if (self.trackToAdd) {
                return 2;
            } else {
                if (playerManager.upNextPlaylist.songs.count) {
                    return 2;
                } else {
                    return 1;
                }
            }
        }
        return 0;
    } else {
        if (self.playlists.count > 1) {
            return self.playlists.count - 1;
        } else {
            return 0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0 && indexPath.row == 0) {
        return 45.0;
    }
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            MFAddPlaylistTableViewCell *cell = (MFAddPlaylistTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MFAddPlaylistTableViewCell"];

            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"MFAddPlaylistTableViewCell" owner:nil options:nil] lastObject];
                [cell.addPlaylistButton addTarget:self action:@selector(addPlaylistButtonTapped) forControlEvents:UIControlEventTouchUpInside];
                self.addPlaylistTextField = cell.addPlaylistNameTextField;
                [cell.addPlaylistNameTextField addTarget:self action:@selector(addPlaylistButtonTapped) forControlEvents:UIControlEventEditingDidEndOnExit];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        } else {
            PlaylistCell *cell = (PlaylistCell *)[tableView dequeueReusableCellWithIdentifier:@"PlaylistCell"];
            [cell setUpNextPlaylist];
            [cell setCanRemove:NO];
            return cell;
        }
        
    } else if (indexPath.section == 1){
        
        static NSString *cellID = @"PlaylistCell";
        
        PlaylistCell *cell = (PlaylistCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PlaylistCell" owner:nil options:nil] lastObject];
        }
        
        [cell setPlaylist:self.playlists[indexPath.row+1]];
        cell.playlistCellDelegate = self;
        
//        if (indexPath.row == 0) {
//            [cell.separatorView setHidden:YES];
//        } else {
//            [cell.separatorView setHidden:NO];
//        }
        
        if (self.trackToAdd || !self.userInfo.isMyUserInfo) {
            [cell setCanRemove:NO];
        } else {
            [cell setCanRemove:YES];
        }
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        
        if (self.trackToAdd) {
            
            //TODO we don't have songs here Most of all we need check it in local cache or use special request to define if we can add track to this playlist.
            MFPlaylistItem* playlistToUpdate = self.playlists[indexPath.row+1];
            
            NSUInteger indexForTrack = [playlistToUpdate.songs indexOfObject:self.trackToAdd];
            BOOL alreadyHaveTrack = NO;
            for (MFTrackItem* t in playlistToUpdate.songs) {
                if ([self.trackToAdd.itemId isEqualToString: t.itemId]) {
                    alreadyHaveTrack = YES;
                }
            }
            
            if (!alreadyHaveTrack) {
                if (self.additionDelegate && [self.additionDelegate respondsToSelector:@selector(playlistsViewController:didFinishWithResult:)]){
                    [self.additionDelegate playlistsViewController:self didFinishWithResult:YES];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                UIViewController* vcToShowMessage = self.tabBarController;
                [[IRNetworkClient sharedInstance] postPlaylistWithId:playlistToUpdate.itemId songsIds:@[self.trackToAdd.itemId] email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
                    //[MFNotificationManager postAddedToPlaylistNotification:self.trackToAdd];
                    [[MFMessageManager sharedInstance] showTrackAddedMessageInViewController:vcToShowMessage];
                    
                    if (self.additionDelegate && [self.additionDelegate respondsToSelector:@selector(didAddTrack:toPlaylist:)]) {
                        [self.additionDelegate didAddTrack:self.trackToAdd toPlaylist:playlistToUpdate];
                    }
                    
                    NSMutableOrderedSet *tracks = [((MFPlaylistItem *)self.playlists[indexPath.row+1]).songs mutableCopy];
                    if (tracks.count>0) {
                        [tracks insertObject:self.trackToAdd atIndex:0];
                    } else {
                        [tracks addObject:self.trackToAdd];
                    }
                    
                    MFPlaylistItem *playlist = (MFPlaylistItem *)self.playlists[indexPath.row+1];
                    playlist.songs =  tracks;
                    NSInteger tracksCount = [playlist.tracksCount integerValue];
                    playlist.tracksCount = @(++tracksCount);
                    if (playlist.songs.count > 0) {
                        playlist.playlistArtwork = ((MFTrackItem *)playlist.songs[0]).trackPicture;
                    }
                    else {
                        playlist.playlistArtwork = nil;
                    }
                    NSMutableArray* array = [[userManager.userInfo.playlists array] mutableCopy];
                    
                    [array removeObject:playlist];
                    [self.playlists removeObject:playlist];
                    if (array.count>2) {
                        [array insertObject:playlist atIndex:2];
                        [self.playlists insertObject:playlist atIndex:2];
                    } else {
                        [array addObject:playlist];
                        [self.playlists addObject:playlist];
                    }
                    [self.tableView reloadData];
                    
                    userManager.userInfo.playlists = [NSOrderedSet orderedSetWithArray:array];
    //                self.trackToAdd.lastActivityType = @"Playlist";
    //                self.trackToAdd.lastActivityTime = [NSDate date];
                    [MFNotificationManager postUpdatePlaylistNotification:playlist];
                    
                } failureBlock:^(NSString *errorMessage) {
                    [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:vcToShowMessage];
                    // TODO: handle error
                }];
                
            }
        }
        else if (self.userInfo) {
            if (_delegate && [_delegate respondsToSelector:@selector(didSelectPlaylist:isDefault:)]) {
                [_delegate didSelectPlaylist:self.playlists[indexPath.row+1] isDefault:NO];
            } else {
                PlaylistTracksViewController *playlistTracksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
                playlistTracksVC.playlist = self.playlists[indexPath.row+1];
                playlistTracksVC.isDefaultPlaylist = NO;
                if (!self.userInfo.isMyUserInfo) {
                    playlistTracksVC.shouldShowOwnerAvatar = YES;
                }
                playlistTracksVC.userExtId = self.userInfo.extId;
                playlistTracksVC.isMyMusic = YES;
                [self.navControllerToPush pushViewController:playlistTracksVC animated:YES];
            }
        }
        else {
//            PlaylistTracksViewController *playlistTracksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
//            playlistTracksVC.playlist = self.playlists[indexPath.row+1];
//            playlistTracksVC.isDefaultPlaylist = NO;
//            playlistTracksVC.userExtId = userManager.userInfo.extId;
//            playlistTracksVC.isMyMusic = YES;
//            [self.navControllerToPush pushViewController:playlistTracksVC animated:YES];
        }
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        if (self.trackToAdd) {
            [playerManager addTrackToNowPlaying:self.trackToAdd];
            if (self.additionDelegate && [self.additionDelegate respondsToSelector:@selector(playlistsViewController:didFinishWithResult:)]){
                [self.additionDelegate playlistsViewController:self didFinishWithResult:YES];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            PlaylistTracksViewController *playlistTracksVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
            playlistTracksVC.playlist = playerManager.upNextPlaylist;
            playlistTracksVC.isDefaultPlaylist = NO;
            playlistTracksVC.isUpNextPlaylist = YES;
            playlistTracksVC.userExtId = userManager.userInfo.extId;
            playlistTracksVC.isMyMusic = NO;
//            if (self.parentViewController && [self.parentViewController isKindOfClass:[MFNewProfileViewController class]]) {
//                playlistTracksVC.headerImage = [((MFNewProfileViewController*)self.parentViewController) headerBlurredImage];
//            }
            [self.navControllerToPush pushViewController:playlistTracksVC animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) addPlaylistButtonTapped{
    [self.addPlaylistTextField resignFirstResponder];
    MFAddPlaylistViewController* vc = [[MFAddPlaylistViewController alloc] init];
    vc.prefilledText = self.addPlaylistTextField.text;
    self.addPlaylistTextField.text = @"";
    vc.delegate = self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void) addPlaylistControllerDidCancel:(MFAddPlaylistViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:self.preferredStatusBarStyle animated:YES];

}

- (void) addPlaylistController:(MFAddPlaylistViewController *)controller didFinishedWithName:(NSString *)name private:(BOOL)isPrivate{
    self.playlistTextField.text = name;
    [[UIApplication sharedApplication] setStatusBarStyle:self.preferredStatusBarStyle animated:YES];
    [controller dismissViewControllerAnimated:YES completion:^{
        [self createPlaylist:name private:isPrivate];
    }];
}

#pragma mark - Button Touches

- (IBAction)didTouchUpAddPlaylistButton:(id)sender
{
    self.playlistsTableView.hidden = YES;
    self.createPlaylistView.hidden = NO;
    self.addPlaylistButton.hidden = YES;
    if (self.trackToAdd) {
        self.backButton.hidden = YES;
    }
    else {
        self.menuButton.hidden = YES;
    }
    self.cancelPlaylistAddingButton.hidden = NO;
    [self.playlistTextField becomeFirstResponder];
}

- (IBAction)didTouchUpCancelAddingPlaylistButton:(id)sender
{
    [self.playlistTextField resignFirstResponder];
    self.playlistTextField.text = @"";
    self.playlistsTableView.hidden = NO;
    self.createPlaylistView.hidden = YES;
    self.addPlaylistButton.hidden = NO;
    if (self.trackToAdd) {
        self.backButton.hidden = NO;
    }
    else {
        self.menuButton.hidden = NO;
    }
    self.cancelPlaylistAddingButton.hidden = YES;
}

- (IBAction)didTouchUpBackButton:(id)sender
{
    if (self.additionDelegate && [self.additionDelegate respondsToSelector:@selector(playlistsViewController:didFinishWithResult:)]){
        [self.additionDelegate playlistsViewController:self didFinishWithResult:NO];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - TextField Methods

- (void) createPlaylist:(NSString*)name private:(BOOL)isPrivate
{
    NSString *playlistTitle = name;
    [[IRNetworkClient sharedInstance] postPlaylistWithTitle:playlistTitle private:isPrivate email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
        MFPlaylistItem *playlist = [MFPlaylistItem MR_createEntity];
        [playlist configureWithDictionary:dictionary];
        playlist.user = userManager.userInfo;
        playlist.isPrivate = isPrivate;
        NSMutableArray* playlists = [[userManager.userInfo.playlists array] mutableCopy];
        
        if (playlists.count>2) {
            [playlists insertObject:playlist atIndex:2];
        } else {
            [playlists addObject:playlist];
        }
        userManager.userInfo.playlists = [NSOrderedSet  orderedSetWithArray:playlists];

        [self.playlists insertObject:playlist atIndex:2];
        [self.playlistsTableView beginUpdates];
        [self.playlistsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.playlistsTableView endUpdates];
        [self hideNoPlaylistsView];
        [userManager userInfo].playlistsCount++;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MFPlaylistsCountDidUpdated" object:nil];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];

    [self didTouchUpCancelAddingPlaylistButton:nil];
}

#pragma mark - PlaylistCell Delegate

-(void) didTouchThumb:(MFTrackItem *)track{
    if (_delegate && [_delegate respondsToSelector:@selector(shouldPlayTrack:)]) {
        [_delegate shouldPlayTrack:track];
    }
}

- (void)didRemovePlaylist:(MFPlaylistItem *)playlist
{
    self.playlistToRemove = playlist;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Deleting a playlist",nil)
                                                        message:[NSString stringWithFormat: NSLocalizedString(@"Are you sure you want to delete \"%@\"?",nil), playlist.title]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No",nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
    [alertView setTag:0];
    [alertView show];
    
}

- (void)didMarkPrivate:(MFPlaylistItem *)playlist
{
    NSIndexPath *indexPath = [self indexPathForPlaylistWithId:playlist.itemId];
    playlist.isPrivate = !playlist.isPrivate;
    
    [self.playlistsTableView beginUpdates];
    [self.playlistsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.playlistsTableView endUpdates];
    
    [[IRNetworkClient sharedInstance] putPlaylistWithId:playlist.itemId private:playlist.isPrivate email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
        
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

#pragma mark - Notifications center

- (void)didUpdatePlaylist:(NSNotification *)notification
{
    
    MFPlaylistItem *playlist = [notification.userInfo valueForKey:@"playlist"];
    NSIndexPath *indexPath = [self indexPathForPlaylistWithId:playlist.itemId];
    PlaylistCell *playlistCell = (PlaylistCell *)[self.playlistsTableView cellForRowAtIndexPath:indexPath];
    if (playlistCell) {
        [self.playlists replaceObjectAtIndex:indexPath.row+1 withObject:playlist];
        [self.playlistsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender
{
    if ([self.playlistsTableView numberOfRowsInSection:0] > 0) {
        [self.playlistsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_scrollDelegate) {
        [self.scrollDelegate scrollViewDidScroll:(UIScrollView *)scrollView];
    }
}

#pragma mark - PlaylistTrackCellDelegate methods

- (void)didLikeTrack:(MFTrackItem *)track
{
    __block MFTrackItem *trackItem = track;
    [[IRNetworkClient sharedInstance] likeTrackById:track.itemId withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^{
        
    } failureBlock:^(NSString *errorMessage) {
        //trackItem.isLiked = NO;
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

- (void)didUnlikeTrack:(MFTrackItem *)track
{
    __block MFTrackItem *trackItem = track;
    [[IRNetworkClient sharedInstance] unlikeTrackById:track.itemId withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^{
        
    } failureBlock:^(NSString *errorMessage) {
        //trackItem.isLiked = YES;
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

- (void)didAddTrackToPlaylist:(MFTrackItem *)track
{
//    PlaylistsViewController *playlistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
//    playlistsVC.container = self.container;
//    playlistsVC.trackToAdd = track;
//    
//    [self.navControllerToPush pushViewController:playlistsVC animated:YES];
}

- (void)didRemoveTrackFromPlaylist:(MFTrackItem *)track
{
    
}

- (void)didRestoreTrack:(MFTrackItem *)track
{
    
}

- (void)shouldShowTrackInfo:(MFTrackItem *)track
{
    if (_delegate && [_delegate respondsToSelector:@selector(shouldShowTrackInfo:)]) {
        [_delegate shouldShowTrackInfo:track];
    }
}

- (void)shouldShowComments:(MFTrackItem *)track
{
    if (_delegate && [_delegate respondsToSelector:@selector(shouldShowComments:)]) {
        [_delegate shouldShowComments:track];
    }
}



#pragma mark - UIAlertVIew Delegate methods


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex&&self.playlistToRemove) {
            NSIndexPath *indexPath = [self indexPathForPlaylistWithId:self.playlistToRemove.itemId];
            [self.playlists removeObject:self.playlistToRemove];
            NSMutableOrderedSet* set = [userManager.userInfo.playlists mutableCopy];
            [set removeObject:self.playlistToRemove];
            userManager.userInfo.playlists = set;
            
            [self.playlistsTableView beginUpdates];
            [self.playlistsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.playlistsTableView endUpdates];
            [userManager userInfo].playlistsCount--;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MFPlaylistsCountDidUpdated" object:nil];
            [[IRNetworkClient sharedInstance] deletePlaylistWithId:self.playlistToRemove.itemId email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
                if (self.playlists.count == 2 && [[(MFPlaylistItem*)self.playlists[1] tracksCount] intValue] == 0 && (!self.userInfo || self.userInfo.isMyUserInfo)) {
                    [self showNoPlaylistsView];
                } else {
                    [self hideNoPlaylistsView];
                }
            } failureBlock:^(NSString *errorMessage) {
                [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
            }];
        }
    }

}

- (IBAction)firstPlaylistButtonTapped:(id)sender {
    [self addPlaylistButtonTapped];
}

@end