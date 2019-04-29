//
//  MFPlaylistsProfilePartViewController.m
//  botmusic
//
//  Created by Panda Systems on 1/15/16.
//
//

#import "MFPlaylistsProfilePartViewController.h"
#import "MFProfilePlaylistCollectionViewCell.h"
#import "UIColor+Expanded.h"
@interface MFPlaylistsProfilePartViewController ()

@end

@implementation MFPlaylistsProfilePartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MFProfilePlaylistCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MFProfilePlaylistCollectionViewCell"];
    // Do any additional setup after loading the view.
    if (self.userInfo.isMyUserInfo) {
        NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUpdatePlaylist];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didUpdatePlaylist:)
                                                     name:notificationName
                                                   object:nil];

        NSString *notificationTypeUpdateLovedTracksPlaylist = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateLovedTracksPlaylist];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLovedTracksPlaylist)
                                                     name:notificationTypeUpdateLovedTracksPlaylist
                                                   object:nil];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setObjectsFromCache{
    if (self.userInfo.playlists.count>0) {
        self.objects = [[self.userInfo.playlists array] subarrayWithRange:NSMakeRange(1, self.userInfo.playlists.count-1)];
    }
    if (self.objects.count>0) {
        self.countLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.objects.count - 1];
    }
}

- (void)downloadObjects{
    NSString *extId = self.userInfo.extId;
    [[IRNetworkClient sharedInstance] getPlaylistsWithEmail:userManager.userInfo.email token:userManager.fbToken extId:extId successBlock:^(NSArray *array) {

        NSArray *playlists = [dataManager convertAndAddPlaylistsToDatabase:array ofUser:self.userInfo];

        self.userInfo.playlists = [NSOrderedSet orderedSetWithArray:playlists];
        if (playlists.count>0) {
            self.objects = [playlists subarrayWithRange:NSMakeRange(1, playlists.count-1)];
        }
        [self.collectionView reloadData];
        self.countLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.objects.count -1];
        self.isLoadedObjects = YES;

        [self.delegate profilePartViewControllerLoadedObjects:self];

    } failureBlock:^(NSString *errorMessage) {
        // TODO: handle error
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:((UIViewController*)self.delegate).tabBarController];

    }];
}

- (CGSize)itemSize{
    return (CGSize){100,165};
}

- (UICollectionViewCell*)cellForItemAtIndexPath:(NSIndexPath*)indexPath{
    MFProfilePlaylistCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MFProfilePlaylistCollectionViewCell" forIndexPath:indexPath];
    MFPlaylistItem* playlist =  self.objects[indexPath.row];
    cell.artworkImageView.alpha = 0.0;
    [cell.artworkImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:playlist.playlistArtwork] placeholderImage:[UIImage imageNamed:@"DefaultArtwork"]];
    cell.numberLabel.text = [NSString stringWithFormat:@"%@", playlist.tracksCount];
    if ([playlist.itemId isEqualToString:@"likes"]) {
        cell.nameLabel.text = NSLocalizedString(@"Loved Tracks", nil);
        cell.heart.hidden = NO;
        cell.nameLabelLeft.constant = 14;
        cell.nameLabel.textColor = cell.heart.textColor;
    } else {
        cell.nameLabel.text = playlist.title;
        cell.heart.hidden = YES;
        cell.nameLabelLeft.constant = 0;
        cell.nameLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void) updateLovedTracksPlaylist{
    [self reloadData];
}

- (void) didUpdatePlaylist:(NSNotification*)notification{
    MFPlaylistItem *playlist = [notification.userInfo valueForKey:@"playlist"];
    [self.objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([((MFPlaylistItem*)obj).itemId isEqualToString:playlist.itemId]) {
            NSMutableArray* newPlaylists = [self.objects mutableCopy];
            [newPlaylists replaceObjectAtIndex:idx withObject:playlist];
            self.objects = [newPlaylists copy];

            NSIndexPath* ip = [NSIndexPath indexPathForItem:idx inSection:0];
            [self.collectionView reloadItemsAtIndexPaths:@[ip]];

            *stop = YES;
        }
    }];
}

@end
