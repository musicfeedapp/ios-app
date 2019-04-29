//
//  NSString+ValidString.m
//  botmusic
//
//  Created by Илья Романеня on 17.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "NSString+ValidString.h"

@implementation NSString (ValidString)

- (NSString*)validString
{
    return self.length != 0 ? self : @"";
}

@end
