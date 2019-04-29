//
//  NSDictionary+Utilities.m
//
//  Created by Илья Романеня.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#import "NSDictionary+Utilities.h"

@implementation NSDictionary (Utilities)

- (id)validStringForKey:(NSString *)key
{
	return [self validateString:[self objectForKey:key]];
}

- (NSString*)makeStringForKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@", [self validateString:[self objectForKey:key]] ];
}

- (id)validObjectForKey:(NSString *)key
{
	return [self validateObject:[self objectForKey:key]];
}

- (id)validateString:(id)object
{
	return ((object != [NSNull null]) && (object != nil)) ? object : @"";
}

- (id)validateObject:(id)object
{
	return ((object != [NSNull null]) && (object != nil)) ? object : nil;
}

@end
