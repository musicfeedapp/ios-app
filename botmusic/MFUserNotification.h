//
//  MFUserNotification.h
//  botmusic
//
//  Created by Panda Systems on 10/26/15.
//
//

#import <Foundation/Foundation.h>

@interface MFUserNotification : NSManagedObject

@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, copy) NSString* identifier;
@property(nonatomic, copy) NSString* userExtID;
@property(nonatomic, copy) NSString* userID;
@property(nonatomic, copy) NSString* userName;
@property(nonatomic, copy) NSString* userPicture;
@property(nonatomic, copy) NSString* status;

+ (instancetype) newNotificationWithDictionary:(NSDictionary*)dictionary;
- (void) configureWithDictionary:(NSDictionary*)dictionary;

- (NSString *)createdTime;

- (BOOL)isRead;
- (BOOL)isSeen;
- (BOOL)isNotSeen;
@end
