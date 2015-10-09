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
@property (nonatomic, readwrite, copy, nonnull) NSString *name;
@property (nonatomic, readwrite, strong, nullable) NSURL *imageURL;

- (nonnull instancetype)initWithUser:(nonnull  NSString *)userId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url;
- (nonnull instancetype)initWithUser:(nonnull  NSString *)userId;
@end

@implementation XMPPConversation

- (nonnull instancetype)initWithUser:(nonnull  NSString *)userId {
    return [self initWithUser:userId name:@"" imageURL:nil];
}

- (NSString * __nonnull)roomId {
    return [self.participants firstObject];
}

- (nonnull instancetype)initWithUser:(nonnull  NSString *)userId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url {
    self = [super init];
    if (self) {
        self.participants = @[ userId ];
        self.lastActivityDate = [NSDate date];
        self.name = displayName;
        self.imageURL = url;
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
    XMPPConversation *conversation = [[XMPPConversation allocWithZone:zone] initWithUser:[self.participants firstObject] name:self.name imageURL:self.imageURL];
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

- (nonnull XMPPConversation *)startConversationWithUser:(nonnull NSString *)userId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url {
    XMPPConversation *conversation = [[XMPPConversation alloc] initWithUser:userId name:displayName imageURL:url];
    return [self startConversation:conversation];
}

- (nonnull XMPPConversation *)startConversation:(nonnull XMPPConversation *)conversation {
    if (self.conversations[conversation] == nil) {
        self.conversations[conversation] = [NSMutableArray new];
    }
    return conversation;
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
    XMPPConversation *conversation = nil;
    if (index == NSNotFound) {
        NSString *userId = (outgoing)? message.to : message.from;
        conversation = [self startConversation:[[XMPPConversation alloc] initWithUser:userId]];
    } else {
        conversation = conversationList[index];
    }
    conversation.lastActivityDate = [NSDate date];
    NSMutableArray *messages = self.conversations[conversation];
    [messages addObject:message];
    self.conversations[conversation] = messages;
    
}
@end