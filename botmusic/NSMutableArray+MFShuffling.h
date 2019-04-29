//
//  NSMutableArray+MFShuffling.h
//  botmusic
//
//  Created by Vladimir on 25.11.15.
//
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#include <Cocoa/Cocoa.h>
#endif

// This category enhances NSMutableArray by providing
// methods to randomly shuffle the elements.
@interface NSMutableArray (MFShuffling)
- (void)shuffle;
@end

