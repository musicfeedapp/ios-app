//
//  MFStatus.m
//  botmusic
//
//  Created by Supervisor on 25.08.14.
//
//

#import "MFStatus.h"

@implementation MFStatus

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
    if([self haveStatus:status]){
        _feedStatus-=status;
    }
}

@end
