//
//  XMPPClient.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

@import Foundation;

@class XMPPChatHistory;
@protocol XMPPCredentialsProvider;

@interface XMPPClientConfiguration : NSObject
+ (nonnull instancetype)configurationWith:(nonnull NSString *)hostName port:(NSInteger)port;
+ (nonnull instancetype)defaultConfiguration;

@property (nonnull, nonatomic, copy) NSString *hostName;
@property (nonatomic, assign) NSInteger port;
@end

@class XMPPProcess;

@protocol XMPPMessageListener <NSObject>
- (void)didReceiveTextMessage:(nonnull NSString *)text from:(nonnull NSString *)from to:(nonnull NSString *)to date:(nonnull NSDate *)date;
@end

@interface XMPPClient : NSObject

- (nonnull instancetype)initWithConfiguration:(nonnull XMPPClientConfiguration  * )configuration credentialsProvider:(nonnull id<XMPPCredentialsProvider>)credentialsProvider;

- (void)auth;
- (nonnull XMPPProcess *)registerJid:(nonnull NSString *)jidString password:(nonnull  NSString *)password;

- (void)sendTextMessage:(nonnull NSString *)text to:(nonnull NSString *)username groupChat:(BOOL)groupChat;

- (void)addMessageListener:(nonnull id<XMPPMessageListener>)listener;
- (void)removeMessageListener:(nonnull id<XMPPMessageListener>)listener;

@property (nonatomic, readonly, assign) BOOL isAuthorized;
@property (nonatomic, readonly, assign) BOOL isConnected;
- (void)disconnect;

@property (nonatomic, copy, nullable) NSString *nickName;

@property (nonnull, readonly, strong) XMPPChatHistory *history;
@end
