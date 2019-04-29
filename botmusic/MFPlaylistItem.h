//
//  MFPlaylistItem.h
//  
//
//  Created by Panda Systems on 4/25/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MFTrackItem, MFUserInfo;

@interface MFPlaylistItem : NSManagedObject

@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) NSString * playlistArtwork;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * tracksCount;
@property (nonatomic, retain) NSOrderedSet *songs;
@property (nonatomic, retain) MFUserInfo *user;
@end

@interface MFPlaylistItem (CoreDataGeneratedAccessors)

- (void)addSongsObject:(MFTrackItem *)value;
- (void)removeSongsObject:(MFTrackItem *)value;
- (void)addSongs:(NSOrderedSet *)values;
- (void)removeSongs:(NSOrderedSet *)values;

@end
