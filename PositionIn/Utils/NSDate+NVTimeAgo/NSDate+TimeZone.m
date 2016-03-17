//
//  NSDate+TimeZone.m
//  PositionIn
//
//  Created by Ruslan Kolchakov on 9/3/16.
//  Copyright (c) 2016 Soluna Labs. All rights reserved.
//

#import "NSDate+TimeZone.h"

@implementation NSDate(TimeZone)

- (NSDate *)toLocalTime {
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

- (NSDate *)toGlobalTime {
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

@end