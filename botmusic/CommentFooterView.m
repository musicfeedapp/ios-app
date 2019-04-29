//
//  CommentFooterView.m
//  botmusic
//
//  Created by Supervisor on 03.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "CommentFooterView.h"

@implementation CommentFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
+(CommentFooterView*)createCommentFooterView
{
    CommentFooterView  *footerView=[[[NSBundle mainBundle]loadNibNamed:@"CommentFooterView" owner:nil options:nil]lastObject];
    [footerView setFrame:CGRectMake(0, 0,CGRectGetWidth([[UIScreen mainScreen]bounds]), COMMENT_FOOTER_HEIGHT)];
    
    return footerView;
}

-(IBAction)didSelectButton:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectFooterView)])
    {
        [_delegate didSelectFooterView];
    }
}


@end
