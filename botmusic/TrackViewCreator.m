//
//  TrackViewCreator.m
//  botmusic
//
//  Created by Supervisor on 13.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "TrackViewCreator.h"
#import "TrackView.h"

@implementation TrackViewCreator

+(TrackView*)createTrackView
{
    TrackView *trackView=[[[NSBundle mainBundle]loadNibNamed:@"TrackView" owner:nil options:nil]lastObject];
    
    CGRect frame=trackView.frame;
    frame.origin.y=180;
    frame.size.height=[TrackView trackViewHeight]+TRACK_VIEW_FOOTER_HEIGHT;
    
    trackView.frame=frame;
    
    return trackView;
}

@end
