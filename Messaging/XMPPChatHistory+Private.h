//
//  XMPPChatHistory+Private.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 12/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPChatHistory.h"
#import "XMPPFramework.h"

@interface XMPPChatHistory()

- (nonnull instancetype)initWithUserId:(nonnull NSString *)currentUserId stream:(nonnull XMPPStream *)stream;

@property (nonatomic, copy, nonnull) NSString *currentUserId;
@property (nonatomic, strong, nonnull) NSMutableDictionary *directMessages;
@property (nonatomic, strong, nonnull) NSMutableDictionary *rooms;
@property (nonatomic, weak, nullable) XMPPStream *stream;

- (void)addDirectMessage:(nonnull XMPPTextMessage *)message outgoing:(BOOL)outgoing;
- (void)cleanRooms;
- (nullable XMPPRoom *)roomWithId:(nonnull NSString *)roomId;
@end
