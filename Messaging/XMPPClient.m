//
//  XMPPClient.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPClient.h"
#import "XMPPFramework.h"
#import "DDTTYLogger.h"
#import "XMPPLogFormatter.h"
#import "XMPPDelegate.h"

#import "XMPPChatHistory+Private.h"
#import "XMPPProcess+Private.h"
#import "XMPPAuthProcess.h"
#import "XMPPRegisterProcess.h"
#import "XMPPCredentials.h"

static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_TRACE;

#pragma mark - Configuration

@interface XMPPClientConfiguration ()
@property (nonatomic, copy) NSString *userJid;
@property (nonatomic, copy) NSString *userpwd;
@end

@implementation  XMPPClientConfiguration

+ (nonnull instancetype)defaultConfiguration {
    return [XMPPClientConfiguration configurationWith:@"beewellapp.com" port:5222];
}


+ (instancetype)configurationWith:(NSString *)hostName port:(NSInteger)port {
    XMPPClientConfiguration *config = [XMPPClientConfiguration new];
    config.hostName = hostName;
    config.port = port;
    return config;
}
@end

#pragma mark - Client

@interface XMPPClient ()
@property (nonatomic, strong) XMPPClientConfiguration *config;
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPDelegate *xmppDelegate;
@property (nonatomic, strong) XMPPReconnect *xmppReconect;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPPing *xmppPing;
@property (nonatomic, strong) XMPPMUC *xmppMUC;

@property (nonatomic, retain) NSMutableArray *messageListeners;

@property (nonnull, readwrite, strong) XMPPChatHistory *history;
@property (nonnull, nonatomic, strong) id<XMPPCredentialsProvider> credentialsProvider;

@property (readwrite, assign) BOOL authorized;

@end


@implementation XMPPClient

+ (void)initialize {
    if(self == [XMPPClient class]) {
        [XMPPClient setupLog];
    }
}

- (instancetype)initWithCredentialsProvider:(nonnull id<XMPPCredentialsProvider>)credentialsProvider {
    return [self initWithConfiguration: [XMPPClientConfiguration defaultConfiguration] credentialsProvider: credentialsProvider];
}

- (nonnull instancetype)initWithConfiguration:(nonnull XMPPClientConfiguration  * )configuration credentialsProvider:(nonnull id<XMPPCredentialsProvider>)credentialsProvider {
    self = [super init];
    if (self) {
        self.credentialsProvider = credentialsProvider;
        self.messageListeners = [NSMutableArray  new];
        self.config = configuration;
        [self setupStreamWithConfig:configuration];
    }
    return self;
}

- (void)dealloc {
    [self teardownStream];
}

- (void)disconnect {
    [self teardownStream];
}

- (BOOL)isConnected {
    return self.xmppStream.isConnected;
}

- (BOOL)isAuthorized {
    return [self isConnected] && [self authorized];
}

#pragma mark - Stream LifeCycle -

- (void)setupStreamWithConfig:(XMPPClientConfiguration *)configuration {
    self.xmppDelegate = [XMPPDelegate new];
    self.xmppStream = [XMPPStream new];
    dispatch_queue_t delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        self.xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif

    [self.xmppStream addDelegate:self delegateQueue:delegateQueue]; // Need for message listeners
    
    [self.xmppStream addDelegate:self.xmppDelegate delegateQueue:delegateQueue]; // Debugging

    self.xmppStream.hostName = configuration.hostName;
    self.xmppStream.hostPort = configuration.port;
    
    self.xmppPing = [XMPPPing new];
    self.xmppPing.respondsToQueries = YES;
    [self.xmppPing activate:self.xmppStream];
    
    self.xmppReconect = [XMPPReconnect new];
    [self.xmppReconect activate:self.xmppStream];
    [self.xmppReconect addDelegate:self.xmppDelegate delegateQueue:delegateQueue];
    [self.xmppReconect addDelegate:self delegateQueue:delegateQueue];
    
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:[XMPPRosterMemoryStorage new]];
    [self.xmppRoster activate:self.xmppStream];
    [self.xmppRoster addDelegate:self.xmppDelegate delegateQueue:delegateQueue];
    
    self.xmppMUC = [[XMPPMUC alloc] init];
    [self.xmppMUC addDelegate:self delegateQueue:delegateQueue];
    [self.xmppMUC addDelegate:self.xmppDelegate delegateQueue:delegateQueue];
    [self.xmppMUC activate:self.xmppStream];
}


- (void)teardownStream {
    self.nickName = nil;
    [self.history cleanRooms];
    
    [self.xmppPing deactivate];

    [self.xmppReconect removeDelegate:self];
    [self.xmppReconect removeDelegate:self.xmppDelegate];
    [self.xmppReconect deactivate];
    
    [self.xmppRoster removeDelegate:self.xmppDelegate];
    [self.xmppRoster deactivate];

    [self.xmppMUC removeDelegate:self];
    [self.xmppMUC removeDelegate:self.xmppDelegate];
    [self.xmppMUC deactivate];
    
    [self.xmppStream removeDelegate:self];
    [self.xmppStream removeDelegate:self.xmppDelegate];
    [self.xmppStream disconnect];
    
    self.xmppPing = nil;
    self.xmppReconect = nil;
    self.xmppRoster = nil;
    self.xmppMUC = nil;
    self.xmppStream = nil;
    
    self.history = [XMPPChatHistory new];
}

#pragma mark - Log -

+ (void)setupLog {
    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
    [ttyLogger setColorsEnabled:YES];
    [ttyLogger setLogFormatter:[XMPPLogFormatter new]];
    UIColor *errorColor = [UIColor colorWithRed:(214/255.0f) green:(57/255.0f) blue:(30/255.0f) alpha:1.0f];
    UIColor *warningColor= [UIColor yellowColor];
    UIColor *infoColor = [UIColor colorWithRed:0.819 green:0.931 blue:0.976 alpha:1.000];
    UIColor *verboseColor = [UIColor lightGrayColor];
    UIColor *xmlColor = [UIColor colorWithRed: 0.3619 green: 0.3619 blue: 0.3619 alpha: 1.0];
    [ttyLogger setForegroundColor:errorColor backgroundColor:nil forFlag:XMPP_LOG_FLAG_ERROR context:XMPP_LOG_CONTEXT];
    [ttyLogger setForegroundColor:warningColor backgroundColor:nil forFlag:XMPP_LOG_FLAG_WARN context:XMPP_LOG_CONTEXT];
    [ttyLogger setForegroundColor:infoColor backgroundColor:nil forFlag:XMPP_LOG_FLAG_INFO context:XMPP_LOG_CONTEXT];
    [ttyLogger setForegroundColor:verboseColor backgroundColor:nil forFlag:XMPP_LOG_FLAG_VERBOSE context:XMPP_LOG_CONTEXT];
    [ttyLogger setForegroundColor:verboseColor backgroundColor:nil forFlag:XMPP_LOG_FLAG_TRACE context:XMPP_LOG_CONTEXT];
    [ttyLogger setForegroundColor:xmlColor backgroundColor:nil forFlag:XMPP_LOG_FLAG_SEND context:XMPP_LOG_CONTEXT];
    [ttyLogger setForegroundColor:xmlColor backgroundColor:nil forFlag:XMPP_LOG_FLAG_RECV_POST context:XMPP_LOG_CONTEXT];
    
    [DDLog addLogger:ttyLogger withLogLevel:XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_SEND_RECV | XMPP_LOG_FLAG_TRACE];
    //        [DDLog addLogger:[DDASLLogger sharedInstance]];

}


#pragma mark - Processes -

- (void)updateRooms {
    [self.xmppMUC discoverServices];
}

- (void)auth {
    XMPPCredentials *credentials = [self.credentialsProvider getChatCredentials];
    if (credentials != nil) {
        XMPPJID *jid = [XMPPJID jidWithString:credentials.jid];
        self.history = [[XMPPChatHistory alloc] initWithUserId:[jid user] nick:self.nickName];
        XMPPAuthProcess *process = [[XMPPAuthProcess alloc] initWithStream:self.xmppStream queue:[XMPPProcess defaultProcessingQueue]];
        process.password = credentials.password;
        process.jid = jid;
        __weak XMPPClient *weakClient = self;
        [process executeWithCompletion:^(id __nullable result, NSError * __nullable error) {
            XMPPClient *client = weakClient;
            client.authorized = (error == nil);
            if (error) {
                XMPPLogError(@"Auth error: %@", [error localizedDescription]);
            } else {
                [client updateRooms];
            }
        }];
    } else {
        XMPPLogWarn(@"Empty credentials");
    }
}

- (nonnull XMPPProcess *)registerJid:(nonnull NSString *)jidString password:(nonnull  NSString *)password {
    XMPPRegisterProcess *process = [[XMPPRegisterProcess alloc] initWithStream:self.xmppStream queue:[XMPPProcess defaultProcessingQueue]];
    XMPPJID *jid = [XMPPJID jidWithString:jidString];
    process.password = password;
    process.jid = jid;
    return process;
}

- (void)sendTextMessage:(nonnull NSString *)text to:(nonnull NSString *)username groupChat:(BOOL)groupChat {
    if (groupChat) {
        [[self.history roomWithId:username] sendMessageWithBody:text];     
    } else {
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", username, self.config.hostName]];
        XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:jid];
        [msg addBody:text];
        XMPPLogInfo(@"Sending message %@", [msg XMLString]);
        [self.xmppStream sendElement:msg];
    }
}


#pragma mark - Message listeners -

- (void)addMessageListener:(nonnull id<XMPPMessageListener>)listener {
    @synchronized(self) {
        [self.messageListeners addObject:listener];
    }
}

- (void)removeMessageListener:(nonnull id<XMPPMessageListener>)listener {
    @synchronized(self) {
        [self.messageListeners removeObject:listener];
    }
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody]) {
        XMPPTextMessage *textMessage = [[XMPPTextMessage alloc] initWithMessage:message];
        [self.history addTextMessage:textMessage outgoing:true];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody]) {
        XMPPTextMessage *textMessage = [[XMPPTextMessage alloc] initWithMessage:message];
        [self.history addTextMessage:textMessage outgoing:false];
        
        NSArray *listeners = nil;
        @synchronized(self) {
            listeners = self.messageListeners;
        }
        NSString *text = [message body];
        NSString *from = [message from].user;
        NSString *to = [message to].user;
        NSDate *date = [NSDate date];
        if ([message wasDelayed]) {
            date = [message delayedDeliveryDate];
        }
        for (id<XMPPMessageListener> listener in listeners) {
            [listener didReceiveTextMessage:text from:from to:to date:date];
        }
    }
}

#pragma mark - MUC -

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverServices:(NSArray *)services {
    XMPPLogInfo(@"Services: %@", services);
    static NSString  *const chatServiceName = @"Public Chatrooms";
    [services enumerateObjectsUsingBlock:^(NSXMLElement *service, NSUInteger idx, BOOL *stop) {
//        if ([[[service attributeForName:@"name"] stringValue] isEqualToString:chatServiceName]) {
            [sender discoverRoomsForServiceNamed:[[service attributeForName:@"jid"] stringValue]];
//            *stop = YES;
//        }
    }];
}

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverRooms:(NSArray *)rooms forServiceNamed:(NSString *)serviceName {
    XMPPLogInfo(@"Rooms: %@", rooms);
    [self.history didDiscoverRooms:rooms stream:sender.xmppStream];
}


#pragma mark - Reconnect -

// * This method may be used to fine tune when we
// * should and should not attempt an auto reconnect.
// *
// * For example, if on the iPhone, one may want to prevent auto reconnect when WiFi is not available.


- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
    XMPPLogTrace();
    [self auth];
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags {
    XMPPLogTrace();
    return NO;
}


@end