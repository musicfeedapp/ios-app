//
//  ProgressView.m
//  botmusic
//
//  Created by Supervisor on 13.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "ProgressView.h"

#import <UIColor+Expanded.h>

@interface ProgressView()

@end

@implementation ProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    if(self=[super initWithCoder:aDecoder]){
        //[self setBackgroundColor:[UIColor colorWithRGBHex:kBrandPinkColor]];
    }
    
    return self;
}

@end
