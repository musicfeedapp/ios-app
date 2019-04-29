//
//  NDMusicControl.m
//  PlayButtonExample
//
//  Created by Dzmitry Navak on 07/12/14.
//  Copyright (c) 2014 navakdzmitry. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NDMusicControl.h"
#import "CALayer+NDAnimationPersistence.h"

@interface NDMusicControl ()

@property (nonatomic, strong)   CALayer* playLayer;
@property (nonatomic, strong)   CALayer* animationLayer;
@property (nonatomic, strong)   CAShapeLayer* playTriangleLayer;
@property (nonatomic, strong)   NSArray* barLayers;
@property (nonatomic)           NDMusicConrolStateType prevState;
@property (nonatomic)           NDMusicConrolStateType playState;
@property (nonatomic, strong)   UIActivityIndicatorView* loadIndicator;

@end

@implementation NDMusicControl

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self initSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initSelf];
    }
    return self;
}

- (void)initSelf
{
    _playLayer = [CALayer layer];
    [self.layer addSublayer:_playLayer];
    self.layer.cornerRadius = CGRectGetWidth(self.bounds)/2;
    
    _animationLayer = [CALayer layer];
    [_playLayer addSublayer:_animationLayer];
    
    _mainColor = [UIColor whiteColor];
    
    UITapGestureRecognizer* tapSelf = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelf)];
    [self addGestureRecognizer:tapSelf];
    
    [self setLayerFrames];
    
    _playState = NDMusicConrolStateTypeNotStarted;
    _prevState = NDMusicConrolStateTypeNotStarted;
}

- (void)setLayerFrames
{
    _playLayer.frame = CGRectInset(self.bounds,
                                   self.bounds.size.width/10,
                                   self.bounds.size.height/4);
    
    _animationLayer.frame = _playLayer.bounds;
    
    [self changePlayState:NDMusicConrolStateTypeNotStarted];
    [self displayPlayState];
}

#pragma mark - API

- (void)changePlayState:(NDMusicConrolStateType)stateType
{
    if (_playState != stateType) {
        NSLog(@"Sate type changed %lu", stateType);
        
        self.prevState = _playState;
        self.playState = stateType;
        [self clearState];
        
        switch (stateType) {
            case NDMusicConrolStateTypeNotStarted:
                [self displayPlayState];
                break;
                
            case NDMusicConrolStateTypePaused:
                [self displayPausedState];
                break;
                
            case NDMusicConrolStateTypeLoading:
                [self displayLoadingState];
                break;
                
            case NDMusicConrolStateTypePlaying:
                [self displayPlayingSate];
                break;
                
            case NDMusicConrolStateTypePlayed:
                //TODO add replay artwork
                [self displayPlayState];
                break;
                
            case NDMusicConrolStateTypeFailed:
                //TODO add failed artwork
                [self displayPlayState];
                break;
                
            default:
                break;
        }
    }
}

- (void)clearState
{
    [_loadIndicator stopAnimating];
    if (_playState != NDMusicConrolStateTypeNotStarted) {
        self.playTriangleLayer.hidden = YES;
    }
    if (_playState != NDMusicConrolStateTypePlaying && _playState != NDMusicConrolStateTypePaused) {
        //magic!
        //        for (CALayer* layer in _barLayers) {
        //            [layer ND_resumeLayer];
        //        }
        [self barLayersHidden:YES];
    }
}

#pragma mark - display states

- (void)displayPlayState
{
    if (_playTriangleLayer == nil) {
        _playTriangleLayer = [CAShapeLayer layer];
        _playTriangleLayer.fillColor = _mainColor.CGColor;
        UIBezierPath *triangle = [UIBezierPath bezierPath];
        
        CGFloat minX = (int)(CGRectGetWidth(_playLayer.bounds)*(0.25 + 0.5/6));
        CGFloat minY = 0;
        CGFloat maxX = (int)(CGRectGetWidth(_playLayer.bounds)*(0.75 + 0.5/6));
        CGFloat maxY = CGRectGetMaxY(_playLayer.bounds);
        [triangle moveToPoint:(CGPoint){minX, minY}];
        [triangle addLineToPoint:(CGPoint){minX, maxY}];
        [triangle addLineToPoint:(CGPoint){maxX, (int)(maxY - minY)/2}];
        [triangle closePath];
        _playTriangleLayer.path = triangle.CGPath;
        
        [_playLayer addSublayer:_playTriangleLayer];
    }
    self.playTriangleLayer.hidden = NO;
}

- (void)displayLoadingState
{
    if (_loadIndicator == nil) {
        self.loadIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadIndicator.frame = CGRectMake((int)(CGRectGetWidth(self.bounds) - CGRectGetWidth(_loadIndicator.bounds))/2,
                                          (int)(CGRectGetHeight(self.bounds) - CGRectGetHeight(_loadIndicator.bounds))/2,
                                          CGRectGetWidth(_loadIndicator.bounds),
                                          CGRectGetHeight(_loadIndicator.bounds));
        _loadIndicator.color = [UIColor whiteColor];
        [self addSubview:_loadIndicator];
    }
    
    [_loadIndicator startAnimating];
}

- (void)displayPlayingSate
{
    if (_barLayers == nil) {
        [self initBarLayers];
    }
    
    [self barLayersHidden:NO];
//    for (int i = 0; i < [_barLayers count]; i++) {
//        CALayer*  layer = _barLayers[i];
//        if (layer.ND_persistentAnimationKeys != nil) {
//            [layer ND_resumeLayer];
//        }
//        else {
//            [self addAnimationToBarLayer:_barLayers[i] atPosition:i];
//            [_barLayers[i] ND_setCurrentAnimationsPersistent];
//        }
//        
//    }
}

- (void)displayPausedState
{
    self.playTriangleLayer.hidden = NO;
    [self barLayersHidden:YES];
//    if (_barLayers == nil) {
//        [self initBarLayers];
//        //pause just created animation
//        for (CALayer* layer in _barLayers) {
//            [layer ND_pauseLayer];
//        }
//    }
//    for (CALayer* layer in _barLayers) {
//        if ([layer animationForKey:@"basic"] != nil) {
//            [layer ND_pauseLayer];
//        }
//    }
}

- (void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

- (void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

#pragma mark - Playing drawing and animation

- (void)initBarLayers
{
    NSMutableArray* tempBarLayers = [NSMutableArray array];
    for (int i = 0; i < 2; i++) {
        CALayer* barLayer = [CALayer layer];
        barLayer.anchorPoint = CGPointMake(0, 1);
        barLayer.backgroundColor = _mainColor.CGColor;
        [_animationLayer addSublayer:barLayer];
        barLayer.frame = [self frameForBarRectAtPosition:i];
//        [self addAnimationToBarLayer:barLayer atPosition:i];
//        [barLayer ND_setCurrentAnimationsPersistent];
        [tempBarLayers addObject:barLayer];
    }
    _barLayers = [NSArray arrayWithArray:tempBarLayers];
}

- (void)barLayersHidden:(BOOL)hidden
{
    _animationLayer.hidden = hidden;
}

- (CGRect)frameForBarRectAtPosition:(NSInteger)position
{
    CGFloat barWidth = 2.0*_playLayer.bounds.size.width/10;
    return CGRectMake(barWidth*position*1.5 + (_playLayer.bounds.size.width - 2.5*barWidth)/2,
                      0,
                      barWidth,
                      CGRectGetHeight(_playLayer.bounds));
}

- (void)addAnimationToBarLayer:(CALayer*)barLayer
                    atPosition:(NSInteger)position
{
    //clear layer animations
    [barLayer removeAllAnimations];
    
    //setup animation
    CABasicAnimation *animation = [CABasicAnimation animation];
    CGFloat minHeight = _playLayer.bounds.size.height/5 + (NSInteger)arc4random_uniform(4) - 2;
    CGFloat maxHeight = CGRectGetHeight(_playLayer.bounds) - ((NSInteger)arc4random_uniform(4) - 1)*minHeight/2;
    CGFloat barMaxHeight = maxHeight;
    
    animation.keyPath = @"bounds.size.height";
    CGFloat fromP = minHeight + (position%2)*(barMaxHeight - minHeight);
    CGFloat toP = minHeight + ((position+1)%2)*(barMaxHeight - minHeight);
    animation.fromValue = @(fromP);
    animation.toValue = @(toP);
    
    //set some variation to animation time
    CGFloat durationVariation = ((NSInteger)arc4random_uniform(3) - 1)*0.1;
    animation.duration = 0.5 + durationVariation;
    animation.repeatCount = HUGE_VALF;
    animation.autoreverses = YES;
    
    [barLayer addAnimation:animation forKey:@"basic"];
}

#pragma mark - detecting touches
- (void)tapSelf
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
