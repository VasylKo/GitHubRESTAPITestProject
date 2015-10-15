//
//  XMPPClient.h
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

@import Foundation;

@protocol XMPPCredentialsProvider;
@protocol XMPPClientDelegate;
@protocol XMPPMessageListener;
@class XMPPProcess;
@class XMPPClientConfiguration;

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

@property (nullable, nonatomic, weak) id<XMPPClientDelegate> delegate;


- (void)joinRoom:(nonnull NSString *)roomJID nickName:(nonnull NSString *)nickName;
- (nonnull NSArray *)messagesForRoom:(nonnull NSString *)roomId;
- (void)cleanRooms;

- (void)joinChat:(nonnull NSString *)userId;
- (nonnull NSArray *)messagesForChat:(nonnull NSString *)userId;


@end


@protocol XMPPClientDelegate <NSObject>

- (void)chatClient:(nonnull XMPPClient *) client didUpdateDirectChat:(nonnull NSString *)userId;
- (void)chatClient:(nonnull XMPPClient *) client didUpdateGroupChat:(nonnull NSString *)roomId;
- (void)chatClientDidAuthorize:(nonnull XMPPClient *) client;
- (void)chatClientDidDisconnect:(nonnull XMPPClient *) client;

@end

@protocol XMPPMessageListener <NSObject>
- (void)didReceiveTextMessage:(nonnull NSString *)text from:(nonnull NSString *)from to:(nonnull NSString *)to date:(nonnull NSDate *)date;
- (void)didReceiveGroupTextMessage:(nonnull NSString *)roomId text:(nonnull NSString *)text from:(nonnull NSString *)from to:(nonnull NSString *)to date:(nonnull NSDate *)date;
@end


@interface XMPPClientConfiguration : NSObject
+ (nonnull instancetype)configurationWith:(nonnull NSString *)hostName port:(NSInteger)port;
+ (nonnull instancetype)defaultConfiguration;

@property (nonnull, nonatomic, copy) NSString *hostName;
@property (nonatomic, assign) NSInteger port;
@end



