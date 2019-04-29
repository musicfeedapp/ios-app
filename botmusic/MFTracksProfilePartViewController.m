//
//  MFTracksProfilePartViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/12/16.
//
//

#import "MFTracksProfilePartViewController.h"
#import "MFProfileTrackCell.h"
#import "MFNotificationManager.h"

@interface MFTracksProfilePartViewController () <MFProfileTrackCellDelegate>

@end

@implementation MFTracksProfilePartViewController

- (void)viewDidLoad {
    self.collectionView.hidden = YES;
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MFProfileTrackCell" bundle:nil] forCellWithReuseIdentifier:@"MFProfileTrackCell"];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setObjectsFromCache{
    if (self.userInfo.playlists.count>1) {
        self.playlist = self.userInfo.playlists[0];
        self.objects = [((MFPlaylistItem*)self.userInfo.playlists[0]).songs array];
        [self.collectionView reloadData];
        if (self.objects.count>0) {
            self.collectionView.hidden = NO;
            self.countLabel.text = [NSString stringWithFormat:@"%@",self.playlist.tracksCount];
        }
    }
}

- (void)downloadObjects{
    [[IRNetworkClient sharedInstance] getPlaylistsWithEmail:userManager.userInfo.email token:userManager.fbToken extId:self.userInfo.extId successBlock:^(NSArray *array) {

        NSArray *playlists = [dataManager convertAndAddPlaylistsToDatabase:array ofUser:self.userInfo];

        self.userInfo.playlists = [NSOrderedSet orderedSetWithArray:playlists];
        self.playlist = playlists[0];
        [[IRNetworkClient sharedInstance] getPlaylistsWithId:self.playlist.itemId extId:self.userInfo.extId lastTimelineId:nil successBlock:^(NSDictionary *dictionary) {
            NSArray *tracks = [dataManager convertAndAddTracksToDatabase:dictionary[@"songs"]];
            self.playlist.songs = [NSOrderedSet orderedSetWithArray:tracks];
            self.objects = [self.playlist.songs array];

            if (tracks.count > 0 && [self.userInfo.extId isEqual:userManager.userInfo.extId]) {
                [MFNotificationManager postUpdatePlaylistNotification:self.playlist];
            }
            
            if (self.isOpenedState && self.collectionView.hidden) {
                self.collectionView.alpha = 0.0;
                [UIView animateWithDuration:0.3 animations:^{
                    self.collectionView.alpha = 1.0;
                }];
            }
            self.collectionView.hidden = NO;

            self.countLabel.text = [NSString stringWithFormat:@"%@",self.playlist.tracksCount];
            self.isLoadedObjects = YES;
            [self.delegate profilePartViewControllerLoadedObjects:self];
            [self.collectionView reloadData];
        } failureBlock:^(NSString *errorMessage) {
            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:((UIViewController*)self.delegate).tabBarController];

        }];
    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:((UIViewController*)self.delegate).tabBarController];

        // TODO: handle error
    }];
}

- (CGSize)itemSize{
    return (CGSize){100,150};
}

- (UICollectionViewCell*)cellForItemAtIndexPath:(NSIndexPath*)indexPath{
    MFProfileTrackCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MFProfileTrackCell" forIndexPath:indexPath];
    MFTrackItem* track = self.objects[indexPath.row];
    cell.track = track;
    cell.trackImage.alpha = 0.0;
    [cell.trackImage sd_setImageAndFadeOutWithURL:[NSURL URLWithString:track.trackPicture]];
    cell.trackNameLabel.text = track.trackName;
    cell.delegate = self;
    return cell;
}

- (void) profileTrackCellDidTapPlay:(MFProfileTrackCell *)cell{

    NSUInteger index = [self.objects indexOfObject:cell.track];
    if (![playerManager.currentTrack isEqual:self.objects[index]]) {
        [playerManager playPlaylist:self.objects fromIndex:(int)index];

        if (self.userInfo.isMyUserInfo) {
            playerManager.currentSourceName = NSLocalizedString(self.playlist.title, nil);
        } else {
            playerManager.currentSourceName = [NSString stringWithFormat:@"%@ — %@", self.playlist.user.name, NSLocalizedString(self.playlist.title, nil)];
        }

    }
    else if ([playerManager playing]) {
        [playerManager pauseTrack];
    }
    else {
        [playerManager resumeTrack];
    }
}

@end
