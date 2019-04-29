//
//  ActionView.h
//  botmusic
//
//  Created by Supervisor on 19.06.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat const ACTION_VIEW_WIDTH=100.0f;

@protocol ActionViewDelegate <NSObject>

@optional
- (void)actionAnimationWillStart;
- (void)actionAnimationDidFinish;
@end

@interface ActionView : UIView

@property (nonatomic, weak) id<ActionViewDelegate> delegate;
@property (nonatomic, readonly, getter=isAnimated) BOOL animated;
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *largeActivityIndicator;

- (void)makePlayAnimation;
- (void)makePauseAnimation;
- (void)makeLoadingAnimation;
- (void)finishAllAnimations;
- (void)makeNextAnimation;
- (void)makePrevAnimation;
- (void)makePauseAnimationForced:(BOOL)forced;
- (void)makePlayAnimationForced:(BOOL)forced;

- (void)showPlayButton;
- (void)showPauseButton;
- (void)showPlayingButton;
- (void)hideAllButtons;

@end
