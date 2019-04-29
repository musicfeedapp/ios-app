//
//  MFStatus.h
//  botmusic
//
//  Created by Supervisor on 25.08.14.
//
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

@interface MFStatus : NSObject

@property(nonatomic,assign)Status feedStatus;

-(BOOL)isFeedActive;

-(void)addStatus:(Status)status;
-(void)removeStatus:(Status)status;
-(BOOL)haveStatus:(Status)status;

@end
