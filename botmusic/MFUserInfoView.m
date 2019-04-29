//
//  MFUserInfoView.m
//  botmusic
//
//  Created by navakdzmitry on 1/26/15.
//
//

#import "CustomAKSegmentControl.h"
#import "MFUserInfoView.h"
#import "BaseButton.h"
#import <UIColor+Expanded.h>
#import "UIImage+ImageWithColor.h"
#import "UIImage+GPUBlur.h"
#import "UIImageView+WebCache_FadeIn.h"


@interface MFUserInfoView ()

@property (nonatomic, weak) IBOutlet UIImageView* smallProfilePicture;
@property (nonatomic, weak) IBOutlet UILabel* checkmark;
@property (nonatomic, weak) IBOutlet UILabel* profileName;
@property (nonatomic, weak) IBOutlet UILabel* smallProfileName;
@property (nonatomic, weak) IBOutlet UIView* resizableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel* profileInitialsLabel;
@property (weak, nonatomic) IBOutlet UILabel* smallProfileInitialsLabel;
@end

@implementation MFUserInfoView

#pragma mark - dynamic relayout

- (void)roundProfileImage
{
    _profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
    _profileInitialsLabel.layer.cornerRadius = self.profileInitialsLabel.frame.size.width / 2;
    _profilePicture.clipsToBounds=YES;
    _smallProfilePicture.layer.cornerRadius = self.smallProfilePicture.frame.size.width / 2;
    _smallProfileInitialsLabel.layer.cornerRadius = self.smallProfileInitialsLabel.frame.size.width / 2;
    _smallProfilePicture.clipsToBounds=YES;
}

# pragma mark - public API

- (void)animateSmallUserView:(BOOL)bigger {
    if(!bigger){
        
        _smallProfilePicture.alpha = 1.0;
        _smallProfileName.alpha = 1.0;
        
    } else {
        
        _smallProfilePicture.alpha = 0.0;
        _smallProfileName.alpha = 0.0;
        
    }
}

- (void)animate:(CGFloat)phase{
    
    _profileName.alpha = 1.0 - (0.85-phase)*7.0;
    _checkmark.alpha = 1.0 - (0.85-phase)*7.0;
    _profilePicture.alpha = 1.0 - (0.6-phase)*10.0;
    _profileInitialsLabel.alpha = 1.0 - (0.6-phase)*10.0;
    _smallProfilePicture.alpha = 1.0 - _profilePicture.alpha;
    _smallProfileName.alpha = 1.0 - _profilePicture.alpha;
    _smallProfileInitialsLabel.alpha = 1.0 - _profilePicture.alpha;


}

- (void)animateBigUserView:(BOOL)bigger {
    if(bigger){
        _profilePicture.alpha = 1.0;
        _profileName.alpha = 1.0;
        _checkmark.alpha = 1.0;
    } else {
        _profilePicture.alpha = 0.0;
        _profileName.alpha = 0.0;
        _checkmark.alpha = 0.0;
    }
}

- (void)setProfileImage:(NSURL*)imageUrl
{
    void(^imageCompletion)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
        
        UIImage* imageBlurred = [image gpuBlurApplyProfileEffect];
        if (imageBlurred) {
            _profileBackground.image = imageBlurred;
        }
        _smallProfilePicture.image = image;
        [self roundProfileImage];
    };
    //NSLog(imageUrl.path);
    [_profilePicture sd_setImageAndFadeOutWithURL:imageUrl
                       placeholderImage:[UIImage imageNamed:@"defaultAvatar.jpg"]
                                                completed:imageCompletion];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnProfilePicture:)];
    [_profilePicture addGestureRecognizer:tapRecognizer];
}

- (void)setHeaderTitle:(NSString*)title
{
    _profileName.text = title;
    _smallProfileName.text = title;
    [_smallProfileName sizeToFit];
    
    [self setNeedsLayout];
}

- (void)showCheckmark:(BOOL)show
{
    _checkmark.hidden = !show;
    self.checkMarkWidthConstraint.constant = show? 21 : 0;
}



#pragma mark - Actions


- (void)didTapOnProfilePicture:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapProfilePicture)]) {
        [_delegate didTapProfilePicture];
    }
}

@end
