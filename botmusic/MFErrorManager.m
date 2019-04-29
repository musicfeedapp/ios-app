//
//  MFErrorManager.m
//  botmusic
//
//  Created by Panda Systems on 4/16/15.
//
//

#import "MFErrorManager.h"
#import "AbstractViewController.h"
@implementation MFErrorManager
+ (NSString*)nameForError:(MFErrorType)error{
    switch (error) {
        case MFConnected:
            return @"Connected";
            break;
            
        case MFNetworkError:
            return @"Network Error";
            break;
            
        case MFNotReachableError:
            return @"No Internet Connection";
            break;
            
        case MFTrackAdded:
            return @"Track added!";
            break;
            
        default:
            break;
    }
}

+ (instancetype)sharedInstance
{
    static MFErrorManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(BOOL)isHighPriorityMessage:(NSString*) message{
    if ([message isEqualToString:NSLocalizedString(@"You need Spotify Premium to stream this track",nil)]) {
        return YES;
    }
    return NO;
}

-(void)setIsProblemMessageHidden:(BOOL)isProblemMessageHidden{
    _isProblemMessageHidden = isProblemMessageHidden;
    if (isProblemMessageHidden) {
        [self.problemMessageHiddenTimer invalidate];
        self.problemMessageHiddenTimer = [NSTimer scheduledTimerWithTimeInterval:60.0*60.0 target:self selector:@selector(unhideProblemMessage:) userInfo:nil repeats:NO];
    }
}

-(void)unhideProblemMessage:(NSTimer*)timer{
    self.isProblemMessageHidden = NO;
}

@end
