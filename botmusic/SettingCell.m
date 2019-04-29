//
//  SettingCell.m
//  botmusic
//
//  Created by Supervisor on 19.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "SettingCell.h"
#import "UIColor+Expanded.h"

CGFloat const SETTING_CELL_HEIGHT=48.0f;

#define SETTING_CELL_SEPARATOR_COLOR [UIColor colorWithHexString:@"A9A9A9"]

@implementation SettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    UIView *view=[self viewWithTag:1];
    view.backgroundColor=SETTING_CELL_SEPARATOR_COLOR;
    
    view=[self viewWithTag:2];
    view.backgroundColor=SETTING_CELL_SEPARATOR_COLOR;
}

#pragma mark - Draw lines methods

- (void)drawLowerSeparator
{
    [self clearSeparators];
    
    UIView *lowerStrip = [[UIView alloc]init];
    lowerStrip.backgroundColor = SETTING_CELL_SEPARATOR_COLOR;
    lowerStrip.frame = CGRectMake(15, SETTING_CELL_HEIGHT-0.5f,CGRectGetWidth(self.frame),0.5f);
    [lowerStrip setUserInteractionEnabled:NO];
    [lowerStrip setTag:1];
    
    [self addSubview:lowerStrip];
}
-(void)drawTopAndBottomSeparator
{
    [self clearSeparators];
    
    UIView *lowerStrip = [[UIView alloc]init];
    lowerStrip.backgroundColor = SETTING_CELL_SEPARATOR_COLOR;
    lowerStrip.frame = CGRectMake(0, SETTING_CELL_HEIGHT-0.5f,CGRectGetWidth(self.frame),0.5f);
    [lowerStrip setUserInteractionEnabled:NO];
    [lowerStrip setTag:1];
    
    [self addSubview:lowerStrip];
    
    UIView *upperStrip = [[UIView alloc]init];
    upperStrip.backgroundColor=SETTING_CELL_SEPARATOR_COLOR;
    upperStrip.frame = CGRectMake(0,0,CGRectGetWidth(self.frame),0.5f);
    [upperStrip setUserInteractionEnabled:NO];
    [upperStrip setTag:2];
    
    [self addSubview:upperStrip];
}
-(void)clearSeparators
{
    UIView *view=[self viewWithTag:1];
    [view removeFromSuperview];
    
    view=[self viewWithTag:2];
    [view removeFromSuperview];
}

#pragma mark - Switcher events
-(IBAction)didSwitcherChangeValue:(id)sender
{
    [self notifySwitcherChangeValue];
}

#pragma mark - Notify Delegate mthods
-(void)notifySwitcherChangeValue
{
    if(_delegate && [_delegate respondsToSelector:@selector(didSwitchAtIndexPath:)])
    {
        [_delegate didSwitchAtIndexPath:self];
    }
}
@end
