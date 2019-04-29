//
//  MFUserInfoService.h
//  botmusic
//
//  Created by vm-macos on 1/26/15.
//
//

#import <Foundation/Foundation.h>

@interface MFUserInfoService : NSObject

@property (nonatomic, strong) IRNetworkClient* networkClient;

- (MFUserInfoService*)initWithUsername:(NSString*)username;
- (void)userProfileInfoWithCompletion:(void(^)(NSError* error, MFUserInfo* info))completion;

@end
