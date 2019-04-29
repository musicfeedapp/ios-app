//
//  CustomAKSegmentControl.m
//  botmusic
//
//  Created by Dzionis Brek on 08.04.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "CustomAKSegmentControl.h"

@implementation CustomAKSegmentControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelectedIndex:(NSUInteger)index
{
    if (index == self.selectedIndexes.lastIndex)
    {
        if (self.customAKSCDelegate)
        {
            [self.customAKSCDelegate segmentControlTaped];
        }
    }
    [super setSelectedIndex:index];
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
