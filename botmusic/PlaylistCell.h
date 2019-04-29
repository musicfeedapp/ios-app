//
//  PlaylistCell.h
//  botmusic
//
//  Created by Panda Systems on 1/23/15.
//
//

#import <UIKit/UIKit.h>

#import "MGSwipeTableCell.h"

@class MFPlaylistItem;

@protocol PlaylistCellDelegate <NSObject>

- (void)didRemovePlaylist:(MFPlaylistItem *)playlist;
- (void)didMarkPrivate:(MFPlaylistItem *)playlist;

@end

@interface PlaylistCell : MGSwipeTableCell

@property (nonatomic, weak) id<PlaylistCellDelegate> playlistCellDelegate;

@property (nonatomic, weak) IBOutlet UIView *separatorView;
@property (nonatomic, weak) IBOutlet UIImageView *playlistImageView;
@property (nonatomic, weak) IBOutlet UILabel *playlistNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *tracksLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numberOfTracksLeftConstraint;
@property (weak, nonatomic) IBOutlet UIView *lockedPlaylistIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstrain;

@property (nonatomic, strong) MFPlaylistItem *playlist;

@property (nonatomic, assign) BOOL canRemove;
- (void)setUpNextPlaylist;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playlistNameLeading;
@property (weak, nonatomic) IBOutlet UILabel *hearticon;

@end
