//
//  MFTrackTableCell.m
//  botmusic
//
//  Created by Supervisor on 28.09.14.
//
//

#import "MFTrackTableCell.h"
#import "MGSwipeButton.h"

@implementation MFTrackTableCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.trackView=[[[NSBundle mainBundle]loadNibNamed:@"MFTrackView" owner:nil options:nil]lastObject];
        [self.contentView addSubview:self.trackView];
        
        MGSwipeButton *button=[MGSwipeButton buttonWithTitle:@"Remove" backgroundColor:[UIColor selectedColor]];
        [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
        self.rightButtons = @[button];
        self.rightSwipeSettings.transition = MGSwipeTransitionStatic;
        
        NSLog(@"%@",button);
        
    }
    return self;
}

@end
