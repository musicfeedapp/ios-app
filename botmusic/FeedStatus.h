//
//  Status.h
//  botmusic
//
//  Created by Supervisor on 28.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    StatusNone=0,
    StatusPlaying=1<<0,
    StatusPaused=1<<1,
    StatusVideoPlaying=1<<2,
    StatusDeleting=1<<3,
    StatusCommenting=1<<4
}Status;

@interface FeedStatus : NSObject

@property(nonatomic,assign)Status feedStatus;

-(BOOL)isFeedActive;

-(void)addStatus:(Status)status;
-(void)removeStatus:(Status)status;
-(BOOL)haveStatus:(Status)status;

@end
