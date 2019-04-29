//
//  PlaylistResultsTableCell.m
//  botmusic
//
//  Created by Panda Systems on 2/4/15.
//
//

#import "PlaylistResultsTableCell.h"
#import "MFPlaylistItem+Behavior.h"
#import "UIImageView+WebCache_FadeIn.h"

@implementation PlaylistResultsTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setup

- (void)setInfo:(MFPlaylistItem *)playlistItem
{
    if (playlistItem) {
        [self.playlistNameLabel setText:playlistItem.title];
        [self.playlistImageView setImage:nil];
        [self.playlistImageView sd_setImageAndFadeOutWithURL:nil
                                                placeholderImage:[UIImage imageNamed:@"NoImage"]];
        
        [self.tracksLabel setText:[NSString stringWithFormat:@"%d", [playlistItem.tracksCount intValue]]];
        
        [self updateFrames];
    }
}

- (void)updateFrames
{
    [self.durationLabel sizeToFit];
    CGRect labelFrame = self.durationLabel.frame;
    labelFrame.size.height = 15.0f;
    self.durationLabel.frame = labelFrame;
    
    CGRect tracksFrame = self.tracksView.frame;
    tracksFrame.origin.x = labelFrame.origin.x + labelFrame.size.width + (labelFrame.size.width > 0 ? 5.0f : 0.0f);
    self.tracksView.frame = tracksFrame;
}

@end
