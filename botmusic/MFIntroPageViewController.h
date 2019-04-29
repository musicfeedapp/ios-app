//
//  MFIntroPageViewController.h
//  botmusic
//
//  Created by Panda Systems on 8/10/15.
//
//

#import <UIKit/UIKit.h>
#import "MFIntroViewController.h"

@interface MFIntroPageViewController : UIViewController
@property NSInteger number;
@property(nonatomic, strong) NSTimer* actionTimer;
@property(nonatomic, weak) MFIntroViewController* introViewController;
@end
