//
//  MFActivityItem+Behavior.m
//  botmusic
//

#import "MFActivityItem+Behavior.h"

static NSString *const kItemIdKey = @"id";
static NSString *const kCommentKey = @"comment";
static NSString *const kEventableIdKey = @"eventable_id";
static NSString *const kEventableTypeKey = @"eventable_type";
static NSString *const kUserExtIdKey = @"user_ext_id";
static NSString *const kUserFacebookIdKey = @"user_facebook_id";
static NSString *const kUserNameKey = @"user_name";
static NSString *const kUserAvatarUrlKey = @"user_avatar_url";
static NSString *const kCreatedAtKey = @"created_at";

static NSString *const kActivityTypeUserLike = @"UserLike";
static NSString *const kActivityTypePlaylist = @"Playlist";
static NSString *const kActivityTypeComment = @"Comment";

@implementation MFActivityItem (Behavior)

- (id)configureWithDictionary: (NSDictionary*)dictionaryData {
    
        self.itemId = [[dictionaryData validStringForKey:kItemIdKey] stringValue];
        self.comment = [dictionaryData validStringForKey:kCommentKey];
        self.eventableId = [dictionaryData validStringForKey:kEventableIdKey];
        self.eventableType = [dictionaryData validStringForKey:kEventableTypeKey];
        self.userExtId = [dictionaryData validStringForKey:kUserExtIdKey];
        self.userFacebookId = [dictionaryData validStringForKey:kUserFacebookIdKey];
        self.userName = [dictionaryData validStringForKey:kUserNameKey];
        self.userAvatarUrl = [dictionaryData validStringForKey:kUserAvatarUrlKey];
        self.createdAtString = [dictionaryData validStringForKey:kCreatedAtKey];
    
    return self;
}

#pragma mark - Properties

- (NSDate *)createdAt {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    return [dateFormatter dateFromString:self.createdAtString];
}

- (NSString *)postTime {
    return [self.createdAt timeAgo];
}

- (NSString *)postTimeLongStyle {
    return [self.createdAt timeAgoLongStyle];
}

- (IRActivityType)type {
    if ([self.eventableType isEqualToString:kActivityTypeUserLike]) {
        return IRActivityTypeUserLike;
    } else if ([self.eventableType isEqualToString:kActivityTypeComment]) {
        return IRActivityTypeComment;
    } else {
        return IRActivityTypePlaylist;
    }
}

#pragma mark - NSCoding methods

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.itemId forKey:kItemIdKey];
    [coder encodeObject:self.comment forKey:kCommentKey];
    [coder encodeObject:self.eventableId forKey:kEventableIdKey];
    [coder encodeObject:self.eventableType forKey:kEventableTypeKey];
    [coder encodeObject:self.userExtId forKey:kUserExtIdKey];
    [coder encodeObject:self.userFacebookId forKey:kUserFacebookIdKey];
    [coder encodeObject:self.userName forKey:kUserNameKey];
    [coder encodeObject:self.userAvatarUrl forKey:kUserAvatarUrlKey];
    [coder encodeObject:self.createdAtString forKey:kCreatedAtKey];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.itemId = [coder decodeObjectForKey:kItemIdKey];
        self.comment = [coder decodeObjectForKey:kCommentKey];
        self.eventableId = [coder decodeObjectForKey:kEventableIdKey];
        self.eventableType = [coder decodeObjectForKey:kEventableTypeKey];
        self.userExtId = [coder decodeObjectForKey:kUserExtIdKey];
        self.userFacebookId = [coder decodeObjectForKey:kUserFacebookIdKey];
        self.userName = [coder decodeObjectForKey:kUserNameKey];
        self.userAvatarUrl = [coder decodeObjectForKey:kUserAvatarUrlKey];
        self.createdAtString = [coder decodeObjectForKey:kCreatedAtKey];
    }
    return self;
}



@end
