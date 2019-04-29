//
//  ResultsTableFooterView.m
//  botmusic
//
//  Created by Panda Systems on 1/23/15.
//
//

#import "ResultsTableFooterView.h"

@implementation ResultsTableFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (ResultsTableFooterView *)createResultsTableFooterView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"ResultsTableFooterView" owner:nil options:nil] lastObject];
}

#pragma mark - Button Touches

- (IBAction)didTouchUpMoreTracksButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMoreTracks:)]) {
        [self.delegate didSelectMoreTracks:self.section];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
