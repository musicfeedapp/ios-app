//
//  MFFeedManager.m
//  botmusic
//
//  Created by Panda Systems on 4/28/15.
//
//

#import "MFFeedManager.h"
#import "IRNetworkClient.h"
#import "MagicalRecord/MagicalRecord.h"
#import "FeedViewController.h"

@interface MFFeedManager ()
@end

@implementation MFFeedManager

+ (MFFeedManager *)sharedInstance{
    
    static MFFeedManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MFFeedManager alloc] init];
                      // Do any other initialisation stuff here
                  });
    return sharedInstance;
}

- (void)getLastTracks:(NSInteger) number
            fromTrack:(MFTrackItem*)item
       isFirstTrigger:(BOOL)isFirstPullTrigger
      succesFromCache:(SuccessBlockFeed)successCacheBlock
     updatedFromServer:(SuccessBlockFeed)successServerBlock
    failureFromServer:(FailureServerBlockFeed)block{
    
    [self returnFeedsFromDatabase:number block:successCacheBlock];
    
    NSString* timestampString = nil;
    NSString* itemId = nil;
    if(item){
        timestampString = item.timestampString;
        itemId = item.itemId;
    }
    [[IRNetworkClient sharedInstance] feedPageWithEmail:userManager.userInfo.email
                                                  token:[userManager fbToken]
                                               feedType:feedTypeAll
                                      lastFeedTimestamp:timestampString
                                             lastFeedId:itemId
                                                myFeeds:NO
                                           successBlock:^(NSArray* feedArrayData)
     {
         
        BOOL changed = NO;
        NSArray* actualArray = feedArrayData;
        if(feedArrayData.count>101) actualArray = [feedArrayData subarrayWithRange:NSMakeRange(0, 101)];
         if (userManager.isLoggedIn) {
             changed = [dataManager addFeedTracksToDatabase:actualArray ofUser:userManager.userInfo];
         } else {
             changed = [dataManager addFeedTracksToDatabase:actualArray ofUser:dataManager.getAnonUserInfo];
         }

        if(changed){
                [self returnFeedsFromDatabase:number block:successServerBlock];
        } else {
                successServerBlock(nil);
        }
         
         NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setTimeZone:utcTimeZone];
         [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
         NSString *localDateString = [dateFormatter stringFromDate:[NSDate date]];
         [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
         NSDate *currentDate = [dateFormatter dateFromString:localDateString];
         [userManager setLastTimelinesCheck:currentDate];
         
     }
                                           failureBlock:^(NSString* errorMessage)
     {
         block(errorMessage);
     }];
}

- (void) deleteTrackFromFeed:(MFTrackItem*)feedItem successBlock:(SuccessDeleteTrackBlock)sBlock failureBlock:(FailureServerBlockFeed)fBlock{
    
    [[IRNetworkClient sharedInstance] deleteTrackById:feedItem.itemId withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary* dictionary){
        MFUserInfo* userInfo;
        if (userManager.isLoggedIn) {
            userInfo = userManager.userInfo;
        } else {
            userInfo = dataManager.getAnonUserInfo;
        }

        [userInfo removeTracksObject:feedItem];
        feedItem.isFeedTrack = NO;
        feedItem.isRemovedFromFeed = YES;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        
        sBlock(dictionary);
    } failureBlock:^(NSString *errorMessage) {
        fBlock(errorMessage);
    }];
}

- (void) restoreTrackToFeed:(MFTrackItem*)feedItem successBlock:(SuccessDeleteTrackBlock)sBlock failureBlock:(FailureServerBlockFeed)fBlock{
    
    [[IRNetworkClient sharedInstance] deleteTrackById:feedItem.itemId withEmail:userManager.userInfo.email token:userManager.fbToken successBlock:^(NSDictionary* dictionary){
        
        
        feedItem.isFeedTrack = NO;
        feedItem.isRemovedFromFeed = YES;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        
        sBlock(dictionary);
    } failureBlock:^(NSString *errorMessage) {
        fBlock(errorMessage);
    }];
}

-(void)returnFeedsFromDatabase:(NSInteger)number block:(SuccessBlockFeed) block{

//    NSManagedObjectContext *privateContext = [NSManagedObjectContext MR_context];
//    // When using private contexts you must execute the core data code in it's private queue using performBlock: or performBlockAndWait:
//    [privateContext performBlock:^{
//        // Execute your fetch
//        NSFetchRequest* request = [MFTrackItem MR_requestAllSortedBy:@"timestamp" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"isFeedTrack == YES"]];
//        [request setFetchLimit:number];
//        NSMutableArray* feeds = [[MFTrackItem MR_executeFetchRequest:request inContext:privateContext] mutableCopy];
//        
//        // Convert your fetched objects into object IDs which can be pulled out of the main context
//        NSArray *privateObjectIDs = [feeds valueForKey:@"objectID"];
//        // Return to our main thread
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // Create a new predicate to use to pull our objects out
//            NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"self IN %@", privateObjectIDs];
//            // Execute your fetch
//            NSArray *finalResults = [MFTrackItem MR_findAllWithPredicate:mainPredicate];
//            // Now you can use finalResults however you need from the main thread
//            
//            if(number<finalResults.count) {
//                block([[finalResults subarrayWithRange:NSMakeRange(0, number)] mutableCopy]);
//            }
//            else block([finalResults mutableCopy]);
//            
//        });
//    }];"ANY personsWithThisAsFavorite == %@"

    if (!block) {
        return;
    }
    
    MFUserInfo* userInfo;
    if (userManager.isLoggedIn) {
        userInfo = userManager.userInfo;
    } else {
        userInfo = dataManager.getAnonUserInfo;
    }
    NSFetchRequest* request = [MFTrackItem MR_requestAllSortedBy:@"lastFeedAppearanceDate" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"ANY belongToUsers == %@", userInfo]];
    //NSFetchRequest* request = [MFTrackItem MR_requestAllSortedBy:@"lastFeedAppearanceDate" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"isFeedTrack == YES"]];
    [request setFetchLimit:number];
    NSMutableArray* feeds = [[MFTrackItem MR_executeFetchRequest:request] mutableCopy];
    
    if(number<feeds.count) {
        block([[feeds subarrayWithRange:NSMakeRange(0, number)] mutableCopy]);
    }
    else block([feeds mutableCopy]);
    
}


@end
