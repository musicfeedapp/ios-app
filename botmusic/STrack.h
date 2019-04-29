//
//  STrack.h
//  botmusic
//
//  Created by Supervisor on 08.06.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>

@interface STrack : NSObject<SPTTrackProvider>

@property(nonatomic,readwrite,strong)SPTTrack *track;

-(id)initWithTrack:(SPTTrack*)track;

@end
