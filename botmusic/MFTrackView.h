//
//  MFTrackView.h
//  botmusic
//
//  Created by Supervisor on 28.09.14.
//
//

#import <UIKit/UIKit.h>
#import "MFTrackItem+Behavior.h"
#import "ActionView.h"
#import "ActionViewCreator.h"
#import "TrackView.h"

@interface MFTrackView : UIView<ActionViewDelegate>

@property (nonatomic, weak) id <TrackViewDelegate> delegate;

@property (nonatomic, strong) NSIndexPath* indexPath;

@property (nonatomic, copy)NSString *trackLink;

@property (nonatomic, assign)BOOL isLiked;

@property (nonatomic, strong)ActionView *actionView;

- (IBAction)didSelectShare:(id)sender;
- (IBAction)didSelectLike:(id)sender;
- (IBAction)didSelectComment:(id)sender;

- (void)setTrackInfo:(MFTrackItem*)trackItem;

@end
