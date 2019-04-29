//
//  MFNewProfileViewController.h
//  botmusic
//
//  Created by Panda Systems on 1/29/15.
//
//

#import <UIKit/UIKit.h>

@interface MFNewProfileViewController : AbstractViewController

@property (nonatomic, strong) MFUserInfo* userInfo;
- (void) reloadProfileData;

@end
