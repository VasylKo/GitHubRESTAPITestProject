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

@property (readonly, copy, nonnull ) NSArray *participants;
@property (nonatomic, readonly, nonnull) NSDate *lastActivityDate;
@property (nonatomic, readonly, copy, nonnull) NSString *name;
@property (nonatomic, readonly, strong, nullable) NSURL *imageURL;
@property (nonatomic, readonly, copy, nonnull) NSString *roomId;
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
- (nonnull XMPPConversation *)startConversationWithUser:(nonnull NSString *)userId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url;
- (nonnull NSArray *)messagesForConversationWithUser:(nonnull NSString *)userId;
- (void)addTextMessage:(nonnull XMPPTextMessage *)message outgoing:(BOOL)outgoing;
@end
