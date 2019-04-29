//
//  ActionView.m
//  botmusic
//
//  Created by Supervisor on 19.06.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "ActionView.h"
#import "MFPlayerAnimationView.h"

static CGFloat const ACTION_ANIMATION_DURATION = 0.8f;

static UIImage* PLAY;
static UIImage* PAUSE;
//static UIImage* PLAYING;

@interface ActionView() {
    BOOL _animated;
    BOOL _animating;
}

@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UIImageView *disappearImage;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *disappearImageHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *disappearImageWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeadingSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIView *playingIndicatorContainer;
@property (strong, nonatomic) MFPlayerAnimationView* playingIndicator;
@property (nonatomic, strong) NSString *currentImageName;

@end

@implementation ActionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (!PLAY) {
        PLAY = [UIImage imageNamed:@"Play.png"];
        PAUSE = [UIImage imageNamed:@"Pause.png"];
        //PLAYING = [UIImage imageNamed:@"newPlay.png"];
    }
    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.playingIndicator) {
        self.playingIndicator = [MFPlayerAnimationView playerAnimationViewWithFrame:self.playingIndicatorContainer.bounds color:[UIColor whiteColor]];
        [self.playingIndicatorContainer addSubview:self.playingIndicator];
        self.playingIndicator.hidden = YES;
    }
}

#pragma mark - Properties

- (BOOL)isAnimated {
    return _animated;
}

- (BOOL)isAnimating {
    return _animating;
}

- (void)setActionImage:(UIImage *)image {
    [_image setImage:image];
    [_disappearImage setImage:image];
}

#pragma mark - Animations

- (void)makeAppearAnimationWithCompletion:(void (^)(BOOL finished))completion {
    _image.hidden = NO;
    _disappearImage.hidden = NO;
    _image.alpha = 0.0f;
    _disappearImage.alpha = 0.0f;
    
    _disappearImageHeightConstraint.constant = 60.0f;
    _disappearImageWidthConstraint.constant = 60.0f;
    
    [UIView animateWithDuration:0.0001f animations:^{
        _image.alpha = 1.0f;
        _disappearImage.alpha = 1.0f;
        
        [self layoutIfNeeded];
    }];
    
    _animating = YES;
    [self animationWillStart];
    
    _disappearImageHeightConstraint.constant = 100.0f;
    _disappearImageWidthConstraint.constant = 100.0f;
    
    [UIView animateWithDuration:ACTION_ANIMATION_DURATION animations:^{
        _disappearImage.alpha = 0.0f;

        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        _animated = YES;
        _animating = NO;
        [self animationDidFinish];
        completion(finished);
    }];
}

- (void)makeDisappearAnimationWithCompletion:(void (^)(BOOL finished))completion {
    _animating = YES;
    [self animationWillStart];
    
    [UIView animateWithDuration:ACTION_ANIMATION_DURATION/2 animations:^{
        _image.alpha = 0.0f;
    } completion:^(BOOL finished) {
//        _image.hidden = YES;
//        _disappearImage.hidden = YES;

        _animated = NO;
        _animating = NO;
        [self animationDidFinish];
        completion(finished);
    }];
}

#pragma mark - Notify Delegate methods

- (void)animationWillStart {
    if (_delegate && [_delegate respondsToSelector:@selector(actionAnimationWillStart)]) {
        [_delegate actionAnimationWillStart];
    }
}

- (void)animationDidFinish {
    if (_delegate && [_delegate respondsToSelector:@selector(actionAnimationDidFinish)]) {
        [_delegate actionAnimationDidFinish];
    }
}

#pragma mark - Public methods

- (void)makeNextAnimation {
    [self.largeActivityIndicator stopAnimating];
    //[self makeAnimationWithImageName:@"Pause.png"];
    [self makeForcedAnimationWithImageName:@"playback-fast-forward.png"];
}

- (void)makePrevAnimation {
    [self.largeActivityIndicator stopAnimating];
    //[self makeAnimationWithImageName:@"Pause.png"];
    [self makeForcedAnimationWithImageName:@"playback-fast-back.png"];
}

- (void)makePlayAnimation {
    [self makePlayAnimationForced:NO];
}

- (void)makePlayAnimationForced:(BOOL)forced {
    [self.largeActivityIndicator stopAnimating];
    //[self makeAnimationWithImageName:@"Pause.png"];
    if (forced) {
        [self makeForcedAnimationWithImageName:@"newPlay.png"];
    } else {
        [self makeAnimationWithImageName:@"newPlay.png"];
    }
}

- (void)makeLoadingAnimation{
    [self.largeActivityIndicator startAnimating];
}

- (void)makePauseAnimation {
    [self makePauseAnimationForced:NO];
}

- (void)makePauseAnimationForced:(BOOL)forced {
    [self.largeActivityIndicator stopAnimating];
    if (forced) {
        [self makeForcedAnimationWithImageName:@"Pause.png"];
    } else {
        [self makeAnimationWithImageName:@"Pause.png"];
    }
    
    //[self makeAnimationWithImageName:@"Play.png"];
}

- (void)finishAllAnimations {
    if (self.isAnimated && !self.isAnimating) {
        [self makeDisappearAnimationWithCompletion:^(BOOL finished) {
            
        }];
    } else {
        [self hideAllButtons];
    }
    [self.largeActivityIndicator stopAnimating];

}

- (void)showPlayingButton {
    _contentViewLeadingSpaceConstraint.constant = 0.0f;
    [self layoutIfNeeded];

    _currentImageName = @"newPlay.png";
    //[self setActionImage:PLAYING];
    [self.largeActivityIndicator stopAnimating];
    _playingIndicator.hidden = NO;
    [_playingIndicator startAnimating];
    _image.hidden = YES;
    _disappearImage.hidden = YES;
    _image.alpha = 1.0f;
    _disappearImage.alpha = 0.0f;

    _animated = YES;
}

- (void)showPlayButton {
    _contentViewLeadingSpaceConstraint.constant = 2.0f;

    _currentImageName = @"Play.png";
    [self setActionImage:PLAY];
    [self.largeActivityIndicator stopAnimating];
    _playingIndicator.hidden = YES;
    _image.hidden = NO;
    _disappearImage.hidden = NO;
    _image.alpha = 1.0f;
    _disappearImage.alpha = 0.0f;
    
    _animated = YES;
}

- (void)showPauseButton {
    _contentViewLeadingSpaceConstraint.constant = 0.0f;
    [self layoutIfNeeded];
    
    _currentImageName = @"Pause.png";
    //[self setActionImage:PAUSE];
    [self.largeActivityIndicator stopAnimating];
    _playingIndicator.hidden = NO;
    [_playingIndicator stopAnimating];

    _image.hidden = YES;
    _disappearImage.hidden = YES;
    _image.alpha = 1.0f;
    _disappearImage.alpha = 0.0f;

    _animated = YES;
}

- (void)hideAllButtons {
    _playingIndicator.hidden = YES;
    _image.alpha = 0.0f;

    _image.hidden = YES;
    _disappearImage.hidden = YES;

    _animated = NO;
}

#pragma mark - Prepare to animations

- (void)makeAnimationWithImageName:(NSString *)imageName {
    if (!self.isAnimated && !self.isAnimating) {
        if ([imageName isEqualToString:@"Play.png"]) {
            _contentViewLeadingSpaceConstraint.constant = 2.0f;
        } else {
            _contentViewLeadingSpaceConstraint.constant = 0.0f;
        }
        [self layoutIfNeeded];
        
        _currentImageName = imageName;
        [self setActionImage:[UIImage imageNamed:imageName]];
        [self makeAppearAnimationWithCompletion:^(BOOL finished) {
            
        }];
    } else if (!self.isAnimating && ![_currentImageName isEqualToString:imageName]) {
        [self makeDisappearAnimationWithCompletion:^(BOOL finished) {
            if ([imageName isEqualToString:@"Play.png"]) {
                _contentViewLeadingSpaceConstraint.constant = 2.0f;
            } else {
                _contentViewLeadingSpaceConstraint.constant = 0.0f;
            }
            [self layoutIfNeeded];
            
            _currentImageName = imageName;
            [self setActionImage:[UIImage imageNamed:imageName]];
            [self makeAppearAnimationWithCompletion:^(BOOL finished) {
                
            }];
        }];
    }
}

- (void) makeForcedAnimationWithImageName:(NSString *)imageName {
    //_currentImageName = imageName;
    //[self setActionImage:[UIImage imageNamed:imageName]];
    [_disappearImage setImage:[UIImage imageNamed:imageName]];
    if ([imageName isEqualToString:@"Play.png"]) {
        _contentViewLeadingSpaceConstraint.constant = 2.0f;
    } else {
        _contentViewLeadingSpaceConstraint.constant = 0.0f;
    }
    [self layoutIfNeeded];
    [self makeAppearAnimationWithCompletion:^(BOOL finished) {
        [self setActionImage:nil];
    }];
}

- (void)dealloc
{
    [self.playingIndicator stopAnimating];
}
@end
