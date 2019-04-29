//
//  MFFollowItem.h
//  
//
//  Created by Panda Systems on 5/5/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MFUserInfo;

@interface MFFollowItem : NSManagedObject

@property (nonatomic, retain) NSString * extId;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isVerified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSNumber * timelineCount_n;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) MFUserInfo *userInfo;
@property (nonatomic, retain) NSSet *followed_inv;
@property (nonatomic, retain) NSSet *followingFriends_inv;
@property (nonatomic, retain) NSSet *followingArtists_inv;
@property (nonatomic, retain) NSSet *belongToSuggestions;
@end

@interface MFFollowItem (CoreDataGeneratedAccessors)

- (void)addFollowed_invObject:(MFUserInfo *)value;
- (void)removeFollowed_invObject:(MFUserInfo *)value;
- (void)addFollowed_inv:(NSSet *)values;
- (void)removeFollowed_inv:(NSSet *)values;

- (void)addFollowingFriends_invObject:(MFUserInfo *)value;
- (void)removeFollowingFriends_invObject:(MFUserInfo *)value;
- (void)addFollowingFriends_inv:(NSSet *)values;
- (void)removeFollowingFriends_inv:(NSSet *)values;

- (void)addFollowingArtists_invObject:(MFUserInfo *)value;
- (void)removeFollowingArtists_invObject:(MFUserInfo *)value;
- (void)addFollowingArtists_inv:(NSSet *)values;
- (void)removeFollowingArtists_inv:(NSSet *)values;

@end
