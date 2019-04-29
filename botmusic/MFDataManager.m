//
//  MFDataManager.m
//  botmusic
//

#import "MFActivityItem+Behavior.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MFSuggestion+Behavior.h"
#import "MFNotificationManager.h"
#import "MFUserNotification.h"

@implementation MFDataManager

+ (MFDataManager *)sharedInstance
{
    static MFDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MFDataManager alloc] init];
                      // Do any other initialisation stuff here
                  });
    return sharedInstance;
}
-(id) init{
    self = [super init];
    NSString* notificationName = [MFNotificationManager nameForNotification:MFNotificationTypeUpdateUserFollowing];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateFollowing:)
                                                 name:notificationName
                                               object:nil];
    return self;
}

- (void)didUpdateFollowing:(NSNotification *)notification
{
    

}

- (MFUserInfo*) getMyUserInfoInContext{
    MFUserInfo* userInfo = [MFUserInfo MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isAnotherUser == NO"]];
    if(userInfo){
        return userInfo;
    } else{
        return [MFUserInfo MR_createEntity];
    }
}

- (MFUserInfo*) getAnonUserInfo{
    MFUserInfo* userInfo = [MFUserInfo MR_findFirstByAttribute:@"extId" withValue:@"_MF_ANON_USER_USERINFO"];
    if(userInfo){
        return userInfo;
    } else{
        userInfo = [MFUserInfo MR_createEntity];
        userInfo.extId = @"_MF_ANON_USER_USERINFO";
        return userInfo;
    }
}

//- (MFUserInfo*) getUserInfoInContextbyFacebookID:(NSString*)facebookID{
//    MFUserInfo* userInfo = [MFUserInfo MR_findFirstByAttribute:@"facebookID" withValue:facebookID];
//    if(userInfo){
//        return userInfo;
//    } else {
//        MFUserInfo* userInfo = [MFUserInfo MR_createEntity];
//        userInfo.facebookID = facebookID;
//        return userInfo;
//    }
//}

- (MFUserInfo*) getUserInfoInContextbyExtID:(NSString*)ExtID{
    MFUserInfo* userInfo = [MFUserInfo MR_findFirstByAttribute:@"extId" withValue:ExtID];
    //NSArray* user = [MFUserInfo MR_findByAttribute:@"extId" withValue:ExtID];
    if(userInfo){
        return userInfo;
    } else {
        MFUserInfo* userInfo = [MFUserInfo MR_createEntity];
        userInfo.extId = ExtID;
        return userInfo;
    }
}

- (MFPlaylistItem*) getPlaylistInContextbyID:(NSString*)ID{
    MFPlaylistItem* playlist = [MFPlaylistItem MR_findFirstByAttribute:@"itemId" withValue:ID];
    if (!playlist) {
        playlist = [MFPlaylistItem MR_createEntity];
        playlist.itemId = ID;
    }
    return playlist;
}


-(BOOL) addFeedTracksToDatabase:(NSArray*) actualArray ofUser:(MFUserInfo*)user{
    
    BOOL changed = NO;
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (NSDictionary* feedItemDictionary in actualArray)
    {
        NSString* itemID = [NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]];
        [ids addObject:itemID];
    }
    
    NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"itemId IN %@", ids];
    NSArray* existedFeedItems = [MFTrackItem MR_findAllWithPredicate:mainPredicate];
    NSArray* existedFeedIds = [existedFeedItems valueForKey:@"itemId"];
    
    for (NSDictionary* feedItemDictionary in actualArray) {
        MFTrackItem* feedItem;
        if (![existedFeedIds containsObject:[NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]]] ){
            feedItem = [MFTrackItem MR_createEntity];
            feedItem.trackState = IRTrackItemStateNotStarted;
        } else {
            NSUInteger i = [existedFeedIds indexOfObject:[NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]]];
            feedItem = existedFeedItems[i];
        }
        [feedItem configureWithDictionary:feedItemDictionary];
        feedItem.isFeedTrack = YES;
        [user addTracksObject:feedItem];
        changed = YES;
        if ([feedItem isSoundcloudTrack]) {
            //NSLog(@"_____________________%@", feedItem.link);
        }
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];

    return changed;
}

-(NSArray*) convertAndAddTracksToDatabase:(NSArray*) actualArray{
//    NSArray* tracks = [self debug_tracksWithID];
    BOOL changed = NO;
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (NSDictionary* feedItemDictionary in actualArray)
    {
        NSString* itemID = [NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]];
        [ids addObject:itemID];
    }
    
    NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"itemId IN %@", ids];
    NSArray* existedFeedItems = [MFTrackItem MR_findAllWithPredicate:mainPredicate];
    NSArray* existedFeedIds = [existedFeedItems valueForKey:@"itemId"];
    NSMutableArray* sortedItems = [[NSMutableArray alloc] init];

    for (NSDictionary* feedItemDictionary in actualArray) {
        MFTrackItem* feedItem;
        if (![existedFeedIds containsObject:[NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]]] ){
            feedItem = [MFTrackItem MR_createEntity];
            feedItem.trackState = IRTrackItemStateNotStarted;
        } else {
            NSUInteger i = [existedFeedIds indexOfObject:[NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]]];
            feedItem = existedFeedItems[i];
        }
        [feedItem configureWithDictionary:feedItemDictionary];
        changed = YES;
        [sortedItems addObject:feedItem];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
//    tracks = [self debug_tracksWithID];
    return sortedItems;
}

-(NSArray*)debug_tracksWithID{
    return [MFTrackItem MR_findByAttribute:@"itemId" withValue:@"163889"];
}
-(void) convertAndAddTracksToDatabaseAsync:(NSArray*)actualArray playlist:(MFPlaylistItem*)playlist completion:(RequestSuccessBlockWithArray)completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray* ids = [[NSMutableArray alloc] init];
        for (NSDictionary* feedItemDictionary in actualArray)
        {
            NSString* itemID = [NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]];
            [ids addObject:itemID];
        }

        NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"itemId IN %@", ids];

        dispatch_async(dispatch_get_main_queue(), ^{
            //NSArray* existedFeedItems = [MFTrackItem MR_findAllWithPredicate:mainPredicate];
            [self fetchInBackgroundEntitiesOfClass:[MFTrackItem class] withPredicate:mainPredicate completion:^(NSArray *array) {
                NSArray* existedFeedItems = array;

                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    NSMutableOrderedSet* songs = [NSMutableOrderedSet orderedSet];
                    NSArray* existedFeedIds = [existedFeedItems valueForKey:@"itemId"];

                    for (NSDictionary* feedItemDictionary in actualArray) {
                        MFTrackItem* feedItem;
                        if (![existedFeedIds containsObject:[NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]]] ){
                            feedItem = [MFTrackItem MR_createEntityInContext:localContext];
                            feedItem.trackState = IRTrackItemStateNotStarted;
                        } else {
                            NSUInteger i = [existedFeedIds indexOfObject:[NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]]];
                            feedItem = [(MFTrackItem*)existedFeedItems[i] MR_inContext:localContext];
                        }
                        [feedItem configureWithDictionary:feedItemDictionary];
                        [songs addObject:feedItem];
                    }
                    MFPlaylistItem* localPlaylist = [playlist MR_inContext:localContext];
                    localPlaylist.songs = songs;
                } completion:^(BOOL contextDidSave, NSError *error) {

                    completion([playlist.songs array]);
                }];
            }];

        });
    });

}

-(void) convertAndAddTracksToDatabaseAsync:(NSArray*)actualArray completion:(RequestSuccessBlockWithArray)completion{
    //NSArray* tracks = [MFTrackItem MR_findByAttribute:@"itemId" withValue:@"163889"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray* ids = [[NSMutableArray alloc] init];
        for (NSDictionary* feedItemDictionary in actualArray)
        {
            NSString* itemID = [NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]];
            [ids addObject:itemID];
        }

        NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"itemId IN %@", ids];

        dispatch_async(dispatch_get_main_queue(), ^{
            //NSArray* existedFeedItems = [MFTrackItem MR_findAllWithPredicate:mainPredicate];
            [self fetchInBackgroundEntitiesOfClass:[MFTrackItem class] withPredicate:mainPredicate completion:^(NSArray *array) {
                NSArray* existedFeedItems = array;
                NSMutableOrderedSet* songs = [NSMutableOrderedSet orderedSet];

                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    NSArray* existedFeedIds = [existedFeedItems valueForKey:@"itemId"];

                    for (NSDictionary* feedItemDictionary in actualArray) {
                        MFTrackItem* feedItem;
                        if (![existedFeedIds containsObject:[NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]]] ){
                            feedItem = [MFTrackItem MR_createEntityInContext:localContext];
                            feedItem.trackState = IRTrackItemStateNotStarted;
                        } else {
                            NSUInteger i = [existedFeedIds indexOfObject:[NSString stringWithFormat:@"%@", [feedItemDictionary objectForKey:@"id"]]];
                            feedItem = [(MFTrackItem*)existedFeedItems[i] MR_inContext:localContext];
                        }
                        [feedItem configureWithDictionary:feedItemDictionary];
                        [songs addObject:feedItem];
                    }
                } completion:^(BOOL contextDidSave, NSError *error) {
                    NSMutableArray* items = [[NSMutableArray alloc] init];
                    for (MFTrackItem* suggestion in songs) {
                        [items addObject:[suggestion MR_inThreadContext]];
                    }
                    completion(items);
                }];
            }];
            
        });
    });
    
}


-(NSArray*) convertAndAddPlaylistsToDatabase:(NSArray*) actualArray ofUser:(MFUserInfo*) userInfo{
    
    BOOL changed = NO;
    NSMutableArray* sortedItems = [[NSMutableArray alloc] init];
    NSMutableArray* customPlaylists = [actualArray mutableCopy];
    if(userInfo){
        BOOL haveDefaultPlaylists = NO;
        if (userInfo.playlists.count>1 && [[(MFPlaylistItem*)userInfo.playlists[0] itemId] isEqualToString:@"default"]) {
            haveDefaultPlaylists = YES;
        }
        if (!haveDefaultPlaylists){
            
            MFPlaylistItem* playlist1 = [MFPlaylistItem MR_createEntity];
            [playlist1 configureWithDictionary:actualArray[0]];
            [sortedItems addObject: playlist1];
            
            MFPlaylistItem* playlist2 = [MFPlaylistItem MR_createEntity];
            [playlist2 configureWithDictionary:actualArray[1]];
            [sortedItems addObject: playlist2];
            playlist1.user = userInfo;
            playlist2.user = userInfo;

        } else {
            
            MFPlaylistItem* playlist1 = userInfo.playlists[0];
            [playlist1 configureWithDictionary:actualArray[0]];
            [sortedItems addObject: playlist1];

            MFPlaylistItem* playlist2 = userInfo.playlists[1];
            [playlist2 configureWithDictionary:actualArray[1]];
            [sortedItems addObject: playlist2];
            playlist1.user = userInfo;
            playlist2.user = userInfo;
        }
        
        [customPlaylists removeObjectAtIndex:0];
        [customPlaylists removeObjectAtIndex:0];
    }
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (NSDictionary* playlistItemDictionary in customPlaylists)
    {
        NSString* itemID = [NSString stringWithFormat:@"%@",[playlistItemDictionary objectForKey:@"id"]];
        [ids addObject:itemID];
    }
    
    NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"itemId IN %@", ids];
    NSArray* existedItems = [MFPlaylistItem MR_findAllWithPredicate: mainPredicate];
    NSArray* existedIds = [existedItems valueForKey:@"itemId"];
    
    for (NSDictionary* playlistItemDictionary in customPlaylists) {
        MFPlaylistItem* item;
        NSString* itemID = [NSString stringWithFormat:@"%@",[playlistItemDictionary objectForKey:@"id"]];
        if (![existedIds containsObject:itemID] ){
            item = [MFPlaylistItem MR_createEntity];
        } else {
            
            NSUInteger i = [existedIds indexOfObject:itemID];
            item = existedItems[i];
            
        }
        [item configureWithDictionary:playlistItemDictionary];
        changed = YES;
        [sortedItems addObject:item];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    
    return sortedItems;
}

-(NSArray*) convertAndAddFollowItemsToDatabase:(NSArray*) actualArray{
    
    BOOL changed = NO;
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (NSDictionary* followItemDictionary in actualArray)
    {
        NSString* itemID = [NSString stringWithFormat:@"%@",[followItemDictionary objectForKey:@"ext_id"]];
        [ids addObject:itemID];
    }
    
    NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"extId IN %@", ids];
    NSArray* existedItems = [MFFollowItem MR_findAllWithPredicate: mainPredicate];
    NSArray* existedIds = [existedItems valueForKey:@"extId"];
    NSMutableArray* sortedItems = [[NSMutableArray alloc] init];
    
    for (NSDictionary* followItemDictionary in actualArray) {
        MFFollowItem* item;
        NSString* itemID = [NSString stringWithFormat:@"%@",[followItemDictionary objectForKey:@"ext_id"]];
        if (![existedIds containsObject:itemID] ){
            item = [MFFollowItem MR_createEntity];
        } else {
            NSUInteger i = [existedIds indexOfObject:itemID];
            item = existedItems[i];
        }
        [item configureWithDictionary:followItemDictionary];
        changed = YES;
        [sortedItems addObject:item];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    
    return sortedItems;

}

-(MFUserInfo*) convertAndAddUserInfoToDatabase:(NSDictionary*) dictionary{
    MFUserInfo* userInfo = [MFUserInfo MR_findFirstByAttribute:@"extId" withValue:[dictionary objectForKey:@"ext_id"]];
    if(!userInfo){
        userInfo = [MFUserInfo MR_createEntity];
    }
    [userInfo configureWithDictionary:dictionary anotherUser:YES];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    
    return userInfo;
}

-(NSArray*) convertAndAddCommentItemsToDatabase:(NSArray*) actualArray{
    
    BOOL changed = NO;
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (NSDictionary* followItemDictionary in actualArray)
    {
        NSString* itemID = [NSString stringWithFormat:@"%@",[followItemDictionary objectForKey:@"id"]];
        [ids addObject:itemID];
    }
    
    NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"commentId IN %@", ids];
    NSArray* existedItems = [MFCommentItem MR_findAllWithPredicate: mainPredicate];
    NSArray* existedIds = [existedItems valueForKey:@"commentId"];
    NSMutableArray* sortedItems = [[NSMutableArray alloc] init];
    
    for (NSDictionary* itemDictionary in actualArray) {
        MFCommentItem* item;
        NSString* itemID = [NSString stringWithFormat:@"%@",[itemDictionary objectForKey:@"id"]];
        if (![existedIds containsObject:itemID] ){
            item = [MFCommentItem MR_createEntity];
        } else {
            NSUInteger i = [existedIds indexOfObject:itemID];
            item = existedItems[i];
        }
        [item configureWithDictionary:itemDictionary];
        changed = YES;
        [sortedItems addObject:item];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    
    return sortedItems;
}

-(NSArray*) convertAndAddActivityItemsToDatabase:(NSArray*) actualArray{
    
    BOOL changed = NO;
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (NSDictionary* followItemDictionary in actualArray)
    {
        NSString* itemID = [NSString stringWithFormat:@"%@",[followItemDictionary objectForKey:@"id"]];
        [ids addObject:itemID];
    }
    
    NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"itemId IN %@", ids];
    NSArray* existedItems = [MFActivityItem MR_findAllWithPredicate: mainPredicate];
    NSArray* existedIds = [existedItems valueForKey:@"itemId"];
    NSMutableArray* sortedItems = [[NSMutableArray alloc] init];
    
    for (NSDictionary* itemDictionary in actualArray) {
        MFActivityItem* item;
        NSString* itemID = [NSString stringWithFormat:@"%@",[itemDictionary objectForKey:@"id"]];
        if (![existedIds containsObject:itemID] ){
            item = [MFActivityItem MR_createEntity];
        } else {
            NSUInteger i = [existedIds indexOfObject:itemID];
            item = existedItems[i];
        }
        [item configureWithDictionary:itemDictionary];
        changed = YES;
        [sortedItems addObject:item];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    
    return sortedItems;
}

-(NSArray*) convertAndAddNotificationItemsToDatabase:(NSArray*) actualArray{

    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (NSDictionary* notifDictionary in actualArray)
    {
        NSString* itemID = [NSString stringWithFormat:@"%@", [notifDictionary objectForKey:@"id"]];
        [ids addObject:itemID];
    }

    NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"identifier IN %@", ids];
    NSArray* existedItems = [MFUserNotification MR_findAllWithPredicate: mainPredicate];
    NSArray* existedIds = [existedItems valueForKey:@"identifier"];
    NSMutableArray* sortedItems = [[NSMutableArray alloc] init];

    for (NSDictionary* itemDictionary in actualArray) {
        MFUserNotification* item;
        NSString* itemID = [NSString stringWithFormat:@"%@",[itemDictionary objectForKey:@"id"]];
        if (![existedIds containsObject:itemID] ){
            item = [MFUserNotification newNotificationWithDictionary:itemDictionary];
        } else {
            NSUInteger i = [existedIds indexOfObject:itemID];
            item = existedItems[i];
            [item configureWithDictionary:itemDictionary];
        }
        if (item) {
            [sortedItems addObject:item];
        }
    }

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];


    return sortedItems;
}

-(NSArray*) convertAndAddSuggestionItemsToDatabase:(NSArray*) actualArray{
    
    BOOL changed = NO;
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (NSDictionary* followItemDictionary in actualArray)
    {
        NSString* itemID = [NSString stringWithFormat:@"%@",[followItemDictionary objectForKey:@"id"]];
        [ids addObject:itemID];
    }
    
    NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"id IN %@", ids];
    NSArray* existedItems = [MFSuggestion MR_findAllWithPredicate: mainPredicate];
    NSArray* existedIds = [existedItems valueForKey:@"id"];
    NSMutableArray* sortedItems = [[NSMutableArray alloc] init];
    int16_t i = 0;
    for (NSDictionary* itemDictionary in actualArray) {
        MFSuggestion* item;
        NSString* itemID = [NSString stringWithFormat:@"%@",[itemDictionary objectForKey:@"id"]];
        if (![existedIds containsObject:itemID] ){
            item = [MFSuggestion MR_createEntity];
        } else {
            NSUInteger i = [existedIds indexOfObject:itemID];
            item = existedItems[i];
        }
        [item configureWithDictionary:itemDictionary];
        changed = YES;
        item.order = ++i;
        [sortedItems addObject:item];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {

    }];

    return sortedItems;
}

-(void) convertAndAddSuggestionItemsToDatabaseAsync:(NSArray*) actualArray completion:(RequestSuccessBlockWithArray)completion{

        NSMutableArray* sortedItems = [[NSMutableArray alloc] init];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

            for (NSDictionary* itemDictionary in actualArray) {
                MFSuggestion* item;
                item = [MFSuggestion MR_createEntityInContext:localContext];
                [item configureWithDictionary:itemDictionary];
                [sortedItems addObject:item];
            }
        } completion:^(BOOL contextDidSave, NSError *error) {
            NSMutableArray* items = [[NSMutableArray alloc] init];
            for (MFSuggestion* suggestion in sortedItems) {
                [items addObject:[suggestion MR_inThreadContext]];
            }
            completion(items);
        }];
}

-(void)clearFeed{
    NSFetchRequest* request = [MFTrackItem MR_requestAllSortedBy:@"lastFeedAppearanceDate" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"isFeedTrack == YES"]];
    NSMutableArray* feeds = [[MFTrackItem MR_executeFetchRequest:request] mutableCopy];
    for (MFTrackItem* track in feeds) {
        track.isFeedTrack = NO;
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];

}

-(void)clearNotifications{
    [MFUserNotification MR_truncateAll];
}

-(void)fetchInBackgroundEntitiesOfClass:(Class)class withPredicate:(NSPredicate*)predicate completion:(RequestSuccessBlockWithArray)completion{
    NSManagedObjectContext *privateContext = [NSManagedObjectContext MR_context];
    // When using private contexts you must execute the core data code in it's private queue using performBlock: or performBlockAndWait:
    [privateContext performBlock:^{
        // Execute your fetch
        NSArray *privateObjects = [class MR_findAllWithPredicate:predicate inContext:privateContext];
        // Convert your fetched objects into object IDs which can be pulled out of the main context
        NSArray *privateObjectIDs = [privateObjects valueForKey:@"objectID"];
        // Return to our main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            // Create a new predicate to use to pull our objects out
            NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"self IN %@", privateObjectIDs];
            // Execute your fetch
            NSArray *finalResults = [class MR_findAllWithPredicate:mainPredicate];
            // Now you can use finalResults however you need from the main thread
            completion(finalResults);
        });
    }];
}

-(void)getLastPlayedTracks:(int)number completion:(RequestSuccessBlockWithArray)completion{
    NSManagedObjectContext *privateContext = [NSManagedObjectContext MR_context];
    [privateContext performBlock:^{
        NSFetchRequest* request = [MFTrackItem MR_requestAllSortedBy:@"lastPlayedDate" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"isPlayed == YES"]];
        [request setFetchLimit:number];
        NSArray *privateObjects = [MFTrackItem MR_executeFetchRequest:request];
        NSArray *privateObjectIDs = [privateObjects valueForKey:@"objectID"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"self IN %@", privateObjectIDs];
            NSArray *finalResults = [MFTrackItem MR_findAllWithPredicate:mainPredicate];
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastPlayedDate" ascending:NO];
            NSArray* sortedArray=[finalResults sortedArrayUsingDescriptors:@[sort]];
            completion(sortedArray);
        });
    }];
}

-(void)updateTrackPlayedTime:(MFTrackItem*)trackItem{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MFTrackItem* localTrack = [trackItem MR_inContext:localContext];
        localTrack.isPlayed = YES;
        localTrack.lastPlayedDate = [NSDate date];

    } completion:^(BOOL contextDidSave, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MFUpdateTrackHistory" object:nil];
    }];
}

-(NSArray*) processSuggestions:(NSArray*) rawSuggestions{
    NSArray* suggestions = [dataManager convertAndAddSuggestionItemsToDatabase: rawSuggestions];

    NSMutableArray* followArray = [NSMutableArray array];
    for (NSDictionary* suggestion in rawSuggestions) {
        [followArray addObjectsFromArray:suggestion[@"common_followers"]];
    }
    NSArray* allFollowItems = [dataManager convertAndAddFollowItemsToDatabase:followArray];

    NSInteger followCurrentIndex = 0;
    for (int i = 0; i<suggestions.count; i++) {
        NSInteger count = [rawSuggestions[i][@"common_followers"] count];
        ((MFSuggestion*)suggestions[i]).commonFollowers = [NSOrderedSet orderedSetWithArray: [allFollowItems subarrayWithRange:NSMakeRange(followCurrentIndex, count)]];
        followCurrentIndex +=count;
    }

    NSMutableArray* tracksArray = [NSMutableArray array];
    for (NSDictionary* suggestion in rawSuggestions) {
        [tracksArray addObjectsFromArray:suggestion[@"timelines"]];
    }
    NSArray* allSuggestionTracks = [dataManager convertAndAddTracksToDatabase:tracksArray];

    NSInteger currentIndex = 0;
    for (int i = 0; i<suggestions.count; i++) {
        NSInteger count = [rawSuggestions[i][@"timelines"] count];
        ((MFSuggestion*)suggestions[i]).timelines = [NSOrderedSet orderedSetWithArray: [allSuggestionTracks subarrayWithRange:NSMakeRange(currentIndex, count)]];
        currentIndex +=count;
    }
    return suggestions;
}

-(NSArray*) convertAndAddUserInfosToDatabase:(NSArray*) actualArray userInfoType:(MFUserInfoType) userInfoType{

    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (NSDictionary* userInfoDictionary in actualArray)
    {
        NSString* itemID = [NSString stringWithFormat:@"%@",[userInfoDictionary objectForKey:@"ext_id"]];
        [ids addObject:itemID];
    }

    NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"extId IN %@", ids];
    NSArray* existedItems = [MFUserInfo MR_findAllWithPredicate: mainPredicate];
    NSArray* existedIds = [existedItems valueForKey:@"extId"];
    NSMutableArray* sortedItems = [[NSMutableArray alloc] init];

    for (NSDictionary* userInfoDictionary in actualArray) {
        MFUserInfo* item;
        NSString* itemID = [NSString stringWithFormat:@"%@",[userInfoDictionary objectForKey:@"ext_id"]];
        BOOL isNewUserInfo;
        if (![existedIds containsObject:itemID] ){
            item = [MFUserInfo MR_createEntity];
            isNewUserInfo = YES;
        } else {
            NSUInteger i = [existedIds indexOfObject:itemID];
            item = existedItems[i];
            isNewUserInfo = NO;
        }

        BOOL isAnotherUser;
        if (isNewUserInfo) {
            isAnotherUser = YES;
        } else {
            isAnotherUser = item.isAnotherUser;
        }

        if (userInfoType == MFUserInfoTypeContacts) {
            [item configureWithContactInfo:userInfoDictionary anotherUser:isAnotherUser];
        } else if (userInfoType == MFUserInfoTypeFacebook) {
            [item configureWithFacebookInfo:userInfoDictionary anotherUser:isAnotherUser];
        } else {
            [item configureWithImportedArtistInfo:userInfoDictionary anotherUser:isAnotherUser];
        }

        [sortedItems addObject:item];
    }

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];

    return sortedItems;

}

@end
