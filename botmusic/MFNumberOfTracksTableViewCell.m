//
//  MFNumberOfTracksTableViewCell.m
//  botmusic
//
//  Created by Panda Systems on 9/4/15.
//
//

#import "MFNumberOfTracksTableViewCell.h"

@implementation MFNumberOfTracksTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.separatorHeight.constant = 1.0/[UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
