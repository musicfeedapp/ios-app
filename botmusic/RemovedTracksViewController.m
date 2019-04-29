//
//  RemovedTracksViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/28/15.
//
//

#import "RemovedTracksViewController.h"
#import "CommentsViewController.h"
#import "PlaylistTrackCell.h"
#import "TrackInfoViewController.h"
#import "MFNotificationManager.h"
#import "MFNumberOfTracksTableViewCell.h"
#import "PlaylistsViewController.h"
#import "MFSingleTrackViewController.h"

@interface RemovedTracksViewController () <PlaylistTrackCellDelegate, PlaylistViewControllerTrackAdditionDelegate>

@property (nonatomic, strong) NSMutableArray *tracks;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation RemovedTracksViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setDefaultTracks];
    [self setUI];
    
    NSString *notificationStatusBarTappedName = [MFNotificationManager nameForNotification:MFNotificationTypeStatusBarTapped];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didTapOnHeader:)
                                                 name:notificationStatusBarTappedName
                                               object:nil];
    [self.tracksTableView setContentInset:UIEdgeInsetsMake(20.0, 0, 0.0, 0)];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    playerManager.videoPlayer.currentViewController = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers


- (void)setDefaultTracks
{
    self.tracks = [[NSMutableArray alloc] init];
    
    [self downloadRemovedTracks];
}

- (void)setUI
{
    UINib *playlistTrackCellNib = [UINib nibWithNibName:@"PlaylistTrackCell" bundle:nil];
    [self.tracksTableView registerNib:playlistTrackCellNib forCellReuseIdentifier:@"PlaylistTrackCell"];
    
    [self.tracksTableView reloadData];
}

- (void)downloadRemovedTracks
{   [self.activityIndicator startAnimating];
    [[IRNetworkClient sharedInstance] getRemovedTracksWithEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSArray *array) {
        [self.activityIndicator stopAnimating];
        NSArray *removedTracks = [dataManager convertAndAddTracksToDatabase:array];
        self.tracks = [NSMutableArray arrayWithArray:removedTracks];
        [self.tracksTableView reloadData];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
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
    return self.tracks.count + 1;
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
        MFTrackItem* track = self.tracks[indexPath.row];
        cell.playlistTrackCellDelegate = self;
        [cell setTrack:track];
        [cell setIsMyMusic:NO];
        [cell setIsRemovedTrack:YES];
        cell.undoRemoveView.alpha = 0.0;
        
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
        [self shouldOpenTrackInfo:self.tracks[indexPath.row]];

    }
}

#pragma mark - Button Touches

- (IBAction)didTouchUpBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PlaylistTrackCell Delegate methods
- (void)didTouchThumb:(MFTrackItem *)track
{
    [self.container setPlayerViewHidden:NO];
    
    [self.tracksTableView setContentInset:UIEdgeInsetsMake(self.tracksTableView.contentInset.top, 0, PLAYER_VIEW_HEIGHT, 0)];
    NSUInteger index = [self.tracks indexOfObject:track];
    if (![playerManager.currentTrack isEqual:self.tracks[index]]) {
        [playerManager playSingleTrack:self.tracks[index]];
    }
    else if ([playerManager playing]) {
        [playerManager pauseTrack];
    }
    else {
        [playerManager resumeTrack];
    }

}

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

- (void)didRestoreTrack:(MFTrackItem *)track
{
    [self.tracks removeObject:track];
    
    [self.tracksTableView reloadData];
    [[IRNetworkClient sharedInstance] restoreTrackWithId:track.itemId email:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary *dictionary) {
        [MFNotificationManager postRestoreTrackNotification];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
    }];
}

- (void)shouldShowComments:(MFTrackItem *)track
{
//    CommentsViewController *commentsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
//    [commentsVC setTrackItem:track];
//    //    [commentsVC setDelegate:self];
//    commentsVC.container = self.container;
//    
//    [self.navControllerToPush pushViewController:commentsVC animated:YES];
    MFSingleTrackViewController *trackInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MFSingleTrackViewController"];
    trackInfoVC.track = track;
    trackInfoVC.container = self.container;
    
    [self.navControllerToPush pushViewController:trackInfoVC animated:YES];
}

- (void)shouldShowTrackInfo:(MFTrackItem *)track
{
    self.trackItem = track;
    [self showSharing];
}

#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender
{
    if ([self.tracksTableView numberOfRowsInSection:0] > 0) {
        [self.tracksTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)didAddTrackToPlaylist:(MFTrackItem *)track
{
    PlaylistsViewController *playlistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playlistsViewController"];
    playlistsVC.container = self.container;
    playlistsVC.trackToAdd = track;
    playlistsVC.additionDelegate = self;
    
    [self.navControllerToPush pushViewController:playlistsVC animated:YES];
}

- (void)didAddTrack:(MFTrackItem *)trackItem toPlaylist:(MFPlaylistItem *)playlist
{
    //    if (![playlist isEqual:self.playlist]) {
    //        [self didRemoveTrackFromPlaylist:trackItem];
    //    }
}

- (void)didRepostTrack:(MFTrackItem *)track{
    [[IRNetworkClient sharedInstance] publishTrackByID:track.itemId SuccessBlock:^(NSDictionary *dictionary) {
        [[MFMessageManager sharedInstance] showTrackRepostedMessageInViewController:self.tabBarController];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];

    }];
}
@end
