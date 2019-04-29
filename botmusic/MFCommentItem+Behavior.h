//
//  MFCommentItem+Behavior.h
//  botmusic
//

#import "MFCommentItem.h"
#import "NSDate+TimesAgo.h"

@interface MFCommentItem (Behavior)<NSCoding>

-(id)configureWithDictionary:(NSDictionary*)commentDictionary;
-(NSString*)postTime;

@end
