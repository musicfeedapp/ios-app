//
//  SSSliderView.h
//  Test
//
//  Created by Supervisor on 11.08.14.
//  Copyright (c) 2014 Supervisor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    SSSliderDirectionNone,
    SSSliderDirectionLeft,
    SSSliderDirectionRight
    
}SSSliderDirection;

@protocol SSSliderViewDelegate <NSObject>
@optional
-(void)willOpenSlider;
-(void)didOpenSlider;
-(void)willCloseSlider;
-(void)didCloseSlider;

@end

@interface SSSliderView : UIView<UIGestureRecognizerDelegate>

@property(nonatomic,weak)IBOutlet UIView *upperView;
@property(nonatomic,weak)id<SSSliderViewDelegate> sliderViewDelegate;

@property(nonatomic,assign)BOOL isSliderOpen;

@property(nonatomic,assign)BOOL canOpenLeftSide;
@property(nonatomic,assign)BOOL canOpenRightSide;

@property(nonatomic,assign)CGFloat openWidth;
@property(nonatomic,assign)CGFloat widthWithoutAnimation;
@property(nonatomic,assign)CGFloat animationDuration;

-(void)closeSliderAnimated:(BOOL)animated;
-(void)openSliderWithDirection:(SSSliderDirection)direction animated:(BOOL)animated;

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer;

-(void)notifyWillOpenSlider;
-(void)notifyDidOpenSlider;
-(void)notifyWillCloseSlider;
-(void)notifyDidCloseSlider;

@end
