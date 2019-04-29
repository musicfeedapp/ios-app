//
//  MFTabBarViewController.h
//  botmusic
//
//  Created by Panda Systems on 11/13/15.
//
//

#import <UIKit/UIKit.h>

@interface MFTabBarViewController : UITabBarController

- (void) switchToLoggedInState;
- (void) switchToAnonymousState;
- (void) navigateToSuggestions;
@end
