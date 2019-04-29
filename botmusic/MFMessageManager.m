//
//  MFMessageManager.m
//  botmusic
//
//  Created by Panda Systems on 2/16/16.
//
//

#import "MFMessageManager.h"
#import "TSMessage.h"
#import "TSMessageView.h"

@interface MFMessageManager () <TSMessageViewProtocol>

@end

@implementation MFMessageManager

+ (instancetype)sharedInstance
{
    static MFMessageManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [TSMessage setDelegate:sharedInstance];
        [sharedInstance setReachabilityNotifications];
    });
    return sharedInstance;
}

- (void)customizeMessageView:(TSMessageView *)messageView{
    //messageView.titleLabel.center = CGPointMake(messageView.center.x, messageView.titleLabel.center.y);
}

- (void)setReachabilityNotifications {
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    [networkReachability startNotifier];
}

- (void)checkReachability:(UIViewController*)controller
{
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable && ![MFErrorManager sharedInstance].isErrorMessageHidden) {
        [self showNoInternetConnectionInViewController:controller];
    } else {

    }
}

- (void)reachabilityChanged:(NSNotification *) notification
{
    Reachability *reachability = [notification object];
    if ([reachability isReachable]) {
        [MFErrorManager sharedInstance].isErrorMessageHidden = NO;
        [self connectionReachable];
    }
    else {
        [MFErrorManager sharedInstance].isErrorMessageHidden = NO;
        [self connectionNotReachable];
    }
}

- (void) connectionReachable{
    [TSMessage dismissActiveNoInternetConnectionNotificationWithConnectedMessage];
}

- (void) connectionNotReachable{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFNoInternetConnection" object:nil];
}

- (void)showNetworkErrorMessageInViewController:(UIViewController*)controller{
    Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return;
    }
    [TSMessage showNotificationInViewController:controller title:NSLocalizedString(@"Oops, something went wrong",nil) subtitle:nil type:TSMessageNotificationTypeWarning duration:2.0];

}

- (void)showTrackAddedMessageInViewController:(UIViewController*)controller{
    [TSMessage showNotificationInViewController:controller title:NSLocalizedString(@"Track added!",nil) subtitle:nil type:TSMessageNotificationTypeSuccess duration:2.0];
}

- (void)showProfileUpdatedMessageInViewController:(UIViewController*)controller{
    [TSMessage showNotificationInViewController:controller title:NSLocalizedString(@"Profile updated!",nil) subtitle:nil type:TSMessageNotificationTypeSuccess duration:2.0];
}

- (void)showTrackRepostedMessageInViewController:(UIViewController*)controller{
    [TSMessage showNotificationInViewController:controller title:NSLocalizedString(@"Track reposted!",nil) subtitle:nil type:TSMessageNotificationTypeSuccess duration:2.0];
}

- (void)showProblemWithNetworkMessageInViewController:(UIViewController*)controller{
    [TSMessage showNotificationInViewController:controller title:NSLocalizedString(@"There is a problem with your network",nil) subtitle:nil type:TSMessageNotificationTypeWarning duration:2.0];
}

- (void)showCantLoadTrackMessageInViewController:(UIViewController*)controller{
    [TSMessage showNotificationInViewController:controller title:NSLocalizedString(@"Cannot load track",nil) subtitle:nil type:TSMessageNotificationTypeWarning duration:2.0];
}

- (void)showSpotifyUpgradeMessageInViewController:(UIViewController*)controller{
    [TSMessage showNotificationInViewController:controller title:NSLocalizedString(@"You need Spotify Premium to stream this track",nil) subtitle:nil type:TSMessageNotificationTypeWarning duration:2.0];
}

- (void)showNoInternetConnectionInViewController:(UIViewController*)controller{
//    [TSMessage showNotificationInViewController:controller title:NSLocalizedString(@"No internet connection",nil) subtitle:nil type:TSMessageNotificationTypeWarning duration:2.5];
    [TSMessage showNotificationInViewController:controller title:NSLocalizedString(@"No internet connection",nil) subtitle:nil image:nil type:TSMessageNotificationTypeWarning duration:TSMessageNotificationDurationEndless callback:^{
        [MFErrorManager sharedInstance].isErrorMessageHidden = YES;
        [TSMessage dismissActiveNotification];
    } buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:YES];
}

- (void)showErrorMessage:(NSString*)message inViewController:(UIViewController*)controller{
    if (message) {
        [TSMessage showNotificationInViewController:controller title:message subtitle:nil type:TSMessageNotificationTypeWarning duration:2.0];
    } else {
        [self showNetworkErrorMessageInViewController:controller];
    }
}
@end
