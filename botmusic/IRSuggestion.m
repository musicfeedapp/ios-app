//
//  IRSuggestion.m
//  botmusic
//
//  Created by Supervisor on 13.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "IRSuggestion.h"

#define kSuggestionID @"id"
#define kFacebookID @"facebook_id"
#define kFacebookLink @"facebook_link"
#define kTwitterLink @"twitter_link"
#define kAvatarUrl @"avatar_url"
#define kName @"name"
#define kUsername @"username"
#define kExtId @"ext_id"
#define kGenres @"genres"
#define kTracksCount @"tracks_count"
#define kIdentifier @"identifier"
#define kIsFollowed @"is_followed"
#define kIsVerified @"is_verified"

@implementation IRSuggestion

#pragma mark - NSCoding Delegate methods

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.id forKey:kSuggestionID];
    [coder encodeObject:self.facebook_id forKey:kFacebookID];
    [coder encodeObject:self.facebook_link forKey:kFacebookLink];
    [coder encodeObject:self.twitter_link forKey:kTwitterLink];
    [coder encodeObject:self.avatar_url forKey:kAvatarUrl];
    [coder encodeObject:self.name forKey:kName];
    [coder encodeObject:self.ext_id forKey:kExtId];
    [coder encodeObject:self.username forKey:kUsername];
    [coder encodeObject:self.genres forKey:kGenres];
    [coder encodeObject:self.tracks_count forKey:kTracksCount];
    [coder encodeObject:self.identifier forKey:kIdentifier];
    [coder encodeObject:@(self.is_followed) forKey:kIsFollowed];
    [coder encodeObject:@(self.is_verified) forKey:kIsVerified];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.id = [coder decodeObjectForKey:kSuggestionID];
        self.facebook_id = [coder decodeObjectForKey:kFacebookID];
        self.facebook_link = [coder decodeObjectForKey:kFacebookLink];
        self.twitter_link = [coder decodeObjectForKey:kTwitterLink];
        self.avatar_url = [coder decodeObjectForKey:kAvatarUrl];
        self.name = [coder decodeObjectForKey:kName];
        self.username = [coder decodeObjectForKey:kUsername];
        self.ext_id = [coder decodeObjectForKey:kExtId];
        self.genres = [coder decodeObjectForKey:kGenres];
        self.tracks_count = [coder decodeObjectForKey:kTracksCount];
        self.identifier = [coder decodeObjectForKey:kIdentifier];
        self.is_followed = [[coder decodeObjectForKey:kIsFollowed] boolValue];
        self.is_verified = [[coder decodeObjectForKey:kIsVerified] boolValue];
    }
    return self;
}

@end
