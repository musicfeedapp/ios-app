#import <Foundation/Foundation.h>
#import "Jastor.h"

@interface IRSuggestion : Jastor <NSCoding>

@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *facebook_id;
@property (nonatomic,copy) NSString *facebook_link;
@property (nonatomic,copy) NSString *twitter_link;
@property (nonatomic,copy) NSString *avatar_url;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *ext_id;
@property (nonatomic,copy) NSArray *genres;
@property (nonatomic,copy) NSNumber *tracks_count;
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,assign) BOOL is_followed;
@property (nonatomic,assign) BOOL is_verified;

@end
