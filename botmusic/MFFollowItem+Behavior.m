//
//  MFFollowItem+Behavior.m
//  botmusic
//
//  Created by Panda Systems on 4/27/15.
//
//

NSString *const kFacebookID=@"facebook_id";
NSString *const kExtID=@"ext_id";
NSString *const kName=@"title";
NSString *const kPicture=@"picture";
NSString *const kFollowed=@"is_followed";
NSString *const kVerified=@"is_verified";

NSString *const kTimelineCount=@"timelines_count";
NSString *const kUsername=@"username";

@implementation MFFollowItem (Behavior)

-(NSInteger) timelineCount{
    return [self.timelineCount_n integerValue];
}

-(void) setTimelineCount:(NSInteger)timelineCount{
    self.timelineCount_n = [NSNumber numberWithInteger:timelineCount];
}

- (id)configureWithDictionary: (NSDictionary*)dictionaryData
{
    if (!([dictionaryData objectForKey:kName] || [dictionaryData objectForKey:kPicture])) {
        return [self configureWithDifferentDictionary:dictionaryData];
    }
    self.facebookID = [dictionaryData validStringForKey:kFacebookID];
    self.extId = [dictionaryData validStringForKey:kExtID];
    self.name = [dictionaryData validStringForKey:kName];
    self.picture = [dictionaryData validObjectForKey:kPicture];
    self.isFollowed = [[dictionaryData validObjectForKey:kFollowed]boolValue];
    self.timelineCount=[[dictionaryData validObjectForKey:kTimelineCount]integerValue];
    self.username=[dictionaryData validObjectForKey:kUsername];
    self.isVerified = [[dictionaryData validObjectForKey:kVerified]boolValue];
    
    return self;
}

//"avatar_url" = "";
//"ext_id" = "2gns8j_At1ddqGLCdnJn";
//"facebook_id" = 10205778638979067;
//"facebook_link" = "";
//id = 10185;
//identifier = 10185;
//"is_verified" = 0;
//name = "Eliza Poll";
//"tracks_count" = 188;
//"twitter_link" = "<null>";
//username = "";

- (id)configureWithDifferentDictionary: (NSDictionary*)dictionaryData
{
    self.facebookID = [dictionaryData validStringForKey:@"facebook_id"];
    self.extId = [dictionaryData validStringForKey:@"ext_id"];
    self.name = [dictionaryData validStringForKey:@"name"];
    self.picture = [dictionaryData validObjectForKey:@"avatar_url"];
    self.isFollowed = YES;
    self.timelineCount=[[dictionaryData validObjectForKey:@"tracks_count"]integerValue];
    self.username=[dictionaryData validObjectForKey:@"username"];
    self.isVerified = [[dictionaryData validObjectForKey:@"is_verified"]boolValue];

    return self;
}

-(id)initWithCoder:(NSCoder*)coder
{
    if(self=[super init])
    {
        self.facebookID=[coder decodeObjectForKey:kFacebookID];
        self.extId=[coder decodeObjectForKey:kExtID];
        self.name=[coder decodeObjectForKey:kName];
        self.picture=[coder decodeObjectForKey:kPicture];
        self.isFollowed=[[coder decodeObjectForKey:kFollowed]integerValue];
        self.timelineCount=[[coder decodeObjectForKey:kTimelineCount]integerValue];
        self.username=[coder decodeObjectForKey:kUsername];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.facebookID forKey:kFacebookID];
    [coder encodeObject:self.extId forKey:kExtID];
    [coder encodeObject:self.name forKey:kName];
    [coder encodeObject:self.picture forKey:kPicture];
    [coder encodeObject:@(self.isFollowed) forKey:kFollowed];
    [coder encodeObject:@(self.timelineCount) forKey:kTimelineCount];
    [coder encodeObject:self.username forKey:kUsername];
}

+ (NSArray*)idsFromFollowItems:(NSArray*)array
{
    NSMutableArray* ids = [NSMutableArray arrayWithCapacity:array.count];
    for (MFFollowItem* followItem in array)
    {
        [ids addObject:@{@"ext_id" : followItem.extId,
                         @"followed" : followItem.isFollowed ? @"true" : @"false"}];
    }
    
    return [NSArray arrayWithArray:ids];
}

@end
