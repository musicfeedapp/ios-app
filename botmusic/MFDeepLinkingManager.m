//
//  MFDeepLinkingManager.m
//  botmusic
//

#import "MFDeepLinkingManager.h"
#import "FeedViewController.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MenuViewController.h"


@implementation MFDeepLinkingManager

+(void) performDeepLinking{
    NSDictionary* pushNotification = [[NSUserDefaults standardUserDefaults] objectForKey:@"applicationOpenedFromPushNotification"];
    if (pushNotification) {
        UIViewController* topViewController = [self topViewController];

        if ([topViewController isKindOfClass:[AbstractViewController class]]){
            
            if ([pushNotification[@"event_type"] isEqualToString:@"like"] || [pushNotification[@"event_type"] isEqualToString:@"add_comment"]) {
                NSString* itemID = [NSString stringWithFormat:@"%@", pushNotification[@"track_id"]];
                MFTrackItem* track = [MFTrackItem MR_findFirstByAttribute:@"itemId" withValue:itemID];
                if (track){
                    [(AbstractViewController*)topViewController shouldOpenTrackInfo:track];
                }
            }
            
            else if ([pushNotification[@"event_type"] isEqualToString:@"follow"]){
                NSString* extID = pushNotification[@"ext_id"];
                MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:extID];
                [(AbstractViewController*)topViewController showUserProfileWithUserInfo:userInfo];
                
            }
            
            else if ([pushNotification[@"event_type"] isEqualToString:@"add_to_playlist"]){
                NSString* extID = pushNotification[@"user_ext_id"];
                NSString* playlistID = [NSString stringWithFormat:@"%@", pushNotification[@"playlist_id"]];
                MFUserInfo* userInfo = [dataManager getUserInfoInContextbyExtID:extID];
                MFPlaylistItem* playlist = [dataManager getPlaylistInContextbyID:playlistID];
                [(AbstractViewController*)topViewController shouldOpenPlaylist:playlist ofUser:userInfo];
            }
                
        }
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"applicationOpenedFromPushNotification"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(void) setPushNotification:(NSDictionary*) pushNotification{
    if(pushNotification)
    {
        [[NSUserDefaults standardUserDefaults] setObject:pushNotification forKey:@"applicationOpenedFromPushNotification"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"applicationOpenedFromPushNotification"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(UIViewController*) topViewController{
    UIViewController* topViewController = [(AppDelegate*)[[UIApplication sharedApplication] delegate] topViewController];
    return topViewController;
}
@end
