//
//  NavigationTitle.m
//  botmusic
//
//  Created by Supervisor on 20.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "NavigationTitle.h"

static CGFloat const ARROW_OFFSET=4.0f;

@implementation NavigationTitle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)awakeFromNib
{
    [self addRecognizers];
}

+(NavigationTitle*)createNavigationTitle
{
    NavigationTitle *navigationTitle=[[[NSBundle mainBundle]loadNibNamed:@"NavigationTitle" owner:nil options:nil]lastObject];
    return navigationTitle;
}

-(void)addRecognizers
{
    UITapGestureRecognizer *tapTitle=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAtTitle:)];
    [_titleLabel addGestureRecognizer:tapTitle];
    
    UITapGestureRecognizer *tapImage=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAtTitle:)];
    [_arrowImage addGestureRecognizer:tapImage];
}
-(void)didTapAtTitle:(UITapGestureRecognizer*)tapRecognizer
{
    [_delegate didTapAtTitle];
}

-(void)setNavigationTitle:(NSString *)title
{
    [self setNavigationTitle:title andState:_state];
}
-(void)setNavigationTitle:(NSString*)title andState:(NavigationTitleState)state
{
    _titleLabel.text=title;
    
    [self setState:state];
    
    [self alignView];
}
-(void)setState:(NavigationTitleState)state
{
    if(state==NavigationTitleStateUp)
    {
        [_arrowImage setImage:[UIImage imageNamed:@"up-arrow.png"]];
    }
    else
    {
        [_arrowImage setImage:[UIImage imageNamed:@"down-arrow.png"]];
    }
    
    _state=state;
}
-(void)alignView
{
    [_titleLabel sizeToFit];
    
    CGRect labelFrame=_titleLabel.frame;
    CGRect imageFrame=_arrowImage.frame;
    CGRect viewFrame=self.frame;
    
    labelFrame.origin.x=((viewFrame.size.width-labelFrame.size.width-imageFrame.size.width-ARROW_OFFSET)/2);
    imageFrame.origin.x=labelFrame.origin.x+labelFrame.size.width+ARROW_OFFSET;
    
    _titleLabel.frame=labelFrame;
    _arrowImage.frame=imageFrame;
}

@end
