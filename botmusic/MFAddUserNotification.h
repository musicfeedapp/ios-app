//
//  MFAddUserNotification.h
//  botmusic
//

#import <Foundation/Foundation.h>
#import "MFUserNotification.h"

@interface MFAddUserNotification : MFUserNotification

@property(nonatomic, copy) NSString* playlistID;
@property(nonatomic, copy) NSString* playlistTitle;

@property(nonatomic, copy) NSString* trackID;
@property(nonatomic, copy) NSString* trackTitle;

@end
