//
//  MFFeedOverlay.m
//  botmusic
//
//  Created by Panda Systems on 11/17/15.
//
//

#import "MFFeedOverlay.h"
#import "UIColor+Expanded.h"

@implementation MFFeedOverlay

- (void)awakeFromNib{
    [super awakeFromNib];
    self.gotItButton.layer.cornerRadius = 3.0;
    //self.gotItButton.layer.borderWidth = 1.0/[UIScreen mainScreen].scale;
    //self.gotItButton.layer.borderColor = [UIColor colorWithRGBHex:0x007AFF].CGColor;

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
