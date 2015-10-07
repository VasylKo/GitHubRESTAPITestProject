//
//  XMPPChatHistory.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPMessage;

@interface XMPPConversation : NSObject
- (nonnull instancetype)initWithUser:(nonnull  NSString *)userId;
@property (readonly, copy, nonnull ) NSArray *participants;
@property (nonatomic, readonly, nonnull) NSDate *lastActivityDate;
@end

@interface XMPPTextMessage : NSObject
- (nonnull instancetype)initWithMessage:(nonnull XMPPMessage *)message;
@property (nonatomic, copy, readonly, nullable) NSString *text;
@property (nonatomic, copy, readonly, nonnull) NSString *from;
@property (nonatomic, copy, readonly, nonnull)  NSString *to;
@property (nonatomic, strong, readonly, nonnull) NSDate *date;
@end

@interface XMPPChatHistory : NSObject
- (nonnull instancetype)initWithCurrentUser:(nonnull NSString *)currentUserId;
- (nonnull NSArray *)conversationList;
- (void)startConversationWithUser:(nonnull NSString *)userId;
- (nonnull NSArray *)messagesForConversationWithUser:(nonnull NSString *)userId;
- (void)addTextMessage:(nonnull XMPPTextMessage *)message outgoing:(BOOL)outgoing;
@end
