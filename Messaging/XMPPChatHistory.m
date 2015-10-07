//
//  XMPPChatHistory.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPChatHistory.h"
#import "XMPPFramework.h"

static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_TRACE;

@interface XMPPConversation() <NSCopying>
@property (readwrite, copy) NSArray *participants;
@property (nonatomic, readwrite, nonnull) NSDate *lastActivityDate;
@end

@implementation XMPPConversation
- (instancetype)initWithUser:(NSString *)userId {
    self = [super init];
    if (self) {
        self.participants = @[ userId ];
        self.lastActivityDate = [NSDate date];
    }
    return self;
}

- (BOOL)isEqual:(id)anObject {
    if (![anObject isKindOfClass:[XMPPConversation class]]) {
        return NO;
    }
    XMPPConversation *otherConversation = (XMPPConversation *)anObject;
    return [self.participants isEqual:otherConversation.participants];
}

- (NSUInteger)hash {
    return [self.participants hash];
}

- (id)copyWithZone:(NSZone *)zone {
    XMPPConversation *conversation = [[XMPPConversation allocWithZone:zone] initWithUser:[self.participants firstObject]];
    conversation.lastActivityDate = self.lastActivityDate;
    return conversation;
}
@end

@interface XMPPTextMessage()
@property (nonatomic, copy, readwrite, nullable) NSString *text;
@property (nonatomic, copy, readwrite, nonnull) NSString *from;
@property (nonatomic, copy, readwrite, nonnull)  NSString *to;
@property (nonatomic, strong, readwrite, nonnull) NSDate *date;
@end

@implementation XMPPTextMessage

- (nonnull instancetype)initWithMessage:(XMPPMessage *)message {
    self = [super init];
    if (self) {
        self.text = [message body];
        self.from = [message from].user;
        self.to = [message to].user;
        NSDate *date = [NSDate date];
        if ([message wasDelayed]) {
            date = [message delayedDeliveryDate];
        }
        self.date = date;
    }
    return self;
}

@end

@interface XMPPChatHistory()
@property (nonatomic, copy) NSString *currentUserId;
@property (nonatomic, strong) NSMutableDictionary *conversations;
@end

@implementation XMPPChatHistory

- (nonnull instancetype)initWithCurrentUser:(nonnull NSString *)currentUserId {
    self = [super init];
    if (self) {
        self.conversations = [NSMutableDictionary new];
        self.currentUserId = currentUserId;
    }
    return self;
}

- (NSArray *)conversationList {
    return  [self.conversations allKeys];
}

- (void)startConversationWithUser:(nonnull NSString *)userId {
    XMPPConversation *conversation = [[XMPPConversation alloc] initWithUser:userId];
    if (self.conversations[conversation] == nil) {
        self.conversations[conversation] = [NSMutableArray new];
    }
}


- (nonnull NSArray *)messagesForConversationWithUser:(nonnull NSString *)userId {
    XMPPConversation *conversation = [[XMPPConversation alloc] initWithUser:userId];
    return self.conversations[conversation] ?: @[];
}

- (void)addTextMessage:(nonnull XMPPTextMessage *)message outgoing:(BOOL)outgoing {
    if (outgoing) {
        message.from = self.currentUserId;
    } else {
        message.to = self.currentUserId;
    }
    NSString *user = outgoing ? message.to : message.from;
    NSArray *conversationList = [self conversationList];
    NSUInteger index = [conversationList indexOfObjectPassingTest:^BOOL(XMPPConversation *conversation, NSUInteger idx, BOOL *stop) {
        return [conversation.participants containsObject:user];
    }];
    if (index != NSNotFound) {
        XMPPConversation *conversation = conversationList[index];
        NSMutableArray *messages = self.conversations[conversation];
        [messages addObject:message];
        self.conversations[conversation] = messages;
    } else {
        XMPPLogError(@"Invalid conversation for message %@", message);
    }
    
}
@end