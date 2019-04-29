//
//  ActionViewCreator.h
//  botmusic
//
//  Created by Supervisor on 19.06.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionView.h"
#import "TrackView.h"

@interface ActionViewCreator : NSObject

+(ActionView*)createActionViewInView:(UIView*)view;

@end
