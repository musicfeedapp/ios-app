//
//  MFFollowItem+Behavior.h
//  botmusic
//
//  Created by Panda Systems on 4/27/15.
//
//

#import "MFFollowItem.h"

@interface MFFollowItem (Behavior)<NSCoding>

- (id)configureWithDictionary: (NSDictionary*)dictionaryData;

+ (NSArray*)idsFromFollowItems:(NSArray*)array;

-(NSInteger) timelineCount;
-(void) setTimelineCount:(NSInteger)timelineCount;


@end
