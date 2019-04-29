//
//  MFUserInfo.h
//  
//
//  Created by Panda Systems on 4/27/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MFFollowItem, MFPlaylistItem, MFTrackItem;

@interface MFUserInfo : NSManagedObject

@property (nonatomic, retain) NSString * background;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * extId;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSString * facebookLink;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic) int32_t playlistsCount;
@property (nonatomic) int32_t followedCount;
@property (nonatomic) int32_t followingsCount;
@property (nonatomic) BOOL isAnotherUser;
@property (nonatomic) BOOL isArtist;
@property (nonatomic) BOOL isFacebookExpired;
@property (nonatomic) BOOL isFollowed;
@property (nonatomic) BOOL isVerified;
@property (nonatomic) BOOL isUserInfoFullyLoaded;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * profileImage;
@property (nonatomic) int32_t songsCount;
@property (nonatomic) int32_t suggestionsCount;
@property (nonatomic) int32_t timelineCount;
@property (nonatomic, retain) NSString * username;

@property (nonatomic, retain) NSData * secondaryEmails_d;
@property (nonatomic, retain) NSData * secondaryPhones_d;
@property (nonatomic, retain) NSData * recentSearches_d;

@property (nonatomic, retain) NSOrderedSet *followed;
@property (nonatomic, retain) NSOrderedSet *followingArtists;
@property (nonatomic, retain) NSOrderedSet *followingFriends;
@property (nonatomic, retain) MFFollowItem *myFollowItem;
@property (nonatomic, retain) NSOrderedSet *playlists;
@property (nonatomic, retain) NSSet *tracks;
@property (nonatomic, retain) NSOrderedSet *suggestions;
@property (nonatomic, retain) NSOrderedSet *trendingArtists;
@property (nonatomic, retain) NSOrderedSet *trendingTracks;

@property (nonatomic, retain) NSOrderedSet *contacts;
@property (nonatomic, retain) NSOrderedSet *facebookFriends;
@property (nonatomic, retain) NSOrderedSet *importedArtists;

@property (nonatomic, retain) NSSet *contacts_inverse;
@property (nonatomic, retain) NSSet *facebookFriends_inverse;
@property (nonatomic, retain) NSSet *importedArtists_inverse;


@end

@interface MFUserInfo (CoreDataGeneratedAccessors)

- (void)insertObject:(MFFollowItem *)value inFollowedAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFollowedAtIndex:(NSUInteger)idx;
- (void)insertFollowed:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFollowedAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFollowedAtIndex:(NSUInteger)idx withObject:(MFFollowItem *)value;
- (void)replaceFollowedAtIndexes:(NSIndexSet *)indexes withFollowed:(NSArray *)values;
- (void)addFollowedObject:(MFFollowItem *)value;
- (void)removeFollowedObject:(MFFollowItem *)value;
- (void)addFollowed:(NSOrderedSet *)values;
- (void)removeFollowed:(NSOrderedSet *)values;
- (void)insertObject:(MFFollowItem *)value inFollowingArtistsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFollowingArtistsAtIndex:(NSUInteger)idx;
- (void)insertFollowingArtists:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFollowingArtistsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFollowingArtistsAtIndex:(NSUInteger)idx withObject:(MFFollowItem *)value;
- (void)replaceFollowingArtistsAtIndexes:(NSIndexSet *)indexes withFollowingArtists:(NSArray *)values;
- (void)addFollowingArtistsObject:(MFFollowItem *)value;
- (void)removeFollowingArtistsObject:(MFFollowItem *)value;
- (void)addFollowingArtists:(NSOrderedSet *)values;
- (void)removeFollowingArtists:(NSOrderedSet *)values;
- (void)insertObject:(MFFollowItem *)value inFollowingFriendsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFollowingFriendsAtIndex:(NSUInteger)idx;
- (void)insertFollowingFriends:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFollowingFriendsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFollowingFriendsAtIndex:(NSUInteger)idx withObject:(MFFollowItem *)value;
- (void)replaceFollowingFriendsAtIndexes:(NSIndexSet *)indexes withFollowingFriends:(NSArray *)values;
- (void)addFollowingFriendsObject:(MFFollowItem *)value;
- (void)removeFollowingFriendsObject:(MFFollowItem *)value;
- (void)addFollowingFriends:(NSOrderedSet *)values;
- (void)removeFollowingFriends:(NSOrderedSet *)values;
- (void)insertObject:(MFPlaylistItem *)value inPlaylistsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPlaylistsAtIndex:(NSUInteger)idx;
- (void)insertPlaylists:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePlaylistsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPlaylistsAtIndex:(NSUInteger)idx withObject:(MFPlaylistItem *)value;
- (void)replacePlaylistsAtIndexes:(NSIndexSet *)indexes withPlaylists:(NSArray *)values;
- (void)addPlaylistsObject:(MFPlaylistItem *)value;
- (void)removePlaylistsObject:(MFPlaylistItem *)value;
- (void)addPlaylists:(NSOrderedSet *)values;
- (void)removePlaylists:(NSOrderedSet *)values;
- (void)insertObject:(MFTrackItem *)value inTracksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTracksAtIndex:(NSUInteger)idx;
- (void)insertTracks:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTracksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTracksAtIndex:(NSUInteger)idx withObject:(MFTrackItem *)value;
- (void)replaceTracksAtIndexes:(NSIndexSet *)indexes withTracks:(NSArray *)values;
- (void)addTracksObject:(MFTrackItem *)value;
- (void)removeTracksObject:(MFTrackItem *)value;
- (void)addTracks:(NSOrderedSet *)values;
- (void)removeTracks:(NSOrderedSet *)values;
@end
