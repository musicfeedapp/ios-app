//
//  MFErrorManager.h
//  botmusic
//
//  Created by Panda Systems on 4/16/15.
//
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, MFErrorType) {
    MFNetworkError,
    MFNotReachableError,
    MFConnected,
    MFTrackAdded
};

@interface MFErrorManager : NSObject
@property (nonatomic) BOOL isErrorMessageHidden;
@property (nonatomic) BOOL isProblemMessageHidden;
@property (nonatomic,strong) NSTimer* problemMessageHiddenTimer;
+ (NSString*)nameForError:(MFErrorType)error;
+ (instancetype)sharedInstance;
-(BOOL)isHighPriorityMessage:(NSString*) message;
@end
