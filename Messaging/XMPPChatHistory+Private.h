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

- (nonnull instancetype)initWithUserId:(nonnull NSString *)currentUserId nick:(nonnull NSString *)nick;

@property (nonatomic, copy, readwrite, nonnull) NSString *nickName;
@property (nonatomic, copy, nonnull) NSString *currentUserId;
@property (nonatomic, strong, nonnull) NSMutableDictionary *conversations;
@property (nonatomic, strong, nonnull) NSMutableDictionary *rooms;

- (void)didDiscoverRooms:(nonnull NSArray *)rooms stream:(nonnull XMPPStream *)stream;
- (void)cleanRooms;
- (nullable XMPPRoom *)roomWithId:(nonnull NSString *)roomId;
@end
