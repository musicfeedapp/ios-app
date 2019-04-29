//
//  MFDeepLinkingManager.h
//  botmusic
//

#import <Foundation/Foundation.h>

@interface MFDeepLinkingManager : NSObject

+(void) performDeepLinking;
+(void) setPushNotification:(NSDictionary*) pushNotification;

@end
