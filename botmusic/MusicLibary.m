//
//  MediaLibary.m
//  botmusic
//
//  Created by Supervisor on 16.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "MusicLibary.h"
#import <MediaPlayer/MediaPlayer.h>

NSString *const kSongTitle=@"title";
NSString *const kSongArtist=@"artist";
NSInteger const TRACK_COUNT_SEPARATOR=50;

@implementation MusicLibary

+(NSArray*)iTunesMusicLibaryTracks
{
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    NSArray *itemsFromGenericQuery = [everything items];
    NSMutableArray *tracks=[NSMutableArray array];
    
    for (MPMediaItem *song in itemsFromGenericQuery)
    {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSString *songArtist=[song valueForProperty:MPMediaItemPropertyArtist];
        
        if(!songTitle)
        {
            songTitle=@"";
        }
        if(!songArtist)
        {
            songArtist=@"";
        }
        
        if(![songTitle isEqualToString:@""] || ![songArtist isEqualToString:@""]){
            NSDictionary *dictionary=@{kSongTitle:songTitle,kSongArtist:songArtist};
            [tracks addObject:dictionary];
        }
    }
    
    return tracks;
}
+(void)postMusicLibary{
    NSArray *libaryTracks=[MusicLibary iTunesMusicLibaryTracks];
    
    for(int i=0;i<libaryTracks.count;i+=TRACK_COUNT_SEPARATOR){
        
        NSRange range;
        
        if(libaryTracks.count>i+TRACK_COUNT_SEPARATOR){
            range=NSMakeRange(i, TRACK_COUNT_SEPARATOR);
        }else{
            range=NSMakeRange(i,libaryTracks.count-i);
        }
        
        NSArray *partOfTracks=[libaryTracks subarrayWithRange:range];
        
        [[IRNetworkClient sharedInstance]postMusic:[partOfTracks toJSON]
                                             email:userManager.userInfo.email
                                             token:[userManager fbToken]
                                      successBlock:^{}
                                      failureBlock:^(NSString *errString){}];
    }
}
+(NSArray*)iTunesMusicLibaryArtists
{
    
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    
    NSArray *itemsFromGenericQuery = [artistsQuery collections];
    NSMutableArray *artists = [NSMutableArray array];
    for (MPMediaItemCollection* collection in itemsFromGenericQuery) {
        NSMutableDictionary* artist = [NSMutableDictionary new];
        [artist setObject:collection.representativeItem.artist forKey:@"name"];
        NSMutableSet* genres = [NSMutableSet new];
        NSMutableSet* albums = [NSMutableSet new];

        for (MPMediaItem* item in collection.items) {
            if (item.genre) {
                [genres addObject:item.genre];
            }
            if (item.albumTitle) {
                [albums addObject:item.albumTitle];
            }
        }
        [artist setObject:[genres allObjects] forKey:@"genres"];
        [artist setObject:[albums allObjects] forKey:@"albums"];
        [artists addObject:artist];
        NSNumber* numberOfTracks = [NSNumber numberWithUnsignedLong: collection.items.count];
        [artist setObject:numberOfTracks forKey:@"tracks_count"];


    }
    
//    for (MPMediaItem *song in itemsFromGenericQuery)
//    {
////        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
//        NSString *songArtist = [song valueForProperty:MPMediaItemPropertyArtist];
//        MPMediaItemArtwork *itemArtwork = [song valueForProperty:MPMediaItemPropertyArtwork];
//        UIImage *artwork = [itemArtwork imageWithSize:CGSizeMake(200, 200)];
//        
////        if(!songTitle)
////        {
////            songTitle=@"";
////        }
//        if(!songArtist)
//        {
//            songArtist=@"";
//        }
//        
//        if (![songArtist isEqualToString:@""]) {
//            NSDictionary *dictionary;
//            if (artwork) {
//                dictionary = @{kSongArtist : songArtist, @"artwork" : artwork};
//            } else {
//                dictionary = @{kSongArtist : songArtist};
//            }
//            [artists addObject:dictionary];
//        }
//    }
//    artists = [[[artists valueForKeyPath:@"@distinctUnionOfObjects.artist"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
    
    return artists;
}

+ (void)sendArtistsToServer{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* artists = [MusicLibary iTunesMusicLibaryArtists];
        dispatch_async(dispatch_get_main_queue(), ^{

            //[self.sendLibraryActivityIndicatior stopAnimating];
            [[IRNetworkClient sharedInstance] postPhoneArtistsList:artists successBlock:^(NSArray *array) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MFArtistsSent" object:nil];
            } failureBlock:^(NSString *errorMessage) {

            }];
            
        });
    });
}
@end
