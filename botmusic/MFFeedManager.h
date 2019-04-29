//
//  MFFeedManager.h
//  botmusic
//
//  Created by Panda Systems on 4/28/15.
//
//

#import <Foundation/Foundation.h>
typedef void(^SuccessBlockFeed)(NSMutableArray* tracks);
typedef void(^FailureServerBlockFeed)(NSString* errorMessage);

typedef void(^SuccessDeleteTrackBlock)(NSDictionary* dictionary);


@interface MFFeedManager : NSObject

+ (MFFeedManager *)sharedInstance;

- (void)getLastTracks:(NSInteger) number
            fromTrack:(MFTrackItem*)item
       isFirstTrigger:(BOOL)isFirstPullTrigger
      succesFromCache:(SuccessBlockFeed)successCacheBlock
     updatedFromServer:(SuccessBlockFeed)successServerBlock
    failureFromServer:(FailureServerBlockFeed)block;

- (void) deleteTrackFromFeed:(MFTrackItem*)item successBlock:(SuccessDeleteTrackBlock)sBlock failureBlock:(FailureServerBlockFeed)fBlock;
- (void) restoreTrackToFeed:(MFTrackItem*)item successBlock:(SuccessDeleteTrackBlock)sBlock failureBlock:(FailureServerBlockFeed)fBlock;
-(void)returnFeedsFromDatabase:(NSInteger)number block:(SuccessBlockFeed) block;
@end
