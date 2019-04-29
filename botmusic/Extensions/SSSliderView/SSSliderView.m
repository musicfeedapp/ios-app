//
//  SSSliderView.m
//  Test
//
//  Created by Supervisor on 11.08.14.
//  Copyright (c) 2014 Supervisor. All rights reserved.
//

#import "SSSliderView.h"

static CGFloat const X_OFFSET=95.0;
static CGFloat const OFFSET_WITHOUT_ANIMATION=42.5;
static  CGFloat const ANIMATION_DURATION=0.4f;

@interface SSSliderView()
{
    CGRect closedFrame;
    CGRect originalFrame;
}

@property(nonatomic,assign)SSSliderDirection direction;

@end

@implementation SSSliderView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)awakeFromNib{
    [self setDefaultSettings];
}

#pragma mark - Default Settings

-(void)setDefaultSettings{
    self.isSliderOpen=NO;
    self.direction=SSSliderDirectionNone;
    
    self.canOpenLeftSide=NO;
    self.canOpenRightSide=YES;
    
    self.openWidth=X_OFFSET;
    self.widthWithoutAnimation=OFFSET_WITHOUT_ANIMATION;
    self.animationDuration=ANIMATION_DURATION;
    
    closedFrame=self.upperView.frame;
    
    [self addPanRecognizer];
}

-(void)addPanRecognizer{
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognize:)];
    [pan setDelegate:self];
    [self.upperView addGestureRecognizer:pan];
}
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint velocity = [panGestureRecognizer velocityInView:self];
    
    if(fabs(velocity.y) > fabs(velocity.x))
    {
        return NO;
    }
    
    if(self.isSliderOpen)
    {
        if(velocity.x>0)
        {
            return YES;
        }
    }
    else
    {
        if(velocity.x<0)
        {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Pan Recognizer methods

-(void)panRecognize:(UIPanGestureRecognizer*)panRecognizer{
    
    CGPoint translation=[panRecognizer translationInView:self];
    
    if(panRecognizer.state==UIGestureRecognizerStateChanged)
    {
        if(self.direction==SSSliderDirectionNone)
        {
            if(!translation.x)
            {
                return;
            }
            else
            {
                [self beginTranslation:translation];
            }
            
            return;
        }
        
        if(self.direction==SSSliderDirectionRight)
        {
            [self rightConstraint:&translation];
        }
        else
        {
            [self leftConstraint:&translation];
        }
        
        CGRect frame=originalFrame;
        frame.origin.x+=translation.x;
        self.upperView.frame=frame;
        
        return;
    }
    
    if(panRecognizer.state==UIGestureRecognizerStateEnded || panRecognizer.state==UIGestureRecognizerStateFailed)
    {
        if(self.direction==SSSliderDirectionNone)
        {
            return;
        }
        
        CGRect frame=closedFrame;
        
        if(!self.isSliderOpen)
        {
            if(fabs(translation.x)>self.widthWithoutAnimation)
            {
                if(self.direction==SSSliderDirectionRight)
                {
                    frame.origin.x=self.openWidth;
                }
                else
                {
                    frame.origin.x=-self.openWidth;
                }
            }
            else
            {
                frame.origin.x=0;
            }
        }
        else
        {
            if((self.direction==SSSliderDirectionRight && translation.x<0) || (self.direction==SSSliderDirectionLeft && translation.x>0))
            {
                self.direction=SSSliderDirectionNone;
                return;
            }
        }
        
        float cooeficient=fabs((self.openWidth-fabsf(translation.x))/self.openWidth);
        
        if(cooeficient!=0.0)
        {
            [UIView animateWithDuration:cooeficient*ANIMATION_DURATION animations:^{
                self.upperView.frame=frame;
            } completion:^(BOOL completed)
             {
                 [self finishPanWithFrame:frame];
             }];
        }
        else
        {
            [self finishPanWithFrame:frame];
        }
    }
}
-(void)finishPanWithFrame:(CGRect)frame{
    self.direction=SSSliderDirectionNone;
    
    if(frame.origin.x==0)
    {
        self.isSliderOpen=NO;
    }
    else
    {
        self.isSliderOpen=YES;
    }
    
    if(self.isSliderOpen){
        [self notifyDidOpenSlider];
    }
    else
    {
        [self notifyDidCloseSlider];
    }
}

#pragma mark - Pan Helpers

-(void)beginTranslation:(CGPoint)translation
{
    originalFrame=self.upperView.frame;
    
    if(self.isSliderOpen)
    {
        if(originalFrame.origin.x>0)
        {
            self.direction=SSSliderDirectionLeft;
        }
        else
        {
            self.direction=SSSliderDirectionRight;
        }
        
        [self notifyWillCloseSlider];
    }
    else
    {
        if(translation.x>0)
        {
            if(self.canOpenLeftSide)
            {
                self.direction=SSSliderDirectionRight;
                [self notifyWillOpenSlider];
            }
        }
        else
        {
            if(self.canOpenRightSide)
            {
                self.direction=SSSliderDirectionLeft;
                [self notifyWillOpenSlider];
            }
        }
    }
}
-(void)leftConstraint:(CGPoint*)translation
{
    if(translation->x>0)
    {
        translation->x=0;
    }
    
    if(translation->x<-self.openWidth)
    {
        translation->x=-self.openWidth;
    }
}
-(void)rightConstraint:(CGPoint*)translation
{
    if(translation->x<0)
    {
        translation->x=0;
    }
    
    if(translation->x>self.openWidth)
    {
        translation->x=self.openWidth;
    }
}

#pragma mark - Open/Close slider

-(void)openSliderWithDirection:(SSSliderDirection)direction animated:(BOOL)animated{
    
    CGRect frame=self.upperView.frame;
    
    if(direction==SSSliderDirectionLeft)
    {
        frame.origin.x-=self.openWidth;
    }
    else
    {
        frame.origin.x+=self.openWidth;
    }
    
    [self notifyWillOpenSlider];
    
    if(animated)
    {
        [UIView animateWithDuration:ANIMATION_DURATION/2 animations:^{
            self.upperView.frame=frame;
        } completion:^(BOOL completed){
            self.isSliderOpen=YES;
            
            [self notifyDidOpenSlider];
        }];
    }
    else
    {
        self.upperView.frame=frame;
        self.isSliderOpen=YES;
        
        [self notifyDidOpenSlider];
    }
    
}
-(void)closeSliderAnimated:(BOOL)animated{
    
    [self notifyWillCloseSlider];
    
    if(animated){
        [UIView animateWithDuration:ANIMATION_DURATION/2 animations:^{
            self.upperView.frame=closedFrame;
        } completion:^(BOOL completed){
            self.isSliderOpen=NO;
            
            [self notifyDidCloseSlider];
        }];
    }else{
        self.upperView.frame=closedFrame;
        self.isSliderOpen=NO;
        [self notifyDidCloseSlider];
    }
}

#pragma mark - Delegate notifications

-(void)notifyWillOpenSlider{
    if(self.sliderViewDelegate && [self.sliderViewDelegate respondsToSelector:@selector(willOpenSlider)])
    {
        [self.sliderViewDelegate willOpenSlider];
    }
}
-(void)notifyDidOpenSlider{
    if(self.sliderViewDelegate && [self.sliderViewDelegate respondsToSelector:@selector(didOpenSlider)])
    {
        [self.sliderViewDelegate didOpenSlider];
    }
}
-(void)notifyWillCloseSlider{
    if(self.sliderViewDelegate && [self.sliderViewDelegate respondsToSelector:@selector(willCloseSlider)])
    {
        [self.sliderViewDelegate willCloseSlider];
    }
}
-(void)notifyDidCloseSlider{
    if(self.sliderViewDelegate && [self.sliderViewDelegate respondsToSelector:@selector(didCloseSlider)])
    {
        [self.sliderViewDelegate didCloseSlider];
    }
}


@end
