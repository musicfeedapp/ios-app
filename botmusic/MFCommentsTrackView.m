//
//  MFCommentsTrackView.m
//  botmusic
//

#import "MFCommentsTrackView.h"
#import "UIImage+Resize.h"
#import "MFTrackItem+Behavior.h"
#import "UIImageView+WebCache_FadeIn.h"

@interface MFCommentsTrackView ()

@property (nonatomic, weak) IBOutlet UIImageView *trackImageView;
@property (nonatomic, weak) IBOutlet UIView *trackNameView;
@property (nonatomic, weak) IBOutlet UILabel *trackNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;

// Constraints
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trackNameLabelTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trackNameLabelHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trackNameLabelWidthConstraint;

@end

@implementation MFCommentsTrackView

- (void)setTrackInfo:(MFTrackItem *)trackItem {
    [self setTrackImage:trackItem.trackPicture];
    [self setTrackName:trackItem.trackName];
    [self.durationLabel setText:trackItem.authorName];
}

- (void)setTrackImage:(NSString *)imageURLString {
    NSURL* imageURL = [NSURL URLWithString:imageURLString];
    if (imageURL) {
//        [[MFAppImageManager sharedManager] startImageDowloadingForUrl:imageURL preprocessType:MFAppManagerImagePreprocessTypeCell];
//        [self.trackImageView sd_setImageAndFadeOutWithURL:imageURL placeholderImage:[UIImage imageNamed:@"DefaultArtwork"]];
        
        [self.trackImageView setImage:[UIImage imageNamed:@"DefaultArtwork"]];
        [self.trackImageView sd_setImageAndFadeOutWithURL:imageURL
                                             placeholderImage:[UIImage imageNamed:@"DefaultArtwork"]];
    }
}

- (void)setTrackName:(NSString *)trackName {
    self.trackNameLabel.text = trackName;
    
    [self.trackNameLabel sizeToFit];
    
    self.trackNameLabelTopConstraint.constant = (self.trackNameView.frame.size.height - self.trackNameLabel.frame.size.height - CGRectGetHeight(self.durationLabel.frame))/2;
    self.trackNameLabelHeightConstraint.constant = self.trackNameLabel.frame.size.height;
    
    [self layoutIfNeeded];
}

@end
