//
//  MFNotificationManager.m
//  botmusic
//
//  Created by Dzmitry Navak on 05/12/14.
//
//

#import "MFNotificationManager.h"

@implementation MFNotificationManager

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString*)nameForNotification:(MFNotificationType)notification
{
    switch (notification) {
        case MFNotificationTypeNotReachable:
            return @"MFNotificationTypeNotReachable";
            break;
            
        case MFNotificationTypeCantLoad:
            return @"MFNotificationTypeCantLoad";
            break;
            
        case MFNotificationTypeLoadingNextTrack:
            return @"MFNotificationTypeLoadingNextTrack";
            break;
            
        case MFNotificationTypeUpdateBadgeNumber:
            return @"MFNotificationTypeUpdateBadgeNumber";
            break;
            
        case MFNotificationTypeUpdatePlaylist:
            return @"MFNotificationTypeUpdatePlaylist";
            break;
            
        case MFNotificationTypeUpdateUserFollowing:
            return @"MFNotificationTypeUpdateUserFollowing";
            break;
            
        case MFNotificationTypeStatusBarTapped:
            return @"MFNotificationTypeStatusBarTapped";
            break;
            
        case MFNotificationTypeRestoreTrack:
            return @"MFNotificationTypeRestoreTrack";
            break;
            
        case MFNotificationTypeHidePlayer:
            return @"MFNotificationHidePlayer";
            break;
            
        case MFNotificationTypeAddedToPlaylist:
            return @"MFNotificationAddedToPlaylist";
            break;

        case MFNotificationTypeCommentsCountChanged:
            return @"MFNotificationTypeCommentsCountChanged";
            break;
            
        case MFNotificationTypeUserUnauthorized:
            return @"MFNotificationTypeUserUnauthorized";
            break;

        case MFNotificationTypeUpdateLovedTracksPlaylist:
            return @"MFNotificationUpdateLovedTracksPlaylist";
            break;
            
        case MFNotificationTypeTrackLiked:
            return @"MFNotificationTypeTrackLiked";
            break;
            
        case MFNotificationTypeTrackDisliked:
            return @"MFNotificationTypeTrackDisliked";
            break;
            
        case MFNotificationTypeUserInfoUpdated:
            return @"MFNotificationTypeUserInfoUpdated";
            break;
            
        case MFNotificationTypeTrackStartedLoading:
            return @"MFNotificationTypeTrackStartedLoading";
            break;
            
        case MFNotificationTypeTrackFinishedLoading:
            return @"MFNotificationTypeTrackFinishedLoading";
            break;
            
        case MFNotificationTypeHideTopError:
            return @"MFNotificationTypeHideTopError";
            break;
            
        case MFNotificationTypeTrackLoagingTooLong:
            return @"MFNotificationTypeTrackLoagingTooLong";
            
        default:
            break;
    }
}

+ (void)postNetworkNotification
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeNotReachable];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"description": NSLocalizedString(@"No Internet Connection",nil)}];
}
+ (void)postCantLoadTrackNotification
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeCantLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"description": NSLocalizedString(@"Cannot load track",nil)}];
}
+ (void)postLoadingNextTrackNotification
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeLoadingNextTrack];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"description": NSLocalizedString(@"Loading next track",nil)}];
}
+ (void)postUpdateBadgeNumberNotification:(NSNumber *)number
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeUpdateBadgeNumber];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"number": number}];
}
+ (void)postUpdatePlaylistNotification:(MFPlaylistItem *)playlist
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeUpdatePlaylist];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"playlist": playlist}];
}
+ (void)postUpdateUserFollowingNotification:(MFUserInfo *)userInfo
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeUpdateUserFollowing];
    NSDictionary* info;
    if (userInfo) {
        info = @{@"user_info": userInfo};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:info];
}
+ (void)postStatusBarTappedNotification
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeStatusBarTapped];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
}
+ (void)postRestoreTrackNotification
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeRestoreTrack];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
}

+ (void)postHidePlayerNotification
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeHidePlayer];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
}

+ (void)postCommentsCountChangedNotification:(MFTrackItem *)item
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeCommentsCountChanged];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"trackID": item.itemId}];
}

+ (void)postAddedToPlaylistNotification:(MFTrackItem *)item
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeAddedToPlaylist];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"trackID": item.itemId}];
}

+ (void)postUserUnauthorizedNotification
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeUserUnauthorized];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
}

+ (void)postUpdateLovedTracksPlaylistNotification
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeUpdateLovedTracksPlaylist];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
}

+ (void)postTrackLikedNotification:(MFTrackItem *)item
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeTrackLiked];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"trackID": item.itemId}];
}

+ (void)postTrackDislikedNotification:(MFTrackItem *)item
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeTrackDisliked];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"trackID": item.itemId}];
}

+ (void)postUserInfoUpdatedNotification:(MFUserInfo *)userInfo
{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeUserInfoUpdated];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"user_info": userInfo}];
}

+ (void)postTrackStartedLoadingNotification:(MFTrackItem *)item{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeTrackStartedLoading];
    if(item) [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"trackID": item.itemId}];
}

+ (void)postTrackFinishedLoadingNotification:(MFTrackItem *)item{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeTrackFinishedLoading];
    if(item) [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"trackID": item.itemId}];
}
+ (void)postHideTopErrorNotification:(NSString*) errorString{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeHideTopError];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:@{@"error" : errorString}];
}

+ (void)postTrackLoagingTooLongNotification{
    NSString* notificationName = [self nameForNotification:MFNotificationTypeTrackLoagingTooLong];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
}

@end
