//
//  IRButton.m
//  botmusic
//
//  Created by Илья Романеня on 13.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "BaseButton.h"
#import <UIColor+Expanded.h>
#import <UIImage+ImageWithColor.h>

@implementation BaseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImage* imageSelected = [UIImage imageWithColor:[UIColor colorWithRGBHex:kInactiveColor]];
        [self setBackgroundImage:imageSelected forState:UIControlStateNormal];
        
        UIImage* imageNormal = [UIImage imageWithColor:[UIColor colorWithRGBHex:kActiveColor]];
        [self setBackgroundImage:imageNormal forState:UIControlStateSelected];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
