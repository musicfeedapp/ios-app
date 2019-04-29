//
//  MFUserNotification.m
//  botmusic
//
//  Created by Panda Systems on 10/26/15.
//
//

#import "MFUserNotification.h"
#import "MFAddUserNotification.h"
#import "MFCommentUserNotification.h"
#import "MFFollowUserNotification.h"
#import "MFJoinUserNotification.h"
#import "MFLikeUserNotification.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MFArtistsAddedUserNotification.h"

@implementation MFUserNotification
@dynamic identifier;
@dynamic createdAt;
@dynamic userName;
@dynamic userExtID;
@dynamic userID;
@dynamic userPicture;
@dynamic status;

+ (instancetype) newNotificationWithDictionary:(NSDictionary*)dictionary{
    MFUserNotification* notification;
    if ([dictionary[@"alert_type"] isEqualToString:@"add_comment"]) {
        notification = [MFCommentUserNotification MR_createEntity];
        MFCommentUserNotification* notif = (MFCommentUserNotification*)notification;
        notif.commentID = [[dictionary validObjectForKey:@"comment"] makeStringForKey:@"id"];
        notif.commentText = [[dictionary validObjectForKey:@"comment"] makeStringForKey:@"comment"];

        notif.trackID = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"id"];
        notif.trackTitle = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"name"];

    } else if ([dictionary[@"alert_type"] isEqualToString:@"like"]) {
        notification = [MFLikeUserNotification MR_createEntity];
        MFLikeUserNotification* notif = (MFLikeUserNotification*)notification;

        notif.trackID = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"id"];
        notif.trackTitle = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"name"];
    } else if ([dictionary[@"alert_type"] isEqualToString:@"follow"]) {
        notification = [MFFollowUserNotification MR_createEntity];

    } else if ([dictionary[@"alert_type"] isEqualToString:@"add_to_playlist"]) {
        notification = [MFAddUserNotification MR_createEntity];
        MFAddUserNotification* notif = (MFAddUserNotification*)notification;
        
        notif.trackID = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"id"];
        notif.trackTitle = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"name"];

        notif.playlistID = [[dictionary validObjectForKey:@"playlist"] makeStringForKey:@"id"];
        notif.playlistTitle = [[dictionary validObjectForKey:@"playlist"] makeStringForKey:@"title"];
    } else if ([dictionary[@"alert_type"] isEqualToString:@"user_joined"]) {
        notification = [MFJoinUserNotification MR_createEntity];
    } else if ([dictionary[@"alert_type"] isEqualToString:@"artist_added"]) {
        notification = [MFArtistsAddedUserNotification MR_createEntity];
        ((MFArtistsAddedUserNotification*)notification).count = [[dictionary objectForKey:@"artists_count"] intValue];
        ((MFArtistsAddedUserNotification*)notification).artists = [NSOrderedSet orderedSetWithArray: [dataManager convertAndAddUserInfosToDatabase:dictionary[@"recently_added_artists"] userInfoType:MFUserInfoTypeImportedArtists]];
    }

    notification.userExtID = [[dictionary validObjectForKey:@"user"] makeStringForKey:@"ext_id"];
    notification.userID = [[dictionary validObjectForKey:@"user"] makeStringForKey:@"id"];
    notification.userName = [[dictionary validObjectForKey:@"user"] makeStringForKey:@"name"];
    notification.userPicture = [[dictionary validObjectForKey:@"user"] makeStringForKey:@"profile_image"];
    notification.status = [dictionary makeStringForKey:@"status"];
    NSString* timestampString = [dictionary validObjectForKey:@"created_at"];
    if(timestampString){
        NSDateFormatter* formatter = [MFTrackItem dateFormatter];
        NSDate* gmtDate = [formatter dateFromString:timestampString];
        NSInteger seconds = [[NSTimeZone localTimeZone] secondsFromGMTForDate: gmtDate];
        notification.createdAt = [NSDate dateWithTimeInterval: seconds sinceDate: gmtDate];
    }

    notification.identifier = [dictionary makeStringForKey:@"id"];
    return notification;
}

- (NSString *)createdTime {
    return [self.createdAt timeAgo];
}

- (BOOL)isRead{
    return [self.status isEqual:@"read"];
}

- (BOOL)isSeen{
    return [self.status isEqual:@"seen"];
}

- (BOOL)isNotSeen{
    return [self.status isEqual:@"new"];
}

- (void) configureWithDictionary:(NSDictionary*)dictionary{
    if ([dictionary[@"alert_type"] isEqualToString:@"add_comment"] && [self isKindOfClass:[MFCommentUserNotification class]]) {
        MFCommentUserNotification* notif = (MFCommentUserNotification*)self;
        notif.commentID = [[dictionary validObjectForKey:@"comment"] makeStringForKey:@"id"];
        notif.commentText = [[dictionary validObjectForKey:@"comment"] makeStringForKey:@"comment"];

        notif.trackID = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"id"];
        notif.trackTitle = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"name"];

    } else if ([dictionary[@"alert_type"] isEqualToString:@"like"] && [self isKindOfClass:[MFLikeUserNotification class]]) {
        MFLikeUserNotification* notif = (MFLikeUserNotification*)self;

        notif.trackID = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"id"];
        notif.trackTitle = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"name"];
    } else if ([dictionary[@"alert_type"] isEqualToString:@"follow"]) {

    } else if ([dictionary[@"alert_type"] isEqualToString:@"add_to_playlist"] && [self isKindOfClass:[MFAddUserNotification class]]) {
        MFAddUserNotification* notif = (MFAddUserNotification*)self;

        notif.trackID = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"id"];
        notif.trackTitle = [[dictionary validObjectForKey:@"timeline"] makeStringForKey:@"name"];

        notif.playlistID = [[dictionary validObjectForKey:@"playlist"] makeStringForKey:@"id"];
        notif.playlistTitle = [[dictionary validObjectForKey:@"playlist"] makeStringForKey:@"title"];
    } else if ([dictionary[@"alert_type"] isEqualToString:@"user_joined"]) {

    } else if ([dictionary[@"alert_type"] isEqualToString:@"artist_added"] && [self isKindOfClass:[MFArtistsAddedUserNotification class]]) {
        ((MFArtistsAddedUserNotification*)self).count = [[dictionary objectForKey:@"artists_count"] intValue];

    }

    self.userExtID = [[dictionary validObjectForKey:@"user"] makeStringForKey:@"ext_id"];
    self.userID = [[dictionary validObjectForKey:@"user"] makeStringForKey:@"id"];
    self.userName = [[dictionary validObjectForKey:@"user"] makeStringForKey:@"name"];
    self.userPicture = [[dictionary validObjectForKey:@"user"] makeStringForKey:@"profile_image"];
    self.status = [dictionary makeStringForKey:@"status"];
    NSString* timestampString = [dictionary validObjectForKey:@"created_at"];
    if(timestampString){
        NSDateFormatter* formatter = [MFTrackItem dateFormatter];
        NSDate* gmtDate = [formatter dateFromString:timestampString];
        NSInteger seconds = [[NSTimeZone localTimeZone] secondsFromGMTForDate: gmtDate];
        self.createdAt = [NSDate dateWithTimeInterval: seconds sinceDate: gmtDate];
    }
}

@end
