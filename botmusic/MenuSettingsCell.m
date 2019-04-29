//
//  MenuSettingsCell.m
//  botmusic
//

#import "MenuSettingsCell.h"
#import <UIColor+Expanded.h>

@interface MenuSettingsCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation MenuSettingsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        [self.titleLabel setTextColor:[UIColor colorWithRGBHex:0xFFFFFF]];
    } else {
        [self.titleLabel setTextColor:[UIColor colorWithRGBHex:0x757575]];
    }
}

@end
