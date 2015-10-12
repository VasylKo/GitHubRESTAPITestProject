//
//  XMPPConversation+Private.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 12/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPConversation.h"

@interface XMPPConversation() <NSCopying>
@property (readwrite, copy, nonnull) NSArray *participants;
@property (nonatomic, readwrite, nonnull) NSDate *lastActivityDate;
@property (nonatomic, readwrite, copy, nonnull) NSString *name;
@property (nonatomic, readwrite, strong, nullable) NSURL *imageURL;
@property (nonatomic, readwrite, assign) BOOL isMultiUser;

- (nonnull instancetype)initWithUser:(nonnull  NSString *)userId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url;
- (nonnull instancetype)initWithUser:(nonnull  NSString *)userId;
- (nonnull instancetype)initWithCommunity:(nonnull  NSString *)roomId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url;
- (nonnull instancetype)initWithCommunity:(nonnull  NSString *)roomId;
@end
