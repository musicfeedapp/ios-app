//
//  MFNavigationBar.m
//  botmusic
//
//  Created by Panda Systems on 2/9/15.
//
//

#import "MFNavigationBar.h"

@implementation MFNavigationBar

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    UINavigationItem *navigationItem = [self topItem];
    
    UIView *subview = [[navigationItem rightBarButtonItem] customView];
    
    if (subview) {
        CGRect subviewFrame = subview.frame;
        subviewFrame.origin.x = self.frame.size.width - 35.0f;
        subviewFrame.origin.y = 7.0f;
        subviewFrame.size.width = 30.0f;
        subviewFrame.size.height = 30.0f;
        
        [subview setFrame:subviewFrame];
    }
    
    subview = [[navigationItem leftBarButtonItem] customView];
    
    if (subview) {
        CGRect subviewFrame = subview.frame;
        subviewFrame.origin.x = 5.0f;
        subviewFrame.origin.y = 5.0f;
        subviewFrame.size.width = 30.0f;
        subviewFrame.size.height = 30.0f;
        
        [subview setFrame:subviewFrame];
    }
}

@end
