//
//  ResultsTableHeaderView.m
//  botmusic
//
//  Created by Panda Systems on 1/22/15.
//
//

#import "ResultsTableHeaderView.h"

@implementation ResultsTableHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (ResultsTableHeaderView *)createResultsTableHeaderView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"ResultsTableHeaderView" owner:nil options:nil] lastObject];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
