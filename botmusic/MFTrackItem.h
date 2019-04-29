//
//  MFTrackItem.h
//  
//
//  Created by Panda Systems on 4/25/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MFActivityItem, MFCommentItem, MFPlaylistItem, MFUserInfo;

@interface MFTrackItem : NSManagedObject

@property (nonatomic, retain) NSString * album;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * authorExtId;
@property (nonatomic, retain) NSString * authorId;
@property (nonatomic, assign) BOOL authorIsFollowed;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * authorPicture;
@property (nonatomic, retain) NSNumber * comments;
@property (nonatomic, assign) BOOL  facebookShared;
@property (nonatomic, assign) BOOL favourite;
@property (nonatomic, retain) NSString * fontColor;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) BOOL isPlayed;
@property (nonatomic, assign) BOOL isVerifiedUser;
@property (nonatomic, assign) BOOL isRemovedFromFeed;
@property (nonatomic, assign) BOOL isNotPosted;
@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) NSString * iTunesLink;
@property (nonatomic, retain) NSDate * lastActivityTime;
@property (nonatomic, retain) NSDate * lastFeedAppearanceDate;
@property (nonatomic, retain) NSString * lastActivityType;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * stream;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * timestampString;
@property (nonatomic, retain) NSString * trackName;
@property (nonatomic, retain) NSString * trackPicture;
@property (nonatomic, retain) NSNumber * trackState_n;
@property (nonatomic, assign) BOOL twitterShared;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * youtubeDirectLink;
@property (nonatomic, retain) NSString * youtubeLink;
@property (nonatomic, retain) NSSet *activities;
@property (nonatomic, retain) NSSet *allComments;
@property (nonatomic, retain) NSSet *belongToPlaylists;
@property (nonatomic, retain) NSSet *belongToUsers;
@property (nonatomic, retain) NSSet *belongToSuggestions;
@property (nonatomic, retain) NSSet *trendingTracks_inverse;

@property (nonatomic, retain) NSDate *lastPlayedDate;
@property (nonatomic, assign) BOOL isFeedTrack;
@end

@interface MFTrackItem (CoreDataGeneratedAccessors)

- (void)addActivitiesObject:(MFActivityItem *)value;
- (void)removeActivitiesObject:(MFActivityItem *)value;
- (void)addActivities:(NSSet *)values;
- (void)removeActivities:(NSSet *)values;

- (void)addAllCommentsObject:(MFCommentItem *)value;
- (void)removeAllCommentsObject:(MFCommentItem *)value;
- (void)addAllComments:(NSSet *)values;
- (void)removeAllComments:(NSSet *)values;

- (void)addBelongToPlaylistsObject:(MFPlaylistItem *)value;
- (void)removeBelongToPlaylistsObject:(MFPlaylistItem *)value;
- (void)addBelongToPlaylists:(NSSet *)values;
- (void)removeBelongToPlaylists:(NSSet *)values;

- (void)addBelongToUsersObject:(MFUserInfo *)value;
- (void)removeBelongToUsersObject:(MFUserInfo *)value;
- (void)addBelongToUsers:(NSSet *)values;
- (void)removeBelongToUsers:(NSSet *)values;

@end
