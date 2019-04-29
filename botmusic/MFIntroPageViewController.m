//
//  MFIntroPageViewController.m
//  botmusic
//
//  Created by Panda Systems on 8/10/15.
//
//

#import "MFIntroPageViewController.h"
#import "UIColor+Expanded.h"
#import <UIImage+SVG/UIImage+SVG.h>


@interface MFIntroPageViewController ()
@property(nonatomic) CGRect screen;
@property(nonatomic, strong) CALayer* animationLayer;
@property(nonatomic, strong) CALayer* screenLayer;
@property(nonatomic, strong) CALayer* player;
@property(nonatomic, strong) NSMutableArray* feeds;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic) int currentColor;
@end

@implementation MFIntroPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feeds = [NSMutableArray array];
    self.screen = [UIScreen mainScreen].bounds;
    // Do any additional setup after loading the view.
    [self addPhoneLayer];
    //self.view.backgroundColor = [UIColor colorWithRGBHex:kFaintColor];
    [self setupFeed];
    if (self.number == 0) {
        [self action1screen];
        self.actionTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(action1screen) userInfo:nil repeats:YES];
        self.textLabel.text = NSLocalizedString(@"Keep track of your friends and favorite artists' music posts", nil);
    }
    if (self.number == 1) {
        [self action2screen];
        self.actionTimer = [NSTimer scheduledTimerWithTimeInterval:6.5 target:self selector:@selector(action2screen) userInfo:nil repeats:YES];
        self.textLabel.text = NSLocalizedString(@"Listen to tracks and watch videos directly in your feed", nil);
    }
    if (self.number == 2) {
        [self action3screen];
        self.actionTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(action3screen) userInfo:nil repeats:YES];
        self.textLabel.text = NSLocalizedString(@"Heart your biggest faves and share your love for the music", nil);
    }
    if (self.number == 3) {
        [self preparefor4screen];
        [self action4screen];
        self.actionTimer = [NSTimer scheduledTimerWithTimeInterval:3.2 target:self selector:@selector(action4screen) userInfo:nil repeats:YES];
        self.textLabel.text = NSLocalizedString(@"Remove tracks you dont like so musicfeed can learn your preferences", nil);
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    }
   
}

- (void)setupFeed{
    for (int i = 0; i<6; i++) {
        CGRect frame = CGRectMake(self.animationLayer.bounds.size.width*0.03, 0.0+i*self.animationLayer.bounds.size.width/300.0*230.0, self.animationLayer.bounds.size.width*0.94, self.animationLayer.bounds.size.width/300.0*230.0);
        CALayer* layer = [self makeFeedTrackLayerWithFrame:frame];
        [self.animationLayer addSublayer:layer];
        [self.feeds addObject:layer];
    }
}

- (void)configurePlayerView{
    CALayer* smallPlayer = [[CALayer alloc] init];
    smallPlayer.frame = CGRectMake(0.0, 0.0, self.player.frame.size.width, self.player.frame.size.height/8.0);
    
    [self.player addSublayer:smallPlayer];
    
    CALayer* progress2 = [[CALayer alloc] init];
    progress2.backgroundColor = [UIColor colorWithRGBHex:0xff0038].CGColor;
    progress2.frame = CGRectMake(-smallPlayer.frame.size.width, 0.0, smallPlayer.frame.size.width, smallPlayer.frame.size.height);
    [smallPlayer addSublayer:progress2];
    
    CALayer* pause1 = [[CALayer alloc] init];
    pause1.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    pause1.frame = CGRectMake(smallPlayer.frame.size.height/3.0, smallPlayer.frame.size.height/3.0, smallPlayer.frame.size.height/12.0, smallPlayer.frame.size.height/3.0);
    
    CALayer* pause2 = [[CALayer alloc] init];
    pause2.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    pause2.frame = CGRectMake(smallPlayer.frame.size.height/3.0 + smallPlayer.frame.size.height*2.0/12.0, smallPlayer.frame.size.height/3.0, smallPlayer.frame.size.height/12.0, smallPlayer.frame.size.height/3.0);
    [smallPlayer addSublayer:pause1];
    [smallPlayer addSublayer:pause2];
    
    CALayer* line1 = [[CALayer alloc] init];
    line1.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    line1.frame = CGRectMake(smallPlayer.frame.size.width/4.8, smallPlayer.frame.size.height*4.0/13.0, smallPlayer.frame.size.width/2.0, smallPlayer.frame.size.height*2.0/13.0);
    
    CALayer* line2 = [[CALayer alloc] init];
    line2.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    line2.frame = CGRectMake(smallPlayer.frame.size.width/4.8, smallPlayer.frame.size.height*7.0/13.0, smallPlayer.frame.size.width/5.0, smallPlayer.frame.size.height*2.0/13.0);
    
    [smallPlayer addSublayer:line1];
    [smallPlayer addSublayer:line2];
    
    CALayer* video = [[CALayer alloc] init];
    video.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    video.frame = CGRectMake(self.player.frame.size.width/36.0, self.player.frame.size.height*0.8/5.0, self.player.frame.size.width*34.0/36.0, self.player.frame.size.height*1.5/5.0);
    [self.player addSublayer:video];
    
    CALayer* progress = [[CALayer alloc] init];
    progress.backgroundColor = [UIColor colorWithRGBHex:0xff0038].CGColor;
    progress.frame = CGRectMake(-self.player.frame.size.width, self.player.frame.size.height*7.5/8.0, self.player.frame.size.width, self.player.frame.size.height*0.5/8.0);
    [self.player addSublayer:progress];
    
    CALayer* line21 = [[CALayer alloc] init];
    line21.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    line21.frame = CGRectMake(self.player.frame.size.width/4.0, self.player.frame.size.height*2.5/5.0, self.player.frame.size.width/2.0, smallPlayer.frame.size.height*2.0/13.0);
    
    CALayer* line22 = [[CALayer alloc] init];
    line22.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    line22.frame = CGRectMake(self.player.frame.size.width*2.0/5.0, self.player.frame.size.height*2.5/5.0 + smallPlayer.frame.size.height*3.0/13.0, self.player.frame.size.width/5.0, smallPlayer.frame.size.height*2.0/13.0);
    
    [self.player addSublayer:line21];
    [self.player addSublayer:line22];
    
    CALayer* pause21 = [[CALayer alloc] init];
    pause21.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    pause21.frame = CGRectMake(self.player.frame.size.width/2.0 - self.player.frame.size.width*1.5/27.0, self.player.frame.size.height*3.0/4.0 - self.player.frame.size.width/12.0 + self.player.frame.size.width/16.0, self.player.frame.size.width/27.0, self.player.frame.size.width/6.0);
    [self.player addSublayer:pause21];
    
    CALayer* pause22 = [[CALayer alloc] init];
    pause22.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    pause22.frame = CGRectMake(self.player.frame.size.width/2.0 + self.player.frame.size.width*0.5/27.0, self.player.frame.size.height*3.0/4.0 - self.player.frame.size.width/12.0 + self.player.frame.size.width/16.0, self.player.frame.size.width/27.0, self.player.frame.size.width/6.0);
    [self.player addSublayer:pause22];
    
    UIImage* backimage = [UIImage imageWithSVGNamed:@"intro-skip-backward"
                                          targetSize:CGSizeMake(self.player.frame.size.width/4.0, self.player.frame.size.width/4.0)
                                           fillColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    CALayer* back = [[CALayer alloc] init];
    back.frame = CGRectMake(self.player.frame.size.width*1.5/8.0, self.player.frame.size.height*3.0/4.0, self.player.frame.size.width/8.0, self.player.frame.size.width/8.0);
    back.contents = (id)backimage.CGImage;
    [self.player addSublayer:back];
    
    UIImage* forwimage = [UIImage imageWithSVGNamed:@"intro-skip-forward"
                                         targetSize:CGSizeMake(self.player.frame.size.width/4.0, self.player.frame.size.width/4.0)
                                          fillColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    CALayer* forward = [[CALayer alloc] init];
    forward.frame = CGRectMake(self.player.frame.size.width*5.5/8.0, self.player.frame.size.height*3.0/4.0, self.player.frame.size.width/8.0, self.player.frame.size.width/8.0);
    forward.contents = (id)forwimage.CGImage;
    [self.player addSublayer:forward];
}

- (void)action2screen{
    for (CALayer* layer in self.feeds) {
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0)]];
        [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0 - layer.frame.size.height*0.65)]];
        animation.duration = 0.3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y - layer.frame.size.height*0.65, layer.frame.size.width, layer.frame.size.height);
        [layer addAnimation:animation forKey:@"position"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (CALayer* layer in self.feeds) {
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0)]];
            [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0 - layer.frame.size.height*1.35)]];
            animation.duration = 0.4;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y - layer.frame.size.height*1.35, layer.frame.size.width, layer.frame.size.height);
            [layer addAnimation:animation forKey:@"position"];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (int i = 0; i<2; i++) {
            [(CALayer*)[self.feeds firstObject] removeFromSuperlayer];
            [self.feeds removeObject:[self.feeds firstObject]];
            CALayer* lastLayer = [self.feeds lastObject];
            CGRect frame = CGRectMake(self.animationLayer.bounds.size.width*0.03, lastLayer.frame.origin.y + lastLayer.frame.size.height, self.animationLayer.bounds.size.width*0.94, self.animationLayer.bounds.size.width/300.0*230.0);
            CALayer* newlayer = [self makeFeedTrackLayerWithFrame:frame];
            [self.animationLayer addSublayer:newlayer];
            [self.feeds addObject:newlayer];
        }
        
        CALayer* firstLayer = [self.feeds firstObject];
        
        UIImage* playimage = [UIImage imageNamed:@"Play.png"];
        CALayer* play = [[CALayer alloc] init];
        play.frame = CGRectMake(firstLayer.frame.size.width*4.2/10.0, firstLayer.frame.size.height*1.65/8.0, firstLayer.frame.size.width/5.0, firstLayer.frame.size.width/5.0);
        play.contents = (id)playimage.CGImage;
        [firstLayer addSublayer:play];
        
        play.anchorPoint = CGPointMake(0.5, 0.5);
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scale setFromValue:[NSNumber numberWithFloat:1.0]];
        [scale setToValue:[NSNumber numberWithFloat:2.0f]];
        [scale setDuration:0.4];
        [scale setFillMode:kCAFillModeForwards];
        [play addAnimation:scale forKey:@"transform.scale"];
        
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacity setFromValue:[NSNumber numberWithFloat:1.0f]];
        [opacity setToValue:[NSNumber numberWithFloat:0.0f]];
        [opacity setDuration:0.4];
        [opacity setFillMode:kCAFillModeForwards];
        [play addAnimation:opacity forKey:@"opacity"];
        play.opacity = 0.0;
        
        if (!self.player) {
            self.player = [[CALayer alloc] init];
            self.player.backgroundColor = [UIColor darkGrayColor].CGColor;
            self.player.frame = CGRectMake(0.0, self.screenLayer.frame.size.height, self.screenLayer.frame.size.width, self.screenLayer.frame.size.height);
            [self configurePlayerView];
            [self.screenLayer addSublayer:self.player];
            
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(0.0 + self.player.frame.size.width/2.0, self.screenLayer.frame.size.height + self.player.frame.size.height/2.0)]];
            [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(0.0 + self.player.frame.size.width/2.0, self.screenLayer.frame.size.height - self.screenLayer.frame.size.height/8.0 + self.player.frame.size.height/2.0)]];
            animation.duration = 0.3;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            self.player.frame = CGRectMake(0.0, self.screenLayer.frame.size.height - self.screenLayer.frame.size.height/8.0, self.screenLayer.frame.size.width, self.screenLayer.frame.size.height);
            [self.player addAnimation:animation forKey:@"position"];
        }
        
        //reset player
        UIColor* newColor = [self nextColor];
        [self.player.sublayers[1] setBackgroundColor:newColor.CGColor];
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(-self.player.frame.size.width/2.0, self.player.frame.size.height*7.75/8.0)]];
        [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(self.player.frame.size.width*1.0/3.0, self.player.frame.size.height*7.75/8.0)]];
        animation.duration = 6.5;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [self.player.sublayers[2] addAnimation:animation forKey:@"position"];
        
        CALayer* smallPlayer = self.player.sublayers[0];
        CABasicAnimation* animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation2 setFromValue:[NSValue valueWithCGPoint:CGPointMake(-smallPlayer.frame.size.width/2.0, smallPlayer.frame.size.height/2.0)]];
        [animation2 setToValue:[NSValue valueWithCGPoint:CGPointMake(smallPlayer.frame.size.width*1.0/3.0, smallPlayer.frame.size.height/2.0)]];
        animation2.duration = 6.5;
        animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [smallPlayer.sublayers[0] addAnimation:animation2 forKey:@"position"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // hide small player
            CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [opacity setFromValue:[NSNumber numberWithFloat:1.0f]];
            [opacity setToValue:[NSNumber numberWithFloat:0.0f]];
            [opacity setDuration:0.3];
            [opacity setFillMode:kCAFillModeForwards];
            ((CALayer*)self.player.sublayers[0]).opacity = 0.0;
            [self.player.sublayers[0] addAnimation:opacity forKey:@"opacity"];
            
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(0.0 + self.player.frame.size.width/2.0, self.screenLayer.frame.size.height - self.screenLayer.frame.size.height/8.0 + self.player.frame.size.height/2.0)]];
            [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(self.screenLayer.frame.size.width/2.0, self.screenLayer.frame.size.height/2.0)]];
            animation.duration = 0.3;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            self.player.frame = self.screenLayer.bounds;
            [self.player addAnimation:animation forKey:@"position"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // show small player
                CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
                [opacity setFromValue:[NSNumber numberWithFloat:0.0f]];
                [opacity setToValue:[NSNumber numberWithFloat:1.0f]];
                [opacity setDuration:0.3];
                [opacity setFillMode:kCAFillModeForwards];
                ((CALayer*)self.player.sublayers[0]).opacity = 1.0;
                [self.player.sublayers[0] addAnimation:opacity forKey:@"opacity"];
                
                CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
                [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.screenLayer.frame.size.width/2.0, self.screenLayer.frame.size.height/2.0)]];
                [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(0.0 + self.player.frame.size.width/2.0, self.screenLayer.frame.size.height - self.screenLayer.frame.size.height/8.0 + self.player.frame.size.height/2.0)]];
                animation.duration = 0.3;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                self.player.frame = CGRectMake(0.0, self.screenLayer.frame.size.height - self.screenLayer.frame.size.height/8.0, self.screenLayer.frame.size.width, self.screenLayer.frame.size.height);
                [self.player addAnimation:animation forKey:@"position"];
                
                
            });
        });
    });
}

- (void)preparefor4screen{
    for (CALayer* layer in self.feeds) {
        layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y - layer.frame.size.height*0.5, layer.frame.size.width, layer.frame.size.height);
    }
}

- (void)action4screen{
    [[self.feeds[3] sublayers][0] setBackgroundColor:[UIColor lightGrayColor].CGColor];
    
    for (CALayer* layer in self.feeds) {
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0)]];
        [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0 - layer.frame.size.height*0.65)]];
        animation.duration = 0.3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y - layer.frame.size.height*0.65, layer.frame.size.width, layer.frame.size.height);
        [layer addAnimation:animation forKey:@"position"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (CALayer* layer in self.feeds) {
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0)]];
            [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0 - layer.frame.size.height*1.35)]];
            animation.duration = 0.4;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y - layer.frame.size.height*1.35, layer.frame.size.width, layer.frame.size.height);
            [layer addAnimation:animation forKey:@"position"];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (int i = 0; i<2; i++) {
            [self.feeds removeObject:[self.feeds firstObject]];
            CALayer* lastLayer = [self.feeds lastObject];
            CGRect frame = CGRectMake(self.animationLayer.bounds.size.width*0.03, lastLayer.frame.origin.y + lastLayer.frame.size.height, self.animationLayer.bounds.size.width*0.94, self.animationLayer.bounds.size.width/300.0*230.0);
            CALayer* newlayer = [self makeFeedTrackLayerWithFrame:frame];
            [self.animationLayer addSublayer:newlayer];
            [self.feeds addObject:newlayer];
        }
        CALayer* firstLayer = [self.feeds objectAtIndex:1];
        CALayer* deleteLayer = [[CALayer alloc] init];
        deleteLayer.backgroundColor = [UIColor colorWithRGBHex:0xff0038].CGColor;
        deleteLayer.frame = CGRectMake(firstLayer.frame.size.width, 0.0, firstLayer.frame.size.width/3.0, firstLayer.frame.size.height/230.0*156.0);
        
        UIImage* trashimage = [UIImage imageWithSVGNamed:@"intro-trash"
                                          targetSize:CGSizeMake(deleteLayer.frame.size.width/2.0*1.5, deleteLayer.frame.size.height/2.0*1.5)
                                           fillColor:[UIColor whiteColor]];
        CALayer* trash = [[CALayer alloc] init];
        trash.frame = CGRectMake(deleteLayer.frame.size.width/4.0, deleteLayer.frame.size.height/3.0, deleteLayer.frame.size.width/2.0, deleteLayer.frame.size.height/2.0);
        trash.contents = (id)trashimage.CGImage;
        [deleteLayer addSublayer:trash];
        
        firstLayer.masksToBounds = YES;
        [firstLayer addSublayer:deleteLayer];
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(deleteLayer.frame.origin.x + deleteLayer.frame.size.width/2.0, deleteLayer.frame.origin.y + deleteLayer.frame.size.height/2.0)]];
        [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(deleteLayer.frame.origin.x - deleteLayer.frame.size.width/2.0, deleteLayer.frame.origin.y + deleteLayer.frame.size.height/2.0)]];
        animation.duration = 0.3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        deleteLayer.frame = CGRectMake(deleteLayer.frame.origin.x - deleteLayer.frame.size.width, deleteLayer.frame.origin.y, deleteLayer.frame.size.width, deleteLayer.frame.size.height);
        [deleteLayer addAnimation:animation forKey:@"position"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIImage* bigtrashimage = [UIImage imageWithSVGNamed:@"intro-trash"
                                                     targetSize:CGSizeMake(deleteLayer.frame.size.width*2.0, deleteLayer.frame.size.height*2.0)
                                                      fillColor:[UIColor whiteColor]];
            CALayer* bigtrash = [[CALayer alloc] init];
            bigtrash.frame = CGRectMake(-deleteLayer.frame.size.width/2.0, deleteLayer.frame.size.height/3.0 - deleteLayer.frame.size.height*3.0/4.0, deleteLayer.frame.size.width*2.0, deleteLayer.frame.size.height*2.0);
            bigtrash.contents = (id)bigtrashimage.CGImage;
            [deleteLayer addSublayer:bigtrash];
            
            bigtrash.anchorPoint = CGPointMake(0.5, 0.4);
            CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            [scale setFromValue:[NSNumber numberWithFloat:0.25]];
            [scale setToValue:[NSNumber numberWithFloat:1.0f]];
            [scale setDuration:0.4];
            [scale setFillMode:kCAFillModeForwards];
            [bigtrash addAnimation:scale forKey:@"transform.scale"];
            
            CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [opacity setFromValue:[NSNumber numberWithFloat:1.0f]];
            [opacity setToValue:[NSNumber numberWithFloat:0.0f]];
            [opacity setDuration:0.4];
            [opacity setFillMode:kCAFillModeForwards];
            [bigtrash addAnimation:opacity forKey:@"opacity"];
            bigtrash.opacity = 0.0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                [scale setFromValue:[NSNumber numberWithFloat:1.0]];
                [scale setToValue:[NSNumber numberWithFloat:0.5]];
                [scale setDuration:0.2];
                [scale setFillMode:kCAFillModeForwards];
                [firstLayer addAnimation:scale forKey:@"transform.scale"];
                
                CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
                [opacity setFromValue:[NSNumber numberWithFloat:1.0f]];
                [opacity setToValue:[NSNumber numberWithFloat:0.0f]];
                [opacity setDuration:0.2];
                [opacity setFillMode:kCAFillModeForwards];
                [firstLayer addAnimation:opacity forKey:@"opacity"];
                firstLayer.opacity = 0.0;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.feeds removeObject:firstLayer];
                    [firstLayer removeFromSuperlayer];
                    CALayer* lastLayer = [self.feeds lastObject];
                    CGRect frame = CGRectMake(self.animationLayer.bounds.size.width*0.03, lastLayer.frame.origin.y + lastLayer.frame.size.height, self.animationLayer.bounds.size.width*0.94, self.animationLayer.bounds.size.width/300.0*230.0);
                    CALayer* newlayer = [self makeFeedTrackLayerWithFrame:frame];
                    [self.animationLayer addSublayer:newlayer];
                    [self.feeds addObject:newlayer];

                    for (CALayer* layer in self.feeds) {
                        if (!(layer == [self.feeds firstObject])) {
                            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
                            [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0)]];
                            [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0 - layer.frame.size.height)]];
                            animation.duration = 0.2;
                            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y - layer.frame.size.height, layer.frame.size.width, layer.frame.size.height);
                            [layer addAnimation:animation forKey:@"position"];
                        }
                    }
                    
                });
            });
        });

    });
}

- (void)action3screen{
    for (CALayer* layer in self.feeds) {
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0)]];
        [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0 - layer.frame.size.height*1.2)]];
        animation.duration = 0.3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y - layer.frame.size.height*1.2, layer.frame.size.width, layer.frame.size.height);
        [layer addAnimation:animation forKey:@"position"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (CALayer* layer in self.feeds) {
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0)]];
            [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0 - layer.frame.size.height*1.8)]];
            animation.duration = 0.4;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y - layer.frame.size.height*1.8, layer.frame.size.width, layer.frame.size.height);
            [layer addAnimation:animation forKey:@"position"];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (int i = 0; i<3; i++) {
            [(CALayer*)[self.feeds firstObject] removeFromSuperlayer];
            [self.feeds removeObject:[self.feeds firstObject]];
            CALayer* lastLayer = [self.feeds lastObject];
            CGRect frame = CGRectMake(self.animationLayer.bounds.size.width*0.03, lastLayer.frame.origin.y + lastLayer.frame.size.height, self.animationLayer.bounds.size.width*0.94, self.animationLayer.bounds.size.width/300.0*230.0);
            CALayer* newlayer = [self makeFeedTrackLayerWithFrame:frame];
            [self.animationLayer addSublayer:newlayer];
            [self.feeds addObject:newlayer];
        }
        
        CALayer* firstLayer = [self.feeds firstObject];
        [(CALayer*)firstLayer.sublayers[4] removeFromSuperlayer];
        CGRect frame = firstLayer.frame;
        UIImage* himage = [UIImage imageWithSVGNamed:@"intro-heart"
                                          targetSize:CGSizeMake(frame.size.height/230.0*(230.0-156.0)*0.8, frame.size.height/230.0*(230.0-156.0)*0.8)
                                           fillColor:[UIColor colorWithRGBHex:0xff0038]];
        CALayer* heart = [[CALayer alloc] init];
        heart.frame = CGRectMake(frame.size.width*17.0/20.0, frame.size.height/230.0*156.0 + frame.size.height/230.0*(230.0-156.0)*0.25, frame.size.height/230.0*(230.0-156.0)*0.4, frame.size.height/230.0*(230.0-156.0)*0.4);
        heart.contents = (id)himage.CGImage;
        [firstLayer addSublayer:heart];
        
        UIImage* bighimage = [UIImage imageWithSVGNamed:@"intro-heart"
                                          targetSize:CGSizeMake(frame.size.height/230.0*(230.0-156.0)*1.6, frame.size.height/230.0*(230.0-156.0)*1.6)
                                           fillColor:[UIColor colorWithRGBHex:0xff0038]];
        CALayer* bigheart = [[CALayer alloc] init];
        bigheart.frame = CGRectMake(frame.size.width*17.0/20.0 - frame.size.height/230.0*(230.0-156.0)*0.6, frame.size.height/230.0*156.0 + frame.size.height/230.0*(230.0-156.0)*0.25 - frame.size.height/230.0*(230.0-156.0)*0.6, frame.size.height/230.0*(230.0-156.0)*1.6, frame.size.height/230.0*(230.0-156.0)*1.6);
        bigheart.contents = (id)bighimage.CGImage;
        [firstLayer addSublayer:bigheart];
        
        bigheart.anchorPoint = CGPointMake(0.5, 0.5);
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scale setFromValue:[NSNumber numberWithFloat:0.25]];
        [scale setToValue:[NSNumber numberWithFloat:1.0f]];
        [scale setDuration:0.4];
        [scale setFillMode:kCAFillModeForwards];
        [bigheart addAnimation:scale forKey:@"transform.scale"];
        
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacity setFromValue:[NSNumber numberWithFloat:1.0f]];
        [opacity setToValue:[NSNumber numberWithFloat:0.0f]];
        [opacity setDuration:0.4];
        [opacity setFillMode:kCAFillModeForwards];
        [bigheart addAnimation:opacity forKey:@"opacity"];
        bigheart.opacity = 0.0;
    });
}

- (void)action1screen{
    
    CABasicAnimation *backgroundColor = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    [backgroundColor setToValue:(id)[UIColor lightGrayColor].CGColor];
    [backgroundColor setDuration:0.3];
    [backgroundColor setFillMode:kCAFillModeForwards];
    [(CALayer*)((CALayer*)self.feeds[0]).sublayers[0] addAnimation:backgroundColor forKey:@"backgroundColor"];
    [(CALayer*)((CALayer*)self.feeds[0]).sublayers[0] setBackgroundColor:[UIColor lightGrayColor].CGColor];

    
    for (CALayer* layer in self.feeds) {
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height/2.0)]];
        [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(layer.frame.origin.x + layer.frame.size.width/2.0, layer.frame.origin.y + layer.frame.size.height*3.0/2.0)]];
        animation.duration = 0.3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y + layer.frame.size.height, layer.frame.size.width, layer.frame.size.height);
        [layer addAnimation:animation forKey:@"position"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [(CALayer*)[self.feeds lastObject] removeFromSuperlayer];
        [self.feeds removeObject:[self.feeds lastObject]];
        CGRect frame = CGRectMake(self.animationLayer.bounds.size.width*0.03, 0.0, self.animationLayer.bounds.size.width*0.94, self.animationLayer.bounds.size.width/300.0*230.0);
        CALayer* newlayer = [self makeFeedTrackLayerWithFrame:frame];
        [self.animationLayer addSublayer:newlayer];
        [self.feeds insertObject:newlayer atIndex:0];
        
        newlayer.anchorPoint = CGPointMake(0.5, 0.5);
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scale setFromValue:[NSNumber numberWithFloat:0.5f]];
        [scale setToValue:[NSNumber numberWithFloat:1.0f]];
        [scale setDuration:0.2];
        [scale setFillMode:kCAFillModeForwards];
        [newlayer addAnimation:scale forKey:@"transform.scale"];
        
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacity setFromValue:[NSNumber numberWithFloat:0.0f]];
        [opacity setToValue:[NSNumber numberWithFloat:1.0f]];
        [opacity setDuration:0.2];
        [opacity setFillMode:kCAFillModeForwards];
        [newlayer addAnimation:opacity forKey:@"opacity"];
        
        UIColor* newColor = [self nextColor];
        CABasicAnimation *backgroundColor = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        [backgroundColor setToValue:(id)newColor.CGColor];
        [backgroundColor setDuration:0.2];
        [backgroundColor setFillMode:kCAFillModeForwards];
        [(CALayer*)newlayer.sublayers[0] addAnimation:backgroundColor forKey:@"backgroundColor"];
        [(CALayer*)newlayer.sublayers[0] setBackgroundColor:newColor.CGColor];
        
    });
    
}

- (UIColor*)nextColor{
    UIColor* color;
    if (self.currentColor == 0) {
        color = [UIColor colorWithRGBHex:0xffcc02];
    }
    if (self.currentColor == 1) {
        color = [UIColor colorWithRGBHex:0x47cc5e];
    }
    if (self.currentColor == 2) {
        color = [UIColor colorWithRGBHex:0xff0038];
    }
    if (self.currentColor == 3) {
        color = [UIColor colorWithRGBHex:0x5ac8fa];
    }
    self.currentColor++;
    if (self.currentColor > 3) {
        self.currentColor = 0;
    }
    return color;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CALayer*) makeFeedTrackLayerWithFrame:(CGRect)frame{
    CALayer* feedLayer = [[CALayer alloc] init];
    feedLayer.frame = frame;
    
    CALayer* trackIm = [[CALayer alloc] init];
    trackIm.backgroundColor = [UIColor lightGrayColor].CGColor;
    trackIm.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height/230.0*156.0);
    [feedLayer addSublayer:trackIm];
    
    UIImage* image = [UIImage imageWithSVGNamed:@"intro-avatar"
                                     targetSize:CGSizeMake(frame.size.height/230.0*(230.0-156.0)*0.7*1.5, frame.size.height/230.0*(230.0-156.0)*0.7*1.5)
                                      fillColor:[UIColor lightGrayColor]];
    CALayer* avatar = [[CALayer alloc] init];
    avatar.frame = CGRectMake(frame.size.width/20.0, frame.size.height/230.0*156.0 + frame.size.height/230.0*(230.0-156.0)*0.1, frame.size.height/230.0*(230.0-156.0)*0.7, frame.size.height/230.0*(230.0-156.0)*0.7);
    avatar.contents = (id)image.CGImage;
    [feedLayer addSublayer:avatar];
    
    CALayer* text1 = [[CALayer alloc] init];
    text1.backgroundColor = [UIColor lightGrayColor].CGColor;
    text1.frame = CGRectMake(frame.size.width/3.5, frame.size.height/230.0*156.0 + frame.size.height/230.0*(230.0-156.0)*0.28, frame.size.width/2.0, frame.size.height/230.0*(230.0-156.0)*0.14);
    [feedLayer addSublayer:text1];
    
    CALayer* text2 = [[CALayer alloc] init];
    text2.backgroundColor = [UIColor lightGrayColor].CGColor;
    text2.frame = CGRectMake(frame.size.width/3.5, frame.size.height/230.0*156.0 + frame.size.height/230.0*(230.0-156.0)*0.48, frame.size.width/5.0, frame.size.height/230.0*(230.0-156.0)*0.14);
    [feedLayer addSublayer:text2];
    
    UIImage* himage = [UIImage imageWithSVGNamed:@"intro-heart-outline"
                                     targetSize:CGSizeMake(frame.size.height/230.0*(230.0-156.0)*0.8, frame.size.height/230.0*(230.0-156.0)*0.8)
                                      fillColor:[UIColor lightGrayColor]];
    CALayer* heart = [[CALayer alloc] init];
    heart.frame = CGRectMake(frame.size.width*17.0/20.0, frame.size.height/230.0*156.0 + frame.size.height/230.0*(230.0-156.0)*0.25, frame.size.height/230.0*(230.0-156.0)*0.4, frame.size.height/230.0*(230.0-156.0)*0.4);
    heart.contents = (id)himage.CGImage;
    [feedLayer addSublayer:heart];
    
    return feedLayer;
}

- (void) addPhoneLayer{
    CALayer* layer = [[CALayer alloc] init];
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    layer.cornerRadius = 25.0;
    layer.borderWidth = 2.0;
    layer.borderColor = [UIColor lightGrayColor].CGColor;
    float phoneWidth = self.screen.size.width*0.6;
    float phoneHeight = phoneWidth/338.0*716.0;
    layer.frame = CGRectMake((self.screen.size.width - phoneWidth)/2.0, self.screen.size.height - 40.0 - phoneHeight, phoneWidth, phoneHeight);
    [self.view.layer addSublayer:layer];
    
    CALayer* button1 = [[CALayer alloc] init];
    button1.backgroundColor = [UIColor lightGrayColor].CGColor;
    button1.frame = CGRectMake((self.screen.size.width - phoneWidth)/2.0 + phoneWidth*226.0/338.0, self.screen.size.height - 40.0 - phoneHeight - 1.5, phoneWidth*50.0/338.0, 1.5);
    [self.view.layer addSublayer:button1];
    
    CALayer* button2 = [[CALayer alloc] init];
    button2.backgroundColor = [UIColor lightGrayColor].CGColor;
    button2.frame = CGRectMake((self.screen.size.width - phoneWidth)/2.0 - 1.5, self.screen.size.height - 40.0 - phoneHeight + phoneHeight*100.0/716.0, 1.5, phoneHeight/716.0*35.0);
    [self.view.layer addSublayer:button2];
    
    CALayer* button3 = [[CALayer alloc] init];
    button3.backgroundColor = [UIColor lightGrayColor].CGColor;
    button3.frame = CGRectMake((self.screen.size.width - phoneWidth)/2.0 - 1.5, self.screen.size.height - 40.0 - phoneHeight + phoneHeight*168.0/716.0, 1.5, phoneHeight/716.0*28.0);
    [self.view.layer addSublayer:button3];
    
    CALayer* button4 = [[CALayer alloc] init];
    button4.backgroundColor = [UIColor lightGrayColor].CGColor;
    button4.frame = CGRectMake((self.screen.size.width - phoneWidth)/2.0 - 1.5, self.screen.size.height - 40.0 - phoneHeight + phoneHeight*227.0/716.0, 1.5, phoneHeight/716.0*28.0);
    [self.view.layer addSublayer:button4];
    
    CALayer* layer2 = [[CALayer alloc] init];
    layer2.backgroundColor = [UIColor whiteColor].CGColor;
    layer2.cornerRadius = 4.0;
    layer2.borderWidth = 1.0;
    layer2.borderColor = [UIColor lightGrayColor].CGColor;
    layer2.frame = CGRectMake(phoneWidth*12.0/338.0, phoneHeight*83.0/716.0, phoneWidth - 2*phoneWidth*12.0/338.0, phoneHeight - 2*phoneHeight*83.0/716.0);
    [layer addSublayer:layer2];
    layer2.masksToBounds = YES;
    self.screenLayer = layer2;
    
    CALayer* home = [[CALayer alloc] init];
    home.backgroundColor = [UIColor whiteColor].CGColor;
    home.borderWidth = 2.0;
    home.borderColor = [UIColor lightGrayColor].CGColor;
    home.frame = CGRectMake(phoneWidth/2.0 - phoneWidth*56.0/338.0/2.0, phoneHeight - phoneHeight*83.0/716.0/2.0 - phoneWidth*56.0/338.0/2.0, phoneWidth*56.0/338.0, phoneWidth*56.0/338.0);
    home.cornerRadius = phoneWidth*56.0/338.0/2.0;
    [layer addSublayer:home];
    
    CALayer* speaker = [[CALayer alloc] init];
    speaker.backgroundColor = [UIColor lightGrayColor].CGColor;
    speaker.frame = CGRectMake(phoneWidth/2.0 - phoneWidth*56.0/338.0/2.0, phoneHeight*83.0/716.0/2.0, phoneWidth*56.0/338.0, 5.0);
    speaker.cornerRadius = 2.5;
    [layer addSublayer:speaker];
    
    UIImage* image = [UIImage imageWithSVGNamed:@"ios7-statusbar-white"
                                     targetSize:CGSizeMake(layer2.bounds.size.width*1.5, layer2.bounds.size.width/300.0*30.0*1.5)
                                      fillColor:[UIColor lightGrayColor]];
    CALayer* statusBar = [[CALayer alloc] init];
    statusBar.backgroundColor = [UIColor whiteColor].CGColor;
    statusBar.contents = (id)image.CGImage;
    statusBar.frame = CGRectMake(0.0, 0.0, layer2.bounds.size.width, layer2.bounds.size.width/300.0*30.0);
    [layer2 addSublayer:statusBar];
    
    CALayer* menu1 = [[CALayer alloc] init];
    menu1.backgroundColor = [UIColor lightGrayColor].CGColor;
    menu1.frame = CGRectMake(layer2.bounds.size.width/315*55/3.0,layer2.bounds.size.width/300.0*20.0 + layer2.bounds.size.width/315*55*2.0/9.0, layer2.bounds.size.width/315*50/2.0, 1.0);
    menu1.cornerRadius = 0.5;
    CALayer* menu2 = [[CALayer alloc] init];
    menu2.backgroundColor = [UIColor lightGrayColor].CGColor;
    menu2.frame = CGRectMake(layer2.bounds.size.width/315*55/3.0,layer2.bounds.size.width/300.0*20.0 + layer2.bounds.size.width/315*55*3.0/9.0, layer2.bounds.size.width/315*50/2.0, 1.0);
    menu2.cornerRadius = 0.5;
    CALayer* menu3 = [[CALayer alloc] init];
    menu3.backgroundColor = [UIColor lightGrayColor].CGColor;
    menu3.frame = CGRectMake(layer2.bounds.size.width/315*55/3.0,layer2.bounds.size.width/300.0*20.0 + layer2.bounds.size.width/315*55*4.0/9.0, layer2.bounds.size.width/315*50/2.0, 1.0);
    menu3.cornerRadius = 0.5;
    
    CATextLayer *label = [[CATextLayer alloc] init];
    [label setFont:@"Helvetica-Bold"];
    [label setFontSize:12];
    [label setFrame:CGRectMake(layer2.bounds.size.width/2.0 - 50.0, layer2.bounds.size.width/300.0*23.0, 100.0, 20.0)];
    [label setString:@"musicfeed"];
    [label setAlignmentMode:kCAAlignmentCenter];
    label.contentsScale = [UIScreen mainScreen].scale*2.0;
    [label setForegroundColor:[[UIColor lightGrayColor] CGColor]];
    [layer2 addSublayer:label];
    
    
    [layer2 addSublayer:menu1];
    [layer2 addSublayer:menu2];
    [layer2 addSublayer:menu3];
    
    self.animationLayer = [[CALayer alloc] init];
    self.animationLayer.masksToBounds = YES;
    self.animationLayer.backgroundColor = [UIColor whiteColor].CGColor;
    self.animationLayer.cornerRadius = 4.0;
    self.animationLayer.frame = CGRectMake(0.0, layer2.bounds.size.width/300.0*20.0 + layer2.bounds.size.width/315*55*7.0/9.0, layer2.bounds.size.width, layer2.bounds.size.height - (layer2.bounds.size.width/300.0*20.0 + layer2.bounds.size.width/315*55*7.0/9.0));
    [layer2 addSublayer:self.animationLayer];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)doneButtonPressed:(id)sender {
    [self.introViewController doneButtonPressed];
}

@end
