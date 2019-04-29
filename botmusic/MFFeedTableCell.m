//
//  MFFeedTableCell.m
//  botmusic
//
//  Created by Dzmitry Navak on 27/11/14.
//
//

#import "MFFeedTableCell.h"
#import "TrackView.h"

@interface MFFeedTableCell ()

//@property (nonatomic, strong) TrackView* trackView;
@end

@implementation MFFeedTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)initViews
{
    _trackView = [TrackView createTrackView];
    _trackView.correspondingCell = self;
    [_trackView configureButtons];
    [_trackView setTapEnable:YES];
    
    [self.contentView addSubview:_trackView];
}

@end
