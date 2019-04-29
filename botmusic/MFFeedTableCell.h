//
//  MFFeedTableCell.h
//  botmusic
//
//  Created by Dzmitry Navak on 27/11/14.
//
//

#import "MGSwipeTableCell+PanHandler.h"
#import <UIColor+Expanded.h>
@class TrackView;

@interface MFFeedTableCell : MGSwipeTableCell

@property (nonatomic, strong) TrackView* trackView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
