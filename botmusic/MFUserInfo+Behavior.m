//
//  MFUserInfo+Behavior.m
//  botmusic
//
//  Created by Panda Systems on 4/27/15.
//
//

#import "MFUserInfo+Behavior.h"

static NSString *const kExtID=@"ext_id";
static NSString *const kFacebookID=@"facebook_id";
static NSString *const kFacebookLink=@"facebook_link";
static NSString *const kEmail=@"email";
static NSString *const kName=@"name";
static NSString *const kFirstName=@"first_name";
static NSString *const kLastName=@"last_name";
static NSString *const kUsername=@"username";
static NSString *const kPhone=@"contact_number";
static NSString *const kProfileImage=@"profile_image";
static NSString *const kBackground=@"background";
static NSString *const kIsFacebookExpired=@"is_facebook_expired";
static NSString *const kIsFollowed=@"is_followed";
static NSString *const kIsVerified=@"is_verified";
static NSString *const kIsAnotherUser=@"is_another_user";
static NSString *const kSongCount=@"songs_count";
static NSString *const kPlaylistsCount=@"playlists_count";

static NSString *const kTimelineCount=@"timelines_count";
static NSString *const kFollowedCount=@"followed_count";
static NSString *const kFollowigsCount=@"followings_count";
static NSString *const kSuggestionCount=@"suggestions_count";
static NSString *const kSongs=@"songs";
static NSString *const kFollowings=@"followings";
static NSString *const kArtists=@"artists";
static NSString *const kFriends=@"friends";
static NSString *const kFollowed=@"followed";
static NSString *const kPlaylists=@"playlists";

@implementation MFUserInfo (Behavior)
- (id)configureWithDictionary: (NSDictionary*)userData anotherUser:(BOOL)isAnotherUser
{
    
    self.extId=[userData validStringForKey:kExtID];
    self.facebookID=[userData validStringForKey:kFacebookID];
    self.facebookLink=[userData validStringForKey:kFacebookLink];
    self.email = [userData validStringForKey:kEmail];
    self.name = [userData validStringForKey:kName];
    self.username=[userData validStringForKey:kUsername];
    self.firstName=[userData validStringForKey:kFirstName];
    self.lastName=[userData validStringForKey:kLastName];
    self.phone = [userData validStringForKey:kPhone];
    self.profileImage = [userData validStringForKey:kProfileImage];
    self.background=[userData validStringForKey:kBackground];

    //TODO need to fix on backend, just weird workaround
    //self.isFacebookExpired=[[userData objectForKey:kIsFacebookExpired]boolValue];
    self.isFacebookExpired=NO;
    
    self.isFollowed=[userData objectForKey:kIsFollowed] != [NSNull null] ? [[userData objectForKey:kIsFollowed]boolValue] : NO;
    self.isVerified=[userData objectForKey:kIsVerified] ? [[userData objectForKey:kIsVerified]boolValue] : NO;
    self.isArtist = [userData objectForKey:@"is_artist"] ? [[userData objectForKey:@"is_artist"]boolValue] : NO;

    self.playlistsCount=[[userData objectForKey:kPlaylistsCount]integerValue];
    self.songsCount=[[userData objectForKey:kSongCount]integerValue];
    self.timelineCount=[[userData objectForKey:kTimelineCount]integerValue];
    self.followingsCount=[[userData objectForKey:kFollowigsCount]integerValue];
    self.followedCount=[[userData objectForKey:kFollowedCount]integerValue];
    self.suggestionsCount=[[userData objectForKey:kSuggestionCount]integerValue];

    self.secondaryEmails = [userData objectForKey:@"secondary_emails"];
    self.secondaryPhones = [userData objectForKey:@"secondary_phones"];

    self.isAnotherUser=isAnotherUser;
        

    self.isUserInfoFullyLoaded = YES;

    
    return self;
}

- (id)configureWithContactInfo:(NSDictionary*)userData anotherUser:(BOOL)isAnotherUser{
    self.extId=[userData validStringForKey:kExtID];
    self.name = [userData validStringForKey:kName];
    self.profileImage = [userData validStringForKey:@"avatar_url"];
    self.isFollowed=[userData objectForKey:kIsFollowed] != [NSNull null] ? [[userData objectForKey:kIsFollowed]boolValue] : NO;
    self.isAnotherUser=isAnotherUser;

    return self;
}

- (id)configureWithFacebookInfo:(NSDictionary*)userData anotherUser:(BOOL)isAnotherUser{
    self.extId=[userData validStringForKey:kExtID];
    self.name = [userData validStringForKey:kName];
    self.profileImage = [userData validStringForKey:kProfileImage];
    self.isFollowed=[userData objectForKey:kIsFollowed] != [NSNull null] ? [[userData objectForKey:kIsFollowed]boolValue] : NO;
    self.isAnotherUser=isAnotherUser;

    return self;
}

- (id)configureWithImportedArtistInfo:(NSDictionary*)userData anotherUser:(BOOL)isAnotherUser{
    self.extId=[userData validStringForKey:kExtID];
    self.name = [userData validStringForKey:kName];
    self.profileImage = [userData validStringForKey:@"avatar_url"];
    if (!self.profileImage.length) {
        self.profileImage = [userData validStringForKey:@"facebook_profile_image_url"];
    }
    self.isFollowed=[userData objectForKey:kIsFollowed] != [NSNull null] ? [[userData objectForKey:kIsFollowed]boolValue] : NO;
    self.isAnotherUser=isAnotherUser;

    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.extId forKey:kExtID];
    [coder encodeObject:self.facebookID forKey:kFacebookID];
    [coder encodeObject:self.facebookLink forKey:kFacebookLink];
    [coder encodeObject:self.email forKey:kEmail];
    [coder encodeObject:self.name forKey:kName];
    [coder encodeObject:self.firstName forKey:kFirstName];
    [coder encodeObject:self.lastName forKey:kLastName];
    [coder encodeObject:self.username forKey:kUsername];
    [coder encodeObject:self.phone forKey:kPhone];
    [coder encodeObject:self.profileImage forKey:kProfileImage];
    
    [coder encodeObject:self.background forKey:kBackground];
    [coder encodeObject:@(self.isFacebookExpired) forKey:kIsFacebookExpired];
    [coder encodeObject:@(self.isAnotherUser) forKey:kIsAnotherUser];
    
    [coder encodeObject:@(self.songsCount) forKey:kSongCount];
    [coder encodeObject:@(self.timelineCount) forKey:kTimelineCount];
    [coder encodeObject:@(self.followedCount) forKey:kFollowedCount];
    [coder encodeObject:@(self.followingsCount) forKey:kFollowigsCount];
    [coder encodeObject:@(self.suggestionsCount) forKey:kSuggestionCount];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
    if (self) {
        self.extId=[coder decodeObjectForKey:kExtID];
        self.facebookID=[coder decodeObjectForKey:kFacebookID];
        self.facebookLink=[coder decodeObjectForKey:kFacebookLink];
        self.email = [coder decodeObjectForKey:kEmail];
        self.name = [coder decodeObjectForKey:kName];
        self.firstName=[coder decodeObjectForKey:kFirstName];
        self.lastName=[coder decodeObjectForKey:kLastName];
        self.username=[coder decodeObjectForKey:kUsername];
        self.phone = [coder decodeObjectForKey:kPhone];
        self.profileImage = [coder decodeObjectForKey:kProfileImage];
        self.isAnotherUser=[[coder decodeObjectForKey:kIsAnotherUser]boolValue];
        
        self.background=[coder decodeObjectForKey:kBackground];
        self.isFacebookExpired=[[coder decodeObjectForKey:kIsFacebookExpired]boolValue];
        
        self.songsCount=[[coder decodeObjectForKey:kSongCount]integerValue];
        self.timelineCount=[[coder decodeObjectForKey:kTimelineCount]integerValue];
        self.followingsCount=[[coder decodeObjectForKey:kFollowigsCount]integerValue];
        self.followedCount=[[coder decodeObjectForKey:kFollowedCount]integerValue];
        self.suggestionsCount=[[coder decodeObjectForKey:kSuggestionCount]integerValue];
    }
    
    return self;
}

#pragma mark - Tracks

//-(void)setSuggestionsCount:(NSInteger)suggestionsCount
//{
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:suggestionsCount];
//
//    _suggestionsCount=suggestionsCount;
//}

#pragma mark - Other Methods

-(NSString*)abbriviatedName
{
    if(self.firstName && ![self.firstName isEqualToString:@""] && self.lastName && self.lastName.length>0){
        NSString *trimmedLastName=[self.lastName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        NSString *lastName=[trimmedLastName substringWithRange:NSMakeRange(0, 1)];
        
        return [NSString stringWithFormat:@"%@ %@",self.firstName,lastName];
    }else{
        return self.username;
    }
    
}
-(BOOL)isMyUserInfo
{
    return [userManager.userInfo.extId isEqualToString:self.extId];
}
-(NSArray*)sortFollowings:(NSArray*)array
{
    array=[array sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(MFFollowItem *follow1,MFFollowItem *follow2){
        if(follow1.timelineCount<follow2.timelineCount)
        {
            return NSOrderedDescending;
        }
        else if(follow1.timelineCount>follow2.timelineCount)
        {
            return NSOrderedAscending;
        }
        else
        {
            return [follow1.name caseInsensitiveCompare:follow2.name];
        }
    }];
    
    return array;
}

- (NSArray*)secondaryEmails
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.secondaryEmails_d];
}

- (void)setSecondaryEmails:(NSArray *)secondaryEmails
{
    self.secondaryEmails_d = [NSKeyedArchiver archivedDataWithRootObject:secondaryEmails];
}

- (NSArray*)secondaryPhones
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.secondaryPhones_d];
}

- (void)setSecondaryPhones:(NSArray *)secondaryPhones
{
    self.secondaryPhones_d = [NSKeyedArchiver archivedDataWithRootObject:secondaryPhones];
}

- (NSArray*)recentSearches
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.recentSearches_d];
}

- (void)setRecentSearches:(NSArray *)recentSearches
{
    self.recentSearches_d = [NSKeyedArchiver archivedDataWithRootObject:recentSearches];
}
@end
