//
//  MFNotificationManager.h
//  botmusic
//
//  Created by Dzmitry Navak on 05/12/14.
//
//

typedef NS_ENUM(NSUInteger, MFNotificationType) {
    MFNotificationTypeNotReachable,
    MFNotificationTypeCantLoad,
    MFNotificationTypeLoadingNextTrack,
    MFNotificationTypeUpdateBadgeNumber,
    MFNotificationTypeUpdatePlaylist,
    MFNotificationTypeUpdateUserFollowing,
    MFNotificationTypeStatusBarTapped,
    MFNotificationTypeRestoreTrack,
    MFNotificationTypeHidePlayer,
    MFNotificationTypeCommentsCountChanged,
    MFNotificationTypeAddedToPlaylist,
    MFNotificationTypeUserUnauthorized, 
    MFNotificationTypeUpdateLovedTracksPlaylist,
    MFNotificationTypeTrackLiked,
    MFNotificationTypeTrackDisliked,
    MFNotificationTypeUserInfoUpdated,
    MFNotificationTypeTrackStartedLoading,
    MFNotificationTypeTrackFinishedLoading,
    MFNotificationTypeHideTopError,
    MFNotificationTypeTrackLoagingTooLong
};

#import <UIKit/UIKit.h>

@class MFPlaylistItem;

@interface MFNotificationManager : UIButton

+ (NSString*)nameForNotification:(MFNotificationType)notification;
+ (void)postNetworkNotification;
+ (void)postCantLoadTrackNotification;
+ (void)postLoadingNextTrackNotification;
+ (void)postUpdateBadgeNumberNotification:(NSNumber *)number;
+ (void)postUpdatePlaylistNotification:(MFPlaylistItem *)playlist;
+ (void)postUpdateUserFollowingNotification:(MFUserInfo *)userInfo;
+ (void)postStatusBarTappedNotification;
+ (void)postRestoreTrackNotification;
+ (void)postHidePlayerNotification;
+ (void)postCommentsCountChangedNotification:(MFTrackItem *)item;
+ (void)postAddedToPlaylistNotification:(MFTrackItem *)item;
+ (void)postUserUnauthorizedNotification;
+ (void)postUpdateLovedTracksPlaylistNotification;
+ (void)postTrackLikedNotification:(MFTrackItem *)item;
+ (void)postTrackDislikedNotification:(MFTrackItem *)item;
+ (void)postUserInfoUpdatedNotification:(MFUserInfo *)userInfo;
+ (void)postTrackStartedLoadingNotification:(MFTrackItem *)item;
+ (void)postTrackFinishedLoadingNotification:(MFTrackItem *)item;
+ (void)postHideTopErrorNotification:(NSString*)errorString;
+ (void)postTrackLoagingTooLongNotification;
@end
