//
//  MFPlaylistItem+Behavior.m
//  botmusic
//
//  Created by Panda Systems on 4/27/15.
//
//

#import "MFPlaylistItem+Behavior.h"

static NSString *const kID = @"id";
static NSString *const kTitle = @"title";
static NSString *const kSongs = @"songs";
static NSString *const kTracksCount = @"tracks_count";
static NSString *const kPlaylistArtwork = @"picture_url";
static NSString *const kIsPrivateKey = @"is_private";

@implementation MFPlaylistItem (Behavior)

- (id)configureWithDictionary:(NSDictionary*)dictionary
{
    
        self.itemId = [NSString stringWithFormat:@"%@",[dictionary validStringForKey:kID]];
        self.title = [dictionary validStringForKey:kTitle];
        self.tracksCount = [dictionary validStringForKey:kTracksCount];
        self.playlistArtwork = [dictionary validStringForKey:kPlaylistArtwork];
        self.isPrivate = [[dictionary validObjectForKey:kIsPrivateKey] boolValue];
        
        //if(dictionary[kSongs]) self.songs = [NSOrderedSet orderedSetWithArray:[dataManager convertAndAddTracksToDatabase:dictionary[kSongs]]];
    
    return self;
}

#pragma mark - NSCoding Delegate methods

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.itemId forKey:kID];
    [coder encodeObject:self.title forKey:kTitle];
    [coder encodeObject:self.tracksCount forKey:kTracksCount];
    [coder encodeObject:self.playlistArtwork forKey:kPlaylistArtwork];
    [coder encodeObject:@(self.isPrivate) forKey:kIsPrivateKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.itemId = [coder decodeObjectForKey:kID];
        self.title = [coder decodeObjectForKey:kTitle];
        self.tracksCount = [coder decodeObjectForKey:kTracksCount];
        self.playlistArtwork = [coder decodeObjectForKey:kPlaylistArtwork];
        self.isPrivate = [[coder decodeObjectForKey:kIsPrivateKey] boolValue];
    }
    return self;
}

#pragma mark - Super Class methods

//- (BOOL)isEqual:(id)object
//{
//    if ([object isKindOfClass:[MFPlaylistItem class]]) {
//        return [self.itemId isEqual:((MFPlaylistItem *)object).itemId];
//    }
//    return [super isEqual:object];
//}

@end
