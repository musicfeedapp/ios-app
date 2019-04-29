//
//  MFUserInfoService.m
//  botmusic
//
//  Created by vm-macos on 1/26/15.
//
//

#import "MFUserInfoService.h"
#import "IRNetworkClient.h"

@interface MFUserInfoService ()
@property(nonatomic, strong) NSString* username;
@end

@implementation MFUserInfoService

#pragma mark - setting up methodth
- (MFUserInfoService*)initWithUsername:(NSString*)username
{
    self = [super init];
    if (self != nil) {
        _username = username;
    }
    return self;
}

- (IRNetworkClient*) networkClient
{
    if (_networkClient != nil) {
        return _networkClient;
    }
    
    _networkClient = [IRNetworkClient sharedInstance];
    return _networkClient;
}

#pragma mark    - data methods

- (void)userProfileInfoWithCompletion:(void(^)(NSError* error, MFUserInfo* info))completion
{
    [_networkClient userProfileWithUsername:_username
                                                successBlock:^(NSDictionary *dictionary)
     {
         //[self.scrollView.pullToRefreshView stopAnimating];
         
         MFUserInfo *userInfo = [[dataManager getUserInfoInContextbyExtID:dictionary[@"ext_id"]] configureWithDictionary:dictionary anotherUser:YES];
        
         completion(nil, userInfo);
     }
                                                failureBlock:^(NSString *errorMessage)
     {
         completion([NSError errorWithDomain:@"MFServiceErrorDomain" code:1 userInfo:@{@"message": errorMessage}], nil);
     }];
}


@end
