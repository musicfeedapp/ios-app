//
//  MFPremiumProfileViewController.h
//  botmusic
//
//  Created by Panda Systems on 1/12/16.
//
//

#import "AbstractViewController.h"

@interface MFPremiumProfileViewController : AbstractViewController

@property (nonatomic, strong) MFUserInfo* userInfo;
- (void) reloadProfileData;

@end
