//
//  MFSaver.h
//  botmusic
//
//  Created by Supervisor on 03.08.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFTrackItem+Behavior.h"

typedef enum{
    MFTracksSourceNone,
    MFTracksSourceProfile,
    MFTracksSourceFeed,
    MFTracksSourceMyMusic,
    MFTracksSourceSuggestions
}MFTracksSource;

@interface MFSaver : NSObject

@property(nonatomic,assign)MFTracksSource trackSource;
@property(nonatomic,copy)NSString *playingTrackItemID;
@property(nonatomic,copy)NSString *feedLatestTrackItemID;
@property(nonatomic,copy)NSString *myMusicLatestTrackItemID;
@property(nonatomic,assign)BOOL isFirstOpenFeeds;

+(MFSaver*)sharedInstance;
-(void)clear;

@end
