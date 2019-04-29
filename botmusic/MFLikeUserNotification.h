//
//  MFLikeUserNotification.h
//  botmusic
//
//  Created by Panda Systems on 10/26/15.
//
//

#import "MFUserNotification.h"

@interface MFLikeUserNotification : MFUserNotification

@property(nonatomic, copy) NSString* trackID;
@property(nonatomic, copy) NSString* trackTitle;

@end
