//
//  MFUserInfo+Behavior.h
//  botmusic
//
//  Created by Panda Systems on 4/27/15.
//
//

#import "MFUserInfo.h"
#import "DataConverter.h"
#import "NSDictionary+Utilities.h"

@interface MFUserInfo (Behavior)

- (id)configureWithDictionary:(NSDictionary*)userData anotherUser:(BOOL)isAnotherUser;
- (id)configureWithContactInfo:(NSDictionary*)userData anotherUser:(BOOL)isAnotherUser;
- (id)configureWithFacebookInfo:(NSDictionary*)userData anotherUser:(BOOL)isAnotherUser;
- (id)configureWithImportedArtistInfo:(NSDictionary*)userData anotherUser:(BOOL)isAnotherUser;

-(NSString*)abbriviatedName;
-(BOOL)isMyUserInfo;

- (NSArray*)secondaryEmails;
- (void)setSecondaryEmails:(NSArray *)secondaryEmails;

- (NSArray*)secondaryPhones;
- (void)setSecondaryPhones:(NSArray *)secondaryPhones;

- (NSArray*)recentSearches;
- (void)setRecentSearches:(NSArray *)recentSearches;
@end
