//
//  MFCommentView.h
//  botmusic
//
//  Created by Supervisor on 22.09.14.
//
//

#import <UIKit/UIKit.h>

@class MFUserInfo;
@class MFCommentItem;
@class MFActivityItem;

@protocol MFCommentViewDelegate <NSObject>

- (void)shouldOpenUserProfileWithUserInfo:(MFUserInfo *)userInfo;

@end

@interface MFCommentView : UIView

@property (nonatomic, weak) id<MFCommentViewDelegate> delegate;

- (void)setCommentInfo:(MFCommentItem *)commentItem;
- (void)setActivityInfo:(MFActivityItem *)activityItem;
- (void)setProposalInfo:(MFFollowItem *)followItem;
- (void)setInitialPostDateInfo:(NSDictionary *)dictionary;

- (void)setSeparatorViewHidden:(BOOL)hidden;

+ (CGFloat)heightForComment:(MFCommentItem *)commentItem;
+ (CGFloat)heightForActivity:(MFActivityItem *)activityItem;

@end
