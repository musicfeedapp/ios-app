//
//  MFCommentTableCell.h
//  botmusic
//
//  Created by Supervisor on 22.09.14.
//
//

#import "MGSwipeTableCell.h"
#import "MFCommentItem+Behavior.h"
#import "MFActivityItem+Behavior.h"
#import "MFCommentView.h"

@interface MFCommentTableCell : MGSwipeTableCell

- (void)setCommentInfo:(MFCommentItem *)commentItem;
- (void)setActivityInfo:(MFActivityItem *)activityItem;
- (void)setProposalInfo:(MFFollowItem *)followItem;
- (void)setShowAvatar:(BOOL)showAvatar;
- (void)setCommentDelegate:(id<MFCommentViewDelegate>)delegate;
- (void)setInitialPostDateInfo:(NSDictionary *)dictionary;

- (void)setSeparatorViewHidden:(BOOL)hidden;

+ (CGFloat)heightForComment:(MFCommentItem *)commentItem;
+ (CGFloat)heightForActivity:(MFActivityItem *)activityItem;

@end
