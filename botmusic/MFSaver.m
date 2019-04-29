//
//  MFSaver.m
//  botmusic
//
//  Created by Supervisor on 03.08.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "MFSaver.h"

@implementation MFSaver

+(MFSaver*)sharedInstance{
    
    static MFSaver *sharedInstance=nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance=[MFSaver new];
    });
    
    return sharedInstance;
}
-(void)clear{
    
    self.trackSource=MFTracksSourceNone;
    self.playingTrackItemID=nil;
    self.feedLatestTrackItemID=nil;
    self.myMusicLatestTrackItemID=nil;
    self.isFirstOpenFeeds=NO;
}

#pragma mark - Helpers

-(NSString*)playingTrackItemID{
    
    MFTrackItem *trackItem=[playerManager currentTrack];
    return trackItem.itemId;
}

@end
