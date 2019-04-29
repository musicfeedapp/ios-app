//
//  MFSeparatorView.m
//  botmusic
//
//  Created by Panda Systems on 9/8/15.
//
//

#import "MFSeparatorView.h"

@implementation MFSeparatorView

- (void) layoutSubviews{
    if (!self.isSetUp) {
        for (NSLayoutConstraint* constraint in self.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = 1.0/[UIScreen mainScreen].scale;
            }
        }
        self.isSetUp = YES;
    }
    [super layoutSubviews];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
