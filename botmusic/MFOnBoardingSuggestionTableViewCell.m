//
//  MFOnBoardingSuggestionTableViewCell.m
//  botmusic
//
//  Created by Panda Systems on 8/26/15.
//
//

#import "MFOnBoardingSuggestionTableViewCell.h"
#import "UIImageView+WebCache_FadeIn.h"

@implementation MFOnBoardingSuggestionTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.separatorHeight.constant = 1.0/[UIScreen mainScreen].scale;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.height/2.0;
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAtAvatar)]];
    [self.unfollowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unfollowViewTapped) ]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSuggestionInfo:(MFSuggestion*)suggestion{
    self.suggestion = suggestion;
    [self.avatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:suggestion.avatar_url] name:suggestion.name cropRoundedImage:YES];
//    [self.avatarImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:suggestion.avatar_url]
//                            placeholderImage:nil
//                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//                                       self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.height/2.0;
//                                       
//                                   }];

    [self.nameLabel setText:suggestion.name];
    [self.nickLabel setText:suggestion.username];
    [self.followedMark setHidden:!suggestion.is_followed];
    [self.unfollowView setHidden:!suggestion.is_followed];
    self.followButton.hidden = !self.followedMark.hidden;

//    NSMutableString* commonFollowers = [NSMutableString string];
//    NSUInteger number = 0;

//    for (MFFollowItem* followItem in suggestion.commonFollowers) {
//        if (commonFollowers.length) {
//            [commonFollowers appendString:@", "];
//        }
//        [commonFollowers appendString:[followItem name]];
//        number++;
//        if (number==3) {
//            break;
//        }
//    }
//    [commonFollowers appendString:@" "];
//
//    if (suggestion.commonFollowers.count>number) {
//        [commonFollowers appendString: [NSString stringWithFormat:NSLocalizedString(@"and %lu others ", nil), suggestion.commonFollowers.count - number]];
//    }
//    _commonFollowersLabel.text = commonFollowers;
//    if (number==0) {
//        _commonFollowersLabel.hidden = YES;
//    } else {
//        _commonFollowersLabel.hidden = NO;
//    }
}

- (void) setSearchResultInfo:(IRSuggestion*)suggestion {
    _suggestion = suggestion;
    [self.avatarImageView sd_setAvatarWithUrl:[NSURL URLWithString:suggestion.avatar_url] name:suggestion.name cropRoundedImage:YES];

//    [self.avatarImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:suggestion.avatar_url]
//                            placeholderImage:nil
//                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//                                       self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.height/2.0;
//
//                                   }];
    [self.nameLabel setText:suggestion.name];
    [self.nickLabel setText:suggestion.username];
//    [self.followedMark setHidden:!suggestion.is_followed];
    self.followButton.hidden = !self.followedMark.hidden;

//    _commonFollowersLabel.hidden = YES;

}

- (IBAction)followButtonTapped:(id)sender {
    [self.delegate shouldFollow:self];
}

- (void) unfollowViewTapped{
    [self.delegate shouldUnFollow:self];
}

- (void) didTapAtAvatar{
    [self.delegate shouldOpenProfile:self];
}
@end
