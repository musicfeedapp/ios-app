//
//  MFNotificationCell.m
//  botmusic
//
//  Created by Panda Systems on 9/10/15.
//
//

#import "MFNotificationCell.h"

@implementation MFNotificationCell

- (void)awakeFromNib {
    // Initialization code
    [self.avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbTapped:)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor* color = self.mySeparatorView.backgroundColor;
    [super setSelected:selected animated:animated];
    self.mySeparatorView.backgroundColor = color;
    // Configure the view for the selected state
}

- (void)thumbTapped:(id)sender {
    [self.delegate notificationCellDidTouchThumb:self];
}
@end
