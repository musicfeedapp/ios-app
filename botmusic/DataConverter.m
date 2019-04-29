//
//  DataConverter.m
//  botmusic
//
//  Created by Supervisor on 25.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "DataConverter.h"

@implementation DataConverter


+(NSArray*)convertTracks:(NSArray*)tracks
{
    return [dataManager convertAndAddTracksToDatabase:tracks];
}
+(NSArray*)convertSuggestions:(NSArray*)suggestions
{
    NSMutableArray *array=[NSMutableArray array];
    for(NSDictionary *dictionary in suggestions)
    {
        IRSuggestion *suggestion=[[IRSuggestion alloc]initWithDictionary:dictionary];
        [array addObject:suggestion];
    }
    
    return array;
}

@end
