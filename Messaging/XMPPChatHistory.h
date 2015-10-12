//
//  XMPPChatHistory.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPMessage;
@class XMPPConversation;

@interface XMPPTextMessage : NSObject
- (nonnull instancetype)initWithMessage:(nonnull XMPPMessage *)message;
@property (nonatomic, copy, readonly, nullable) NSString *text;
@property (nonatomic, copy, readonly, nonnull) NSString *from;
@property (nonatomic, copy, readonly, nonnull)  NSString *to;
@property (nonatomic, strong, readonly, nonnull) NSDate *date;
@end

@interface XMPPChatHistory : NSObject
- (nonnull instancetype)initWithUserId:(nonnull NSString *)currentUserId nick:(nonnull NSString *)nick;
- (nonnull NSArray *)conversationList;
- (nonnull XMPPConversation *)startConversationWithUser:(nonnull NSString *)userId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url;
- (nonnull NSArray *)messagesForConversationWithUser:(nonnull NSString *)userId;
- (nonnull NSArray *)messagesForConversationWithCommunity:(nonnull NSString *)roomId;
- (void)addTextMessage:(nonnull XMPPTextMessage *)message outgoing:(BOOL)outgoing;

@property (nonatomic, copy, readonly, nonnull) NSString *nickName;
@end
