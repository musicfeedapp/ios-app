//
//  MenuCell.m
//  botmusic
//
//  Created by Supervisor on 14.08.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "MenuCell.h"
#import <UIColor+Expanded.h>

static NSInteger const SUGGESTION_LABEL_OFFSET=250;

@implementation MenuCell

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
    self.badgeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.badgeButton setTitle:@"" forState:UIControlStateNormal];
    [self.badgeButton setBackgroundColor:[UIColor redColor]];
    [self.badgeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.badgeButton setUserInteractionEnabled:NO];
    [self.badgeButton.layer setCornerRadius:10.0f];
    [self.badgeButton.titleLabel sizeToFit];
    self.badgeButton.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame) - 60 - ((CGRectGetWidth(self.badgeButton.titleLabel.frame) + 7) > 21 ? (CGRectGetWidth(self.badgeButton.titleLabel.frame) + 7) : 21), 24, CGRectGetWidth(self.badgeButton.titleLabel.frame) + 7 > 21 ? CGRectGetWidth(self.badgeButton.titleLabel.frame) + 7 : 21, 21);
    [self.badgeButton setHidden:YES];
    [self.contentView addSubview:self.badgeButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted && self.delegate && [self.delegate respondsToSelector:@selector(didHighlightCellAtIndexPath:)]) {
        [self.delegate didHighlightCellAtIndexPath:self.indexPath];
    }
}

- (void)setIsProfileCell:(BOOL)isProfileCell
{
    if (isProfileCell) {
        [self.image.layer setCornerRadius:(self.image.frame.size.width / 2)];
        [self.image setClipsToBounds:YES];
        [self.image setHidden:NO];
    }
    else {
        [self.image.layer setCornerRadius:0.0f];
        [self.image setHidden:YES];
    }
    
    _isProfileCell = isProfileCell;
}

- (void)setIsSelected:(BOOL)isSelected
{
    if (isSelected) {
        [self.titleLabel setTextColor:[UIColor colorWithRGBHex:0xFFFFFF]];
    }
    else {
        [self.titleLabel setTextColor:[UIColor colorWithRGBHex:0x757575]];
    }
}

- (void)setSuggestionCount:(NSInteger)suggestionCount
{
    [self.suggestionCountLabel setHidden:NO];
    [self.suggestionCountLabel setText:[NSString stringWithFormat:@"%ld",(long)suggestionCount]];
    [self.suggestionCountLabel sizeToFit];
    
    CGRect frame=self.suggestionCountLabel.frame;
    frame.origin.x=SUGGESTION_LABEL_OFFSET-frame.size.width;
    [self.suggestionCountLabel setFrame:frame];
}

- (void)setBadgeNumber:(NSUInteger)number
{
    if (number > 0) {
        [self.badgeButton setTitle:[NSString stringWithFormat:@"%ld", (unsigned long)number] forState:UIControlStateNormal];
        [_badgeButton.titleLabel sizeToFit];
        _badgeButton.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame) - 10 - ((CGRectGetWidth(_badgeButton.titleLabel.frame) + 7) > 21 ? (CGRectGetWidth(_badgeButton.titleLabel.frame) + 7) : 21), 19, CGRectGetWidth(_badgeButton.titleLabel.frame) + 7 > 21 ? CGRectGetWidth(_badgeButton.titleLabel.frame) + 7 : 21, 21);
        [self.badgeButton setHidden:NO];
    }
    else {
        [self.badgeButton setHidden:YES];
    }
}

- (void)setTitle:(NSString *)title
{
    [self.titleLabel setText:title];
    [self.titleLabel sizeToFit];
    
    CGRect imageFrame = self.image.frame;
    imageFrame.origin.x = self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + 25.0f;
    [self.image setFrame:imageFrame];
    
    CGRect badgeFrame = self.badgeButton.frame;
    badgeFrame.origin.x = self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + 15.0f;
    [self.badgeButton setFrame:badgeFrame];
}

@end
