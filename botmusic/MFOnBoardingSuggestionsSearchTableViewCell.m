//
//  MFOnBoardingSuggestionsSearchTableViewCell.m
//  botmusic
//
//  Created by Panda Systems on 8/26/15.
//
//

#import "MFOnBoardingSuggestionsSearchTableViewCell.h"

@implementation MFOnBoardingSuggestionsSearchTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.separatorHeight.constant = 1.0/[UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
