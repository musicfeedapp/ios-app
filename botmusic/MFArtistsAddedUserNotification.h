//
//  MFArtistsAddedUserNotification.h
//  botmusic
//

#import "MFUserNotification.h"

@interface MFArtistsAddedUserNotification : MFUserNotification
@property (nonatomic) int16_t count;
@property (nonatomic, retain) NSOrderedSet *artists;
@end
