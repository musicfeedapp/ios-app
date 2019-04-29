//
//  MFStatusManager.h
//  botmusic
//
//  Created by Supervisor on 25.08.14.
//
//

#import <Foundation/Foundation.h>
#import "MFStatus.h"

@interface MFStatusManager : NSObject

@property(nonatomic,strong)NSMutableArray *statusArray;

@property(nonatomic,readonly,assign)NSInteger activeIndex;
@property(nonatomic,assign)NSInteger deletingIndex;
@property(nonatomic,assign)NSInteger commentingIndex;

-(id)initWithNumber:(NSInteger)number;


@end
