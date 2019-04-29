//
//  ImportArtistTableCell.m
//  botmusic
//

#import "ImportArtistTableCell.h"

@implementation ImportArtistTableCell

- (void)awakeFromNib {
    self.artistImageView.layer.cornerRadius = self.artistImageView.frame.size.width/2;
    self.artistImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTouchUpCheckBoxButton:(id)sender
{
    [self.checkBoxButton setSelected:!self.checkBoxButton.isSelected];
}

@end
