//
//  MFProfileFollowCollectionViewCell.m
//  botmusic
//
//  Created by Panda Systems on 1/13/16.
//
//

#import "MFProfileFollowCollectionViewCell.h"

@implementation MFProfileFollowCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width/2.0;
}

- (IBAction)followButtonTapped:(id)sender {
    [self.delegate profileFollowCellDidSelectFollow:self];
}

@end
