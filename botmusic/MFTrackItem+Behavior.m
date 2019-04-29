//
//  MFTrackItem+Behavior.m
//  botmusic
//
//  Created by Panda Systems on 4/25/15.
//
//

static NSString *const WHITE_COLOR=@"#ffffff";

@implementation MFTrackItem (Behavior)

NSString* feedTypeYoutube = @"youtube";
NSString* feedTypeSpotify = @"spotify";
NSString* feedTypeSoundcloud = @"soundcloud";
NSString* feedTypeGrooveshark=@"grooveshark";
NSString* feedTypeShazam=@"shazam";
NSString* feedTypeAll=@"all";
NSString* feedTypeMixcloud=@"mixcloud";

-(IRTrackItemState)trackState{
    return [self.trackState_n unsignedIntegerValue];
}
-(void) setTrackState:(IRTrackItemState) state{
    self.trackState_n = [NSNumber numberWithUnsignedInt:state];
}

+ (NSDateFormatter*)dateFormatter
{
    static NSDateFormatter* dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      dateFormatter = [[NSDateFormatter alloc] init];
                      dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
                      dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_EN"];
                  });
    
    return dateFormatter;
}

- (void)configureWithDictionary: (NSDictionary*)dictionaryData
{
    self.itemId = [NSString stringWithFormat:@"%@", [dictionaryData validStringForKey:@"id"]];
    self.author = [dictionaryData validStringForKey:@"author"];
    if (![[dictionaryData validStringForKey:@"author_name"] isEqualToString:@""]) self.authorName = [dictionaryData validStringForKey:@"author_name"];
    self.username=[dictionaryData validObjectForKey:@"username"];
    self.authorId = [dictionaryData validStringForKey:@"author_identifier"];

    NSString* newExtId = [dictionaryData validStringForKey:@"author_ext_id"];
    if (!self.authorExtId || ![newExtId isEqualToString:@""]) {
        self.authorExtId = [dictionaryData validStringForKey:@"author_ext_id"];
    }

    self.authorPicture = [dictionaryData validStringForKey:@"author_picture"];
    self.type = [dictionaryData validStringForKey:@"feed_type"];
    self.link = [dictionaryData validStringForKey:@"link"];
    self.iTunesLink = [dictionaryData validStringForKey:@"itunes_link"];
    self.youtubeLink = [dictionaryData validStringForKey:@"youtube_link"];
    self.youtubeDirectLink = [dictionaryData validStringForKey:@"youtube_direct_link"];
    self.artist = [dictionaryData validStringForKey:@"artist"];
    self.album = [dictionaryData validStringForKey:@"album"];
    self.trackName = [dictionaryData validStringForKey:@"name"];
    self.trackPicture = [dictionaryData validStringForKey:@"picture"];
    self.likes = [dictionaryData validObjectForKey:@"likes_count"];
    self.comments=[dictionaryData validObjectForKey:@"comments_count"];
    self.fontColor=[dictionaryData validObjectForKey:@"font_color"];
    self.timestampString = [dictionaryData validObjectForKey:@"published_at"];
    self.stream = [dictionaryData validStringForKey:@"stream"];
    self.isLiked=[[dictionaryData objectForKey:@"is_liked"]boolValue];
    self.isVerifiedUser=[[dictionaryData objectForKey:@"is_verified_user"]boolValue];
    self.favourite=[[dictionaryData objectForKey:@"is_liked"]boolValue];
    self.authorIsFollowed = [[dictionaryData objectForKey:@"author_is_followed"] boolValue];

    if (dictionaryData[@"is_posted"] && [dictionaryData[@"is_posted"] boolValue] == NO){
        self.isNotPosted = YES;
    } else {
        self.isNotPosted = NO;
    }
    if(self.timestampString){
        NSDateFormatter* formatter = [MFTrackItem dateFormatter];
        NSDate* gmtDate = [formatter dateFromString:self.timestampString];
        NSInteger seconds = [[NSTimeZone localTimeZone] secondsFromGMTForDate: gmtDate];
        self.timestamp = [NSDate dateWithTimeInterval: seconds sinceDate: gmtDate];
    } else {
        self.timestamp = nil;
    }

    NSString* timestampActivityString = [dictionaryData validObjectForKey:@"last_activity_created_at"];
    if(timestampActivityString){
        NSDateFormatter* formatter = [MFTrackItem dateFormatter];
        NSDate* gmtDate = [formatter dateFromString:timestampActivityString];
        NSInteger seconds = [[NSTimeZone localTimeZone] secondsFromGMTForDate: gmtDate];
        self.lastActivityTime = [NSDate dateWithTimeInterval: seconds sinceDate: gmtDate];
    } else {
        self.lastActivityTime = nil;
    }

    NSString* feedOrderString = [dictionaryData validObjectForKey:@"last_feed_appearance_timestamp"];
    if(feedOrderString){
        NSDateFormatter* formatter = [MFTrackItem dateFormatter];
        NSDate* gmtDate = [formatter dateFromString:feedOrderString];
        NSInteger seconds = [[NSTimeZone localTimeZone] secondsFromGMTForDate: gmtDate];
        self.lastFeedAppearanceDate = [NSDate dateWithTimeInterval: seconds sinceDate: gmtDate];
    } else {
        //self.lastFeedAppearanceDate = nil;
    }

    self.lastActivityType = [dictionaryData validStringForKey:@"last_activity_eventable_type"];
    
    //self.trackState = IRTrackItemStateNotStarted;

}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.itemId forKey:@"id"];
    [coder encodeObject:self.author forKey:@"author"];
    [coder encodeObject:self.authorName forKey:@"author_name"];
    [coder encodeObject:self.username forKey:@"username"];
    [coder encodeObject:self.authorId forKey:@"author_identifier"];
    [coder encodeObject:self.authorExtId forKey:@"author_ext_id"];
    [coder encodeObject:self.authorPicture forKey:@"author_picture"];
    [coder encodeObject:self.type forKey:@"feed_type"];
    [coder encodeObject:self.link forKey:@"link"];
    [coder encodeObject:self.iTunesLink forKey:@"itunes_link"];
    [coder encodeObject:self.youtubeLink forKey:@"youtube_link"];
    [coder encodeObject:self.youtubeDirectLink forKey:@"youtube_direct_link"];
    [coder encodeObject:self.artist forKey:@"artist"];
    [coder encodeObject:self.album forKey:@"album"];
    [coder encodeObject:self.trackName forKey:@"name"];
    [coder encodeObject:self.trackPicture forKey:@"picture"];
    [coder encodeObject:self.likes forKey:@"likes_count"];
    [coder encodeObject:self.comments forKey:@"comments_count"];
    [coder encodeObject:self.fontColor forKey:@"font_color"];
    [coder encodeObject:self.timestampString forKey:@"published_at"];
    [coder encodeObject:self.timestamp forKey:@"timestamp"];
    [coder encodeObject:self.stream forKey:@"stream"];
    [coder encodeObject:@(self.isLiked) forKey:@"is_liked"];
    [coder encodeObject:@(self.isVerifiedUser) forKey:@"is_verified_user"];
    [coder encodeObject:@(self.favourite) forKey:@"favourite"];
    [coder encodeObject:@(self.authorIsFollowed) forKey:@"author_is_followed"];
    [coder encodeObject:self.lastActivityTime forKey:@"last_activity_created_at"];
    [coder encodeObject:self.lastActivityType forKey:@"last_activity_eventable_type"];
    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        
        self.itemId = [coder decodeObjectForKey:@"id"];
        self.author = [coder decodeObjectForKey:@"author"];
        self.authorName = [coder decodeObjectForKey:@"author_name"];
        self.username = [coder decodeObjectForKey:@"username"];
        self.authorId = [coder decodeObjectForKey:@"author_identifier"];
        self.authorExtId = [coder decodeObjectForKey:@"author_ext_id"];
        self.authorPicture = [coder decodeObjectForKey:@"author_picture"];
        self.type = [coder decodeObjectForKey:@"feed_type"];
        self.link = [coder decodeObjectForKey:@"link"];
        self.iTunesLink = [coder decodeObjectForKey:@"itunes_link"];
        self.youtubeLink = [coder decodeObjectForKey:@"youtube_link"];
        self.youtubeDirectLink = [coder decodeObjectForKey:@"youtube_direct_link"];
        self.artist = [coder decodeObjectForKey:@"artist"];
        self.album = [coder decodeObjectForKey:@"album"];
        self.trackName = [coder decodeObjectForKey:@"name"];
        self.trackPicture = [coder decodeObjectForKey:@"picture"];
        self.likes = [coder decodeObjectForKey:@"likes_count"];
        self.comments=[coder decodeObjectForKey:@"comments_count"];
        self.fontColor=[coder decodeObjectForKey:@"font_color"];
        self.timestampString = [coder decodeObjectForKey:@"published_at"];
        self.timestamp = [coder decodeObjectForKey:@"timestamp"];
        self.stream = [coder decodeObjectForKey:@"stream"];
        self.isLiked=[[coder decodeObjectForKey:@"is_liked"]boolValue];
        self.isVerifiedUser=[[coder decodeObjectForKey:@"is_verified_user"]boolValue];
        self.favourite=[[coder decodeObjectForKey:@"favourite"]boolValue];
        self.authorIsFollowed=[[coder decodeObjectForKey:@"author_is_followed"]boolValue];
        self.lastActivityTime = [coder decodeObjectForKey:@"last_activity_created_at"];
        self.lastActivityType = [coder decodeObjectForKey:@"last_activity_eventable_type"];
        
        self.trackState = IRTrackItemStateNotStarted;
    }
    return self;
}

- (BOOL)isHaveVideo
{
    if([self.type isEqualToString:feedTypeGrooveshark] || [self.type isEqualToString:feedTypeYoutube] || [self.type isEqualToString:feedTypeShazam])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)likeTrackItem
{
    NSInteger likes=[self.likes integerValue];
    self.likes=@(++likes);
    self.isLiked=YES;
//    self.lastActivityType = @"UserLike";
//    self.lastActivityTime = [NSDate date];
    
}

- (void)dislikeTrackItem
{
    NSInteger likes=[self.likes integerValue];
    self.likes=@(--likes);
    self.isLiked=NO;
}

- (void)addComment
{
    NSInteger comments=[self.comments integerValue];
    self.comments=@(++comments);
    
}

- (void)removeComment
{
    NSInteger comments=[self.comments integerValue];
    self.comments=@(--comments);
}

- (BOOL)isLightColor
{
    return [self.fontColor isEqualToString:WHITE_COLOR];
}

- (NSString*)shareText
{
    return [NSString stringWithFormat:@"#NowPlaying %@ on #MusicFeed. %@", self.trackName, self.shareLink];
}

- (NSString*)shareLink
{
    if ([self isYoutubeTrack]) {
        NSArray *myArray = [self.youtubeLink componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        return [NSString stringWithFormat:@"http://youtu.be/%@", myArray[myArray.count - 1]];
    } else {
        return self.link;
    }
}

- (NSString*)videoID{
    
    NSString *url;
    
    if([self.type isEqualToString:feedTypeYoutube])
    {
        url=self.link;
    }
    else
    {
        url=self.youtubeLink;
    }
    if(!url) url = @"";
    NSRegularExpression *regExp=[[NSRegularExpression alloc]initWithPattern:@"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange range=[[regExp firstMatchInString:url options:0 range:NSMakeRange(0, [url length])]range];
    NSString *videoID=[url substringWithRange:range];
    
    return videoID;
}
#pragma mark - Track types

- (BOOL)isSpotifyTrack{
    return [self.type isEqualToString:feedTypeSpotify];
}

- (BOOL)isSoundcloudTrack{
    return [self.type isEqualToString:feedTypeSoundcloud];
}

- (BOOL)isMixcloudTrack{
    return [self.type isEqualToString:feedTypeMixcloud];
}

- (BOOL)isYoutubeTrack{
    return ![self isSpotifyTrack] && ![self isSoundcloudTrack] && ![self isMixcloudTrack];
}


@end
