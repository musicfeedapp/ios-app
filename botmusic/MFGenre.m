//
//  MFGenre.m
//  botmusic
//
//  Created by Panda Systems on 11/17/15.
//
//

#import "MFGenre.h"

@implementation MFGenre

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[self class]]) {
        return NO;
    } else {
        return [self.ID isEqual:((MFGenre*)other).ID];
    }
}

- (NSUInteger)hash
{
    return [self.ID hash];
}

@end
