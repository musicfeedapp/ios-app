//
//  NSDate+TimesAgo.m
//  botmusic
//
//  Created by Supervisor on 06.08.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "NSDate+TimesAgo.h"

@implementation NSDate (TimesAgo)

- (NSString *)timeAgo
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([self timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    int minutes;
    
    if(deltaSeconds < 60)
    {
        return [NSString stringWithFormat:@"%ds",(int)deltaSeconds];
    }
    else if (deltaMinutes < 60)
    {
        return [NSString stringWithFormat:@"%dm",(int)deltaMinutes];
    }
    else if (deltaMinutes < (24 * 60))
    {
        minutes = (int)floor(deltaMinutes/60.0f);
        return [NSString stringWithFormat:@"%dh",minutes];
    }
    else if (deltaMinutes<(60 * 24 * 7))
    {
        minutes = (int)floor(deltaMinutes/(60*24.0f));
        return [NSString stringWithFormat:@"%dd",minutes];
    }
    else if (deltaMinutes < (24 * 60 * 365.25))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 7.0f));
        return [NSString stringWithFormat:@"%dw",minutes];
    }
    
    minutes = (int)floor(deltaMinutes/(60 * 24 * 365.0f));
    return [NSString stringWithFormat:@"%dy",minutes];
}

- (NSString *)timeAgoLongStyle
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([self timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;

    int minutes;

    if(deltaSeconds < 60)
    {
        return [NSString stringWithFormat:@"%d sec",(int)deltaSeconds];
    }
    else if (deltaMinutes < 60)
    {
        return [NSString stringWithFormat:@"%d min",(int)deltaMinutes];
    }
    else if (deltaMinutes < (24 * 60))
    {
        minutes = (int)floor(deltaMinutes/60.0f);
        if (minutes == 1) return [NSString stringWithFormat:@"%d hour",minutes];
        return [NSString stringWithFormat:@"%d hours",minutes];
    }
    else if (deltaMinutes<(60 * 24 * 7))
    {
        minutes = (int)floor(deltaMinutes/(60*24.0f));
        if (minutes == 1) return [NSString stringWithFormat:@"%d day",minutes];
        return [NSString stringWithFormat:@"%d days",minutes];
    }
    else if (deltaMinutes < (24 * 60 * 365.25))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 7.0f));
        if (minutes == 1) return [NSString stringWithFormat:@"%d week",minutes];
        return [NSString stringWithFormat:@"%d weeks",minutes];
    }

    minutes = (int)floor(deltaMinutes/(60 * 24 * 365.0f));
    if (minutes == 1) return [NSString stringWithFormat:@"%d year",minutes];
    return [NSString stringWithFormat:@"%d years",minutes];
}


@end
