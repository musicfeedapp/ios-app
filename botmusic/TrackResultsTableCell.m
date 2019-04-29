//
//  TrackResultsTableCell.m
//  botmusic
//
//  Created by Panda Systems on 2/3/15.
//
//

#import "TrackResultsTableCell.h"
#import "MFTrackItem+Behavior.h"
#import <UIColor+Expanded.h>
#import "UIImageView+WebCache_FadeIn.h"

@implementation TrackResultsTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setup

- (void)setInfo:(MFTrackItem *)trackItem
{
    if (trackItem) {
        _track = trackItem;
        
        [self.trackNameLabel setText:trackItem.trackName];
        [self.trackImageView setImage:nil];
        [self.trackImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:trackItem.trackPicture]
                                             placeholderImage:[UIImage imageNamed:@"NoImage"]];
        
        [self.commentsLabel setText:[NSString stringWithFormat:@"%d", [trackItem.comments intValue]]];
        [self.likesButton setSelected:trackItem.isLiked];
        [self.likesLabel setText:[NSString stringWithFormat:@"%d", [trackItem.likes intValue]]];
        [self.authorLabel setText:trackItem.authorName];
        if (trackItem.authorName && ![trackItem.authorName isEqualToString:@""]) {
            [self.authorLabel setText:trackItem.authorName];
        } else {
            if ([trackItem.type isEqualToString:@"youtube"]) {
                [self.authorLabel setText:@"Youtube"];
            } else if ([trackItem.type isEqualToString:@"soundcloud"]){
                [self.authorLabel setText:@"Soundcloud"];
            } else {
                [self.authorLabel setText:@"Other"];
            }
        }
    }
}

#pragma mark - Button Touches

- (IBAction)didTouchUpCommentsButton:(id)sender
{
    if (self.trackResultsCellDelegate && [self.trackResultsCellDelegate respondsToSelector:@selector(shouldShowComments:)]) {
        [self.trackResultsCellDelegate shouldShowComments:self.track];
    }
}

- (IBAction)didTouchUpLikesButton:(id)sender
{
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (!(networkStatus == NotReachable)) {
        if ([self.likesButton.titleLabel.text isEqualToString:[NSString stringWithUTF8String:"\uF130"]]) {
            [self.likesButton setTitle:[NSString stringWithUTF8String:"\uF140"] forState:UIControlStateNormal];
            [self.likesButton setTitleColor:[UIColor colorWithRGBHex:kLovedColor] forState:UIControlStateNormal];
            [self.track likeTrackItem];
            [self setInfo:self.track];
            if (self.trackResultsCellDelegate && [self.trackResultsCellDelegate respondsToSelector:@selector(didLikeTrack:)]) {
                [self.trackResultsCellDelegate didLikeTrack:self.track];
            }
        }
        else {
            [self.likesButton setTitle:[NSString stringWithUTF8String:"\uF130"] forState:UIControlStateNormal];
            [self.likesButton setTitleColor:[UIColor colorWithRGBHex:kLightColor] forState:UIControlStateNormal];
            [self.track dislikeTrackItem];
            [self setInfo:self.track];
            if (self.trackResultsCellDelegate && [self.trackResultsCellDelegate respondsToSelector:@selector(didUnlikeTrack:)]) {
                [self.trackResultsCellDelegate didUnlikeTrack:self.track];
            }
        }
    }
}

- (IBAction)didTouchUpShowTrackInfoButton:(id)sender
{
    if (self.trackResultsCellDelegate && [self.trackResultsCellDelegate respondsToSelector:@selector(shouldShowTrackInfo:)]) {
        [self.trackResultsCellDelegate shouldShowTrackInfo:self.track];
    }
}

- (IBAction)didTouchUpAddButton:(id)sender
{
    if (self.trackResultsCellDelegate && [self.trackResultsCellDelegate respondsToSelector:@selector(didAddTrackToPlaylist:)]) {
        [self.trackResultsCellDelegate didAddTrackToPlaylist:self.track];
    }
}

@end
