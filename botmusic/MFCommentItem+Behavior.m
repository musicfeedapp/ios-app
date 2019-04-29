//
//  MFCommentItem+Behavior.m
//  botmusic
//

static NSString *kID=@"id";
static NSString *kComment=@"comment";
static NSString *kUserName=@"user_name";
static NSString *kFacebookUserId=@"user_facebook_id";
static NSString *kCreatedAt=@"created_at";
static NSString *kUserAvatarUrl=@"user_avatar_url";
static NSString *kUserExtId=@"user_ext_id";

@implementation MFCommentItem (Behavior)

-(id)configureWithDictionary:(NSDictionary*)commentDictionary
{
    
        self.commentId=[commentDictionary[kID] stringValue];
        self.comment=commentDictionary[kComment];
        self.user_name=commentDictionary[kUserName];
        self.userExtId=commentDictionary[kUserExtId];
        self.autorFacebookId=commentDictionary[kFacebookUserId];
        self.autorAvatarUrl=commentDictionary[kUserAvatarUrl];
        self.creationTime=commentDictionary[kCreatedAt];

    
    return self;
}
-(NSString*)postTime
{
    NSDateFormatter *dateFormatter=[NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *commentDate=[dateFormatter dateFromString:self.creationTime];
    return [commentDate timeAgo];
}

#pragma mark - NSCoding Delegate methods

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.commentId forKey:kID];
    [coder encodeObject:self.comment forKey:kComment];
    [coder encodeObject:self.user_name forKey:kUserName];
    [coder encodeObject:self.userExtId forKey:kUserExtId];
    [coder encodeObject:self.autorFacebookId forKey:kFacebookUserId];
    [coder encodeObject:self.autorAvatarUrl forKey:kUserAvatarUrl];
    [coder encodeObject:self.creationTime forKey:kCreatedAt];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.commentId = [coder decodeObjectForKey:kID];
        self.comment = [coder decodeObjectForKey:kComment];
        self.user_name = [coder decodeObjectForKey:kUserName];
        self.userExtId = [coder decodeObjectForKey:kUserExtId];
        self.autorFacebookId = [coder decodeObjectForKey:kFacebookUserId];
        self.autorAvatarUrl = [coder decodeObjectForKey:kUserAvatarUrl];
        self.creationTime = [coder decodeObjectForKey:kCreatedAt];
    }
    return self;
}

@end
