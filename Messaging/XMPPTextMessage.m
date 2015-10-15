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
    self = [super init];
    if (self) {
        self.text = [message body];
        self.from = [message isGroupChatMessage] ? [message from].resource :[message from].user;
        self.to = [message isGroupChatMessage] ? [message to].resource :[message to].user;
        NSDate *date = [NSDate date];
        if ([message wasDelayed]) {
            date = [message delayedDeliveryDate];
        }
        self.date = date;
    }
    return self;
}

@end

