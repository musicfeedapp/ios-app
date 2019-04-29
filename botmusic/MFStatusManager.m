//
//  MFStatusManager.m
//  botmusic
//
//  Created by Supervisor on 25.08.14.
//
//

#import "MFStatusManager.h"
#import "MFStatus.h"

@interface MFStatusManager()



@end

@implementation MFStatusManager

-(id)initWithNumber:(NSInteger)number{
    if(self=[super init]){
        self.statusArray=[NSMutableArray array];
        
        for(int i=0;i<number;i++){
            MFStatus *status=[MFStatus new];
            [self.statusArray addObject:status];
        }
    }
    return self;
}

#pragma mark - Properties

-(NSInteger)activeIndex{
    
    for(int i=0;i<self.statusArray.count;i++){
        
        MFStatus *status=self.statusArray[i];
        
        if([status isFeedActive]){
            return i;
        }
    }
    
    return NSNotFound;
}
-(NSInteger)deletingIndex{
    for(int i=0;i<self.statusArray.count;i++){
        
        MFStatus *status=self.statusArray[i];
        
        if([status haveStatus:StatusDeleting]){
            return i;
        }
    }
    
    return NSNotFound;
}
-(void)setDeletingIndex:(NSInteger)deletingIndex{
    NSInteger oldIndex=[self deletingIndex];
    
    if(oldIndex!=NSNotFound){
        MFStatus *status=[self.statusArray objectAtIndex:oldIndex];
        [status removeStatus:StatusDeleting];
        [self.statusArray replaceObjectAtIndex:oldIndex withObject:status];
    }
    
    MFStatus *status=[self.statusArray objectAtIndex:deletingIndex];
    [status addStatus:StatusDeleting];
    [self.statusArray replaceObjectAtIndex:deletingIndex withObject:status];
}

-(NSInteger)commentingIndex{
    for(int i=0;i<self.statusArray.count;i++){
        
        MFStatus *status=self.statusArray[i];
        
        if([status haveStatus:StatusCommenting]){
            return i;
        }
    }
    
    return NSNotFound;
}
-(void)setCommentingIndex:(NSInteger)commentingIndex{
    NSInteger oldIndex=[self commentingIndex];
    
    if(oldIndex!=NSNotFound){
        MFStatus *status=[self.statusArray objectAtIndex:oldIndex];
        [status removeStatus:StatusCommenting];
        [self.statusArray replaceObjectAtIndex:oldIndex withObject:status];
    }
    
    MFStatus *status=[self.statusArray objectAtIndex:commentingIndex];
    [status addStatus:StatusCommenting];
    [self.statusArray replaceObjectAtIndex:commentingIndex withObject:status];
}

@end
