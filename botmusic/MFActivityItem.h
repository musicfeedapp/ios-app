//
//  MFActivityItem.h
//  
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MFTrackItem;

@interface MFActivityItem : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * createdAtString;
@property (nonatomic, retain) NSString * eventableId;
@property (nonatomic, retain) NSString * eventableType;
@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) NSString * userAvatarUrl;
@property (nonatomic, retain) NSString * userExtId;
@property (nonatomic, retain) NSString * userFacebookId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) MFTrackItem *track;

@end
