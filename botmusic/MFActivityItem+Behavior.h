//
//  MFActivityItem+Behavior.h
//  botmusic
//

#import "MFActivityItem.h"

typedef NS_ENUM(NSUInteger, IRActivityType) {
    IRActivityTypeUserLike,
    IRActivityTypePlaylist,
    IRActivityTypeComment
};
@interface MFActivityItem (Behavior)

@property (nonatomic, strong, readonly) NSDate *createdAt;
@property (nonatomic, strong, readonly) NSString *postTime;
@property (nonatomic, strong, readonly) NSString *postTimeLongStyle;

@property (nonatomic, readonly) IRActivityType type;

- (id)configureWithDictionary: (NSDictionary*)dictionaryData;

@end
