//
//  XMPPTextMessage.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPMessage;


@interface XMPPTextMessage : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *text;
@property (nonatomic, copy, readonly, nonnull) NSString *from;
@property (nonatomic, copy, readonly, nonnull)  NSString *to;
@property (nonatomic, strong, readonly, nonnull) NSDate *date;
@end

