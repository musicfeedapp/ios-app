//
//  ActionViewCreator.m
//  botmusic
//
//  Created by Supervisor on 19.06.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "ActionViewCreator.h"

@implementation ActionViewCreator

+ (ActionView*)createActionViewInView:(UIView*)view
{
    CGRect bounds = view.bounds;
    bounds.size.height = [TrackView trackViewHeight] - 88;
    view.bounds = bounds;
    ActionView *actionView = [[[NSBundle mainBundle] loadNibNamed:@"ActionView" owner:nil options:nil] lastObject];
    
    CGRect frame = CGRectMake(([TrackView trackViewWidth] - 18 - ACTION_VIEW_WIDTH)/2,
                              (CGRectGetHeight(view.frame) - ACTION_VIEW_WIDTH)/2,
                              ACTION_VIEW_WIDTH,
                              ACTION_VIEW_WIDTH);
    [actionView setFrame:frame];
    [view addSubview:actionView];
//
//    [view addConstraint:[NSLayoutConstraint
//                         constraintWithItem:actionView
//                         attribute:NSLayoutAttributeCenterY
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:view
//                         attribute:NSLayoutAttributeCenterY
//                         multiplier:1.0
//                         constant:0]];
//    
//    [view addConstraint:[NSLayoutConstraint
//                         constraintWithItem:actionView
//                         attribute:NSLayoutAttributeCenterX
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:view
//                         attribute:NSLayoutAttributeCenterX
//                         multiplier:1.0
//                         constant:0]];
    
    [actionView setUserInteractionEnabled:NO];
    
    return actionView;
}

@end
