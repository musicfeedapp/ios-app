//
//  STrack.m
//  botmusic
//
//  Created by Supervisor on 08.06.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "STrack.h"

@implementation STrack

-(id)initWithTrack:(SPTTrack*)track
{
    if(self=[super init])
    {
        self.track=track;
    }
    
    return self;
}

-(NSArray*)tracks
{
    return @[_track];
}
-(NSURL*)uri
{
    return _track.uri;
}

@end
