//
//  XMPPTextMessagey+Private.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 12/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPTextMessage.h"
#import "XMPPFramework.h"

@interface XMPPTextMessage()
- (nonnull instancetype)initWithMessage:(nonnull XMPPMessage *)message;
@property (nonatomic, copy, readwrite, nullable) NSString *text;
@property (nonatomic, copy, readwrite, nonnull) NSString *from;
@property (nonatomic, copy, readwrite, nonnull)  NSString *to;
@property (nonatomic, strong, readwrite, nonnull) NSDate *date;
@end