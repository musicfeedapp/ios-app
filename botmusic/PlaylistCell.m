//
//  PlaylistCell.m
//  botmusic
//
//  Created by Panda Systems on 1/23/15.
//
//

#import "PlaylistCell.h"

#import <UIColor+Expanded.h>

#import "MFPlaylistItem+Behavior.h"
#import "MFTrackItem+Behavior.h"
#import "MGSwipeButton.h"
#import "UIImageView+WebCache_FadeIn.h"
static UIImage* defaultArtwork;

@implementation PlaylistCell

- (void)awakeFromNib {
    // Initialization code
    self.separatorHeightConstrain.constant = 1.0/[UIScreen mainScreen].scale;
    if (!defaultArtwork) {
        defaultArtwork = [UIImage imageNamed:@"DefaultArtwork"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPlaylist:(MFPlaylistItem *)playlist
{
    if ([playlist.itemId isEqualToString:@"likes"]) {
        self.hearticon.hidden = NO;
        self.playlistNameLabel.textColor = self.hearticon.textColor;
        self.playlistNameLeading.constant = 34;
        self.playlistNameLabel.text = NSLocalizedString(@"Loved Tracks",nil);

    } else {
        self.hearticon.hidden = YES;
        self.playlistNameLabel.textColor = [UIColor blackColor];
        self.playlistNameLeading.constant = 12;
        self.playlistNameLabel.text = NSLocalizedString(playlist.title,nil);

    }
    _playlist = playlist;
    //((UILabel*)self.lockedPlaylistIcon).textColor = [UIColor colorWithRGBHex:kAppMainColor];
    if (playlist.isPrivate) {
        self.lockedPlaylistIcon.alpha = 1.0;
        self.numberOfTracksLeftConstraint.constant = 25.0;
    } else {
        self.lockedPlaylistIcon.alpha = 0.0;
        self.numberOfTracksLeftConstraint.constant = 12.0;
    }
    self.tracksLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d",nil), [playlist.tracksCount intValue]];
    //self.durationLabel.text = @"\uf1f0";
    self.durationLabel.text = @"";
    
    NSURL* imageUrl = [NSURL URLWithString:playlist.playlistArtwork];
    [self.playlistImageView sd_setImageAndFadeOutWithURL:imageUrl
                                            placeholderImage:defaultArtwork];
}

- (void)setUpNextPlaylist
{
    self.hearticon.hidden = YES;
    self.playlistNameLabel.textColor = [UIColor blackColor];
    self.playlistNameLeading.constant = 12;

    self.lockedPlaylistIcon.alpha = 1.0;
    self.numberOfTracksLeftConstraint.constant = 25.0;
    
    self.playlistNameLabel.text = NSLocalizedString(@"Up Next",nil);
    self.tracksLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d",nil), playerManager.nowPlayingQueue.count];
    
    self.durationLabel.text = @"";
    if (playerManager.upNextPlaylist.songs.count) {
        NSURL* imageUrl = [NSURL URLWithString:((MFTrackItem*)playerManager.upNextPlaylist.songs[0]).trackPicture];
        [self.playlistImageView sd_setImageAndFadeOutWithURL:imageUrl
                                  placeholderImage:defaultArtwork];
    } else {
        self.playlistImageView.image = defaultArtwork;
    }

}

- (void)setCanRemove:(BOOL)canRemove
{
    _canRemove = canRemove;
    
    if (canRemove) {
//        MGSwipeButton *swipeButtonRemove = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"delete",nil)
//                                                          backgroundColor:[UIColor colorWithRGBHex:kOffWhiteColor]
//                                                                  padding:0
//                                                                 callback:^BOOL(MGSwipeTableCell *sender) {
//                                                                     [self removePlaylist];
//                                                                     return YES;
//                                                                 }];
//        [swipeButtonRemove setTitleColor:[UIColor colorWithRGBHex:kBrandPinkColor] forState:UIControlStateNormal];
//        [swipeButtonRemove.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
//        
//        UIPanGestureRecognizer *removePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
//        [swipeButtonRemove addGestureRecognizer:removePanRecognizer];
//        
//        NSString *privateButtonTitle = _playlist.isPrivate ? NSLocalizedString(@"make public",nil): NSLocalizedString(@"make private",nil);
//        MGSwipeButton *swipeButtonPrivate = [MGSwipeButton buttonWithTitle:privateButtonTitle
//                                                           backgroundColor:[UIColor colorWithRGBHex:kOffWhiteColor]
//                                                                   padding:0
//                                                                  callback:^BOOL(MGSwipeTableCell *sender) {
//                                                                      [self markPrivate];
//                                                                      return YES;
//                                                                  }];
//        [swipeButtonPrivate setTitleColor:[UIColor colorWithRGBHex:kLightColor] forState:UIControlStateNormal];
//        [swipeButtonPrivate.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
//        
//        UIPanGestureRecognizer *privatePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
//        [swipeButtonPrivate addGestureRecognizer:privatePanRecognizer];
//        
//        self.rightButtons =  @[swipeButtonRemove, swipeButtonPrivate];
//        self.rightSwipeSettings.transition = MGSwipeTransitionBorder;
//        MGSwipeExpansionSettings* sws = [[MGSwipeExpansionSettings alloc] init];
//        sws.buttonIndex = 0;
//        sws.fillOnTrigger = YES;
//        sws.threshold = 1;
//        self.rightExpansion = sws;
    }
    else {
        self.rightButtons = nil;
        self.rightExpansion = nil;
    }
}

- (void)removePlaylist
{
    if (self.playlistCellDelegate && [self.playlistCellDelegate respondsToSelector:@selector(didRemovePlaylist:)]) {
        [self.playlistCellDelegate didRemovePlaylist:self.playlist];
    }
}

- (void)markPrivate
{
    if (self.playlistCellDelegate && [self.playlistCellDelegate respondsToSelector:@selector(didMarkPrivate:)]) {
        [self.playlistCellDelegate didMarkPrivate:self.playlist];
    }
}

@end
