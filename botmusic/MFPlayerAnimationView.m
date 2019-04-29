//
//  MFPlayerAnimationView.m
//  botmusic
//
//  Created by Panda Systems on 12/16/15.
//
//

#import "MFPlayerAnimationView.h"

@interface MFPlayerAnimationView ()

@property (nonatomic, strong) NSArray* barTopLeftCornerCoordinates;
@property (nonatomic, strong) CADisplayLink* displayLink;
@property (nonatomic, strong) UIColor* color;
@end

@implementation MFPlayerAnimationView{
    CGFloat _animationTime;
    CGFloat _maxHeight;
    CGFloat _barWidth;
    CGFloat _spaceWidth;
    CGFloat roundScale;
    CGFloat _previousFrameTimestamp;
}

+(MFPlayerAnimationView*)playerAnimationViewWithFrame:(CGRect)frame color:(UIColor*)color{
    return [[MFPlayerAnimationView alloc] initWithFrame:frame color:color];
}

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color
{
    self = [self initWithFrame:frame];
    if (self) {
        self.color = color;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        CGFloat width = frame.size.width;
        CGFloat heigth = width*5.0/4.0;
        if (heigth>frame.size.height) {
            width = width*frame.size.height/heigth;
            heigth = frame.size.height;
        }
        roundScale = [UIScreen mainScreen].scale;
        _barWidth = width/16.0;
        _spaceWidth = (width - 6*_barWidth)/5.0;
        _barWidth = ceil(_barWidth*roundScale)/roundScale;
        _spaceWidth = floor(_spaceWidth*roundScale)/roundScale;
        NSMutableArray* barTopLeftCornerCoordinates = [NSMutableArray array];

        CGFloat offsetX = round((frame.size.width - width)/2.0*roundScale)/roundScale;
        CGFloat offsetY = round((frame.size.height - heigth)/2.0*roundScale)/roundScale;

        for (int i = 0; i < 6; i++) {
            [barTopLeftCornerCoordinates addObject:[NSValue valueWithCGPoint:CGPointMake(offsetX + i*(_spaceWidth+_barWidth), offsetY)]];
        }
        _maxHeight = round(heigth*roundScale)/roundScale;
        self.barTopLeftCornerCoordinates = [barTopLeftCornerCoordinates copy];
        [self updateAnimation];
    }
    return self;
}

- (void)updateAnimation{
    _animationTime +=_displayLink.duration;
    [self setNeedsDisplay];
}

- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if (hidden) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)startAnimating{
    if (!self.isAnimating) {
        [self scheduleTimer];
    }
}

- (BOOL)isAnimating{
    return self.displayLink;
}

- (void)stopAnimating{
    if (self.isAnimating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)scheduleTimer{
    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimation)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    [_color setFill];
    for (int i = 0; i < 6; i++) {
        CGFloat phase = 0.0;
        if (i!=0) {
            phase = 2.0*M_PI*(0.1 - 0.2*i);
        }
        CGPoint point = [_barTopLeftCornerCoordinates[i] CGPointValue];
        CGFloat height = _maxHeight*(0.2+0.35*(1.0+cos(5.0*_animationTime + phase))/2.0 + 0.45*(1.0+cos(10.0*_animationTime + 2.0*phase - 0.5))/2.0);
        height = round(height*roundScale)/roundScale;
        CGContextFillRect(context, CGRectMake(point.x, point.y + (_maxHeight - height), _barWidth, height));
    }

}


@end
