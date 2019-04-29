//
//  PlaylistResultsTableCell.h
//  botmusic
//
//  Created by Panda Systems on 2/4/15.
//
//

#import <UIKit/UIKit.h>

@class MFPlaylistItem;

@interface PlaylistResultsTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *playlistImageView;
@property (nonatomic, weak) IBOutlet UILabel *playlistNameLabel;
@property (nonatomic, weak) IBOutlet UIView *tracksView;
@property (nonatomic, weak) IBOutlet UILabel *tracksLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;

- (void)setInfo:(MFPlaylistItem *)playlistItem;

@end
