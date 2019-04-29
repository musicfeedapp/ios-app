//
//  MFEmailTableViewCell.m
//  botmusic
//
//  Created by Panda Systems on 9/11/15.
//
//

#import "MFEmailTableViewCell.h"

@implementation MFEmailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor* c = _separator.backgroundColor;
    [super setSelected:selected animated:animated];
    _separator.backgroundColor = c;
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    UIColor* c = _separator.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    _separator.backgroundColor = c;
}
@end
