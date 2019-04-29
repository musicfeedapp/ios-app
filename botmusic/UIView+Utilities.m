//
//  UIView+Utilities.m
//  botmusic
//
//  Created by Илья Романеня on 09.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "UIView+Utilities.h"

@implementation UIView (Utilities)

- (void)applyRoundingCorners:(UIRectCorner)corners radius:(CGSize)radiusSize
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:radiusSize];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end
