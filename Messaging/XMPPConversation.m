//
//  XMPPConversation.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 12/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPConversation+Private.h"


@implementation XMPPConversation

- (nonnull instancetype)initWithCommunity:(nonnull  NSString *)roomId {
    return [self initWithCommunity:roomId name:@"" imageURL:nil];
}

- (nonnull instancetype)initWithCommunity:(nonnull  NSString *)roomId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url {
    self = [super init];
    if  (self) {
        self.participants = @[ roomId ];
        self.lastActivityDate = [NSDate date];
        self.name = displayName;
        self.imageURL = url;
        self.isMultiUser = YES;
    }
    return self;
}

- (nonnull instancetype)initWithUser:(nonnull  NSString *)userId {
    return [self initWithUser:userId name:@"" imageURL:nil];
}

- (nonnull instancetype)initWithUser:(nonnull  NSString *)userId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url {
    self = [super init];
    if (self) {
        self.participants = @[ userId ];
        self.lastActivityDate = [NSDate date];
        self.name = displayName;
        self.imageURL = url;
        self.isMultiUser = NO;
    }
    return self;
}

- (NSString * __nonnull)roomId {
    return [self.participants firstObject];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{%@ -> Group:%d,Occupants:%@}",[super description], self.isMultiUser, self.participants];
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
    XMPPConversation *conversation;
    if (self.isMultiUser) {
        conversation = [[XMPPConversation allocWithZone:zone] initWithCommunity:[self.participants firstObject] name:self.name imageURL:self.imageURL];
    } else {
        conversation = [[XMPPConversation allocWithZone:zone] initWithUser:[self.participants firstObject] name:self.name imageURL:self.imageURL];        
    }
    conversation.lastActivityDate = self.lastActivityDate;
    return conversation;
}
@end
