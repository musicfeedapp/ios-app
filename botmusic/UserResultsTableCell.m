//
//  UserResultsTableCell.m
//  botmusic
//
//  Created by Panda Systems on 1/22/15.
//
//

#import "UserResultsTableCell.h"
#import "IRSuggestion.h"
#import <UIColor+Expanded.h>
#import "UIImageView+WebCache_FadeIn.h"
@implementation UserResultsTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Button Touches

- (IBAction)didTouchUpFollowButton:(id)sender
{
    [_followButton setSelected:!_followButton.isSelected];
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeFollowing:)]) {
        [_delegate didChangeFollowing:_suggestion];
    }
}


#pragma mark - Helpers

- (void)setInfo:(IRSuggestion*)suggestion
{
    _suggestion = suggestion;
    
    if (suggestion) {
        [self.usernameLabel setText:suggestion.name];
        self.tracksLabel.text = [NSString stringWithFormat:@"%@", suggestion.tracks_count];
        [self.verifiedMarkLabel setHidden:!suggestion.is_verified];
        [self.followButton setSelected:suggestion.is_followed];
        [self.userImageView setImage:nil];
        [self.userImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:suggestion.avatar_url]
                                            placeholderImage:[UIImage imageNamed:@"NoImage.png"]];
        
        [self updateFrames];
    }
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.clipsToBounds = YES;
}

- (void)updateFrames
{
    [self.usernameLabel sizeToFit];
    //CGRect labelFrame = self.usernameLabel.frame;
    //labelFrame.size.height = 20.0f;
    //self.usernameLabel.frame = labelFrame;
    
    //CGRect markFrame = self.verifiedMarkLabel.frame;
    //markFrame.origin.x = labelFrame.origin.x + labelFrame.size.width + 5.0f;
    //self.verifiedMarkLabel.frame = markFrame;
    [self layoutIfNeeded];
}

@end
