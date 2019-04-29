//
//  MFCommentItem.h
//  
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MFTrackItem;

@interface MFCommentItem : NSManagedObject

@property (nonatomic, retain) NSString * autorAvatarUrl;
@property (nonatomic, retain) NSString * autorFacebookId;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * commentId;
@property (nonatomic, retain) NSString * creationTime;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * userExtId;
@property (nonatomic, retain) MFTrackItem *track;

@end
