//
//  XMPPClient.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

@import Foundation;

@interface XMPPClientConfiguration : NSObject
+ (nonnull instancetype)configurationWith:(nonnull NSString *)hostName port:(NSInteger)port;
+ (nonnull instancetype)defaultConfiguration;

@property (nonnull, nonatomic, copy) NSString *hostName;
@property (nonatomic, assign) NSInteger port;
@end

@class XMPPProcess;

@interface XMPPClient : NSObject

- (nonnull instancetype)initWithConfiguration:(nonnull XMPPClientConfiguration  * )configuration;

- (nonnull XMPPProcess *)auth:(nonnull NSString *)jidString password:(nonnull  NSString *)password;
- (nonnull XMPPProcess *)registerJid:(nonnull NSString *)jidString password:(nonnull  NSString *)password;

- (void)sendTestMessage;
@property (nonatomic, readonly, assign) BOOL isConnected;
@end
