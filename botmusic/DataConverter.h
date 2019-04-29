//
//  DataConverter.h
//  botmusic
//
//  Created by Supervisor on 25.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFFollowItem+Behavior.h"
#import "MFTrackItem+Behavior.h"
#import "IRSuggestion.h"
#import "MFPlaylistItem+Behavior.h"

@interface DataConverter : NSObject

+(NSArray*)convertTracks:(NSArray*)tracks;
+(NSArray*)convertSuggestions:(NSArray*)suggestions;

@end
