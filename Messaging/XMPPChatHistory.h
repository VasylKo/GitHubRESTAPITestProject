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

- (void)joinRoom:(nonnull NSString *)roomId nickName:(nonnull NSString *)nickName;
- (nullable NSString *)senderIdForRoom:(nonnull NSString *)roomId;

- (nonnull XMPPConversation *)startConversationWithUser:(nonnull NSString *)userId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url;
- (nonnull NSArray *)messagesForConversationWithUser:(nonnull NSString *)userId;
- (nonnull NSArray *)messagesForConversationWithCommunity:(nonnull NSString *)roomId;

@end
