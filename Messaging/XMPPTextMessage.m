//
//  XMPPTextMessage.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPTextMessage+Private.h"
#import "XMPPMessage+XEP0045.h"


@implementation XMPPTextMessage

- (nonnull instancetype)initWithMessage:(XMPPMessage *)message {
    NSDate *date = [NSDate date];
    if ([message wasDelayed]) {
        date = [message delayedDeliveryDate];
    }
    NSString *from = [message isGroupChatMessage] ? [message from].resource :[message from].user;
    NSString *to = [message isGroupChatMessage] ? [message to].resource :[message to].user;

    return [self init:[message body] from:from to:to date:date];
}

- (nonnull instancetype)init:(nullable NSString *)text from:(nonnull NSString *)from to:(nonnull NSString *)to date:(nonnull NSDate *)date {
    self = [super init];
    if (self != nil) {
        self.text = text;
        self.from = from;
        self.to = to;
        self.date = date;
    }
    return self;
}

- (instancetype)init {
    return [self init:nil from:@"" to:@"" date:[NSDate date]];
}
@end

