//
//  MFPlaylistItem+Behavior.h
//  botmusic
//
//  Created by Panda Systems on 4/27/15.
//
//

#import "MFPlaylistItem.h"

@interface MFPlaylistItem (Behavior)<NSCoding>

- (id)configureWithDictionary:(NSDictionary*)dictionary;

@end
