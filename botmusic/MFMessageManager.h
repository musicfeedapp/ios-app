//
//  MFMessageManager.h
//  botmusic
//
//  Created by Panda Systems on 2/16/16.
//
//

#import <Foundation/Foundation.h>

@interface MFMessageManager : NSObject

+ (instancetype)sharedInstance;

- (void)showNetworkErrorMessageInViewController:(UIViewController*)controller;
- (void)showTrackAddedMessageInViewController:(UIViewController*)controller;
- (void)showProfileUpdatedMessageInViewController:(UIViewController*)controller;
- (void)showTrackRepostedMessageInViewController:(UIViewController*)controller;
- (void)showProblemWithNetworkMessageInViewController:(UIViewController*)controller;
- (void)showCantLoadTrackMessageInViewController:(UIViewController*)controller;
- (void)showSpotifyUpgradeMessageInViewController:(UIViewController*)controller;
- (void)showNoInternetConnectionInViewController:(UIViewController*)controller;
- (void)checkReachability:(UIViewController*)controller;
- (void)showErrorMessage:(NSString*)message inViewController:(UIViewController*)controller;

@property (nonatomic) BOOL statusBarShouldBeHidden;

@end
