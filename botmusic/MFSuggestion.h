//
//  MFSuggestion.h
//  
//
//  Created by Panda Systems on 5/5/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MFUserInfo;

@interface MFSuggestion : NSManagedObject

@property (nonatomic, retain) NSString * avatar_url;
@property (nonatomic, retain) NSString * ext_id;
@property (nonatomic, retain) NSString * facebook_id;
@property (nonatomic, retain) NSString * facebook_link;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic) BOOL is_followed;
@property (nonatomic) BOOL is_verified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int64_t tracks_count;
@property (nonatomic) int64_t followersCount;
@property (nonatomic, retain) NSString * twitter_link;
@property (nonatomic, retain) NSString * username;
@property (nonatomic) int16_t order;
@property (nonatomic, retain) NSString * genres_string;
@property (nonatomic, retain) NSOrderedSet *timelines;
@property (nonatomic, retain) NSOrderedSet *commonFollowers;
@property (nonatomic, retain) NSOrderedSet *suggestion_inverse;
@property (nonatomic, retain) NSOrderedSet *trendingArtist_inverse;

@end
