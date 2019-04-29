//
//  Status.m
//  botmusic
//
//  Created by Supervisor on 28.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "FeedStatus.h"

@implementation FeedStatus

-(BOOL)isFeedActive
{
    if([self haveStatus:StatusPlaying] || [self haveStatus:StatusPaused] || [self haveStatus:StatusVideoPlaying])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)haveStatus:(Status)status
{
    return (_feedStatus & status)!=0;
}
-(void)addStatus:(Status)status
{
    _feedStatus|=status;
}
-(void)removeStatus:(Status)status
{
    _feedStatus-=status;
}

@end
