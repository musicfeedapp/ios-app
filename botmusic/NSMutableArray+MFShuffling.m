//
//  NSMutableArray+MFShuffling.m
//  botmusic
//
//  Created by Vladimir on 25.11.15.
//
//

#import "NSMutableArray+MFShuffling.h"

@implementation NSMutableArray (MFShuffling)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end