//
//  MFSuggestion+Behavior.m
//  botmusic
//
//  Created by Panda Systems on 5/5/15.
//
//

#import "MFSuggestion+Behavior.h"

@implementation MFSuggestion (Behavior)

- (void)configureWithDictionary: (NSDictionary*)dictionaryData {
    
    self.id = [[dictionaryData validStringForKey:@"id"] stringValue];
    self.avatar_url = [dictionaryData validStringForKey:@"avatar_url"];
    self.ext_id = [dictionaryData validStringForKey:@"ext_id"];
    self.facebook_id = [dictionaryData validStringForKey:@"facebook_id"];
    self.facebook_link = [dictionaryData validStringForKey:@"facebook_link"];
    self.identifier = [dictionaryData validStringForKey:@"identifier"];
    self.is_followed = [[dictionaryData objectForKey:@"is_followed"] boolValue];
    self.is_verified = [[dictionaryData objectForKey:@"is_verified_user"]boolValue];
    self.name = [dictionaryData validStringForKey:@"name"];
    self.twitter_link = [dictionaryData validStringForKey:@"twitter_link"];
    self.username = [dictionaryData validStringForKey:@"username"];
    self.genres_string = [(NSArray*)[dictionaryData objectForKey:@"genres"] componentsJoinedByString:@","];
    self.followersCount = [[dictionaryData objectForKey:@"user_follower_count"] intValue];
}

-(NSArray*) genres{
    return [self.genres_string componentsSeparatedByString:@","];
}

@end
