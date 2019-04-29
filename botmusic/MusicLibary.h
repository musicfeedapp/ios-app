//
//  MediaLibary.h
//  botmusic
//
//  Created by Supervisor on 16.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicLibary : NSObject

+(NSArray*)iTunesMusicLibaryTracks;
+(void)postMusicLibary;
+(NSArray*)iTunesMusicLibaryArtists;
+(void)sendArtistsToServer;

@end
