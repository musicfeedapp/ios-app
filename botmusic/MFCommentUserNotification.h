//
//  MFCommentUserNotification.h
//  botmusic
//

#import "MFUserNotification.h"

@interface MFCommentUserNotification : MFUserNotification

@property(nonatomic, copy) NSString* trackID;
@property(nonatomic, copy) NSString* trackTitle;

@property(nonatomic, copy) NSString* commentID;
@property(nonatomic, copy) NSString* commentText;

@end
