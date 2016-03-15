//
//  NSDate+TimeZone.h
//  PositionIn
//
//  Created by Ruslan Kolchakov on 9/3/16.
//  Copyright (c) 2016 Soluna Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TimeZone)

- (NSDate *)toLocalTime;
- (NSDate *)toGlobalTime;

@end