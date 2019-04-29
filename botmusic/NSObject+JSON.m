//
//  NSObject+JSON.m
//  botmusic
//
//  Created by Supervisor on 16.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "NSObject+JSON.h"

@implementation NSObject (JSON)

-(NSString*)toJSON
{
    NSError *error=nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    
    if(!error)
    {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    else
    {
        return nil;
    }
}

@end
