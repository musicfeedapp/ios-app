//
//  CommentHeaderView.m
//  botmusic
//
//  Created by Supervisor on 03.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "CommentHeaderView.h"

@implementation CommentHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)didSelectButton:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectHeaderView)])
    {
        [_delegate didSelectHeaderView];
    }
}

@end
