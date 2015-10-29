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
#import "XMPPMessage+XEP0045.h"

#import "XMPPTextMessage+Private.h"
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


#pragma mark - Client -

@interface XMPPClient ()
@property (nonatomic, strong) XMPPClientConfiguration *config;
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPDelegate *xmppDelegate;
@property (nonatomic, strong) XMPPReconnect *xmppReconect;
@property (nonatomic, strong) XMPPPing *xmppPing;

@property (nonatomic, retain) NSMutableArray *messageListeners;

@property (nonnull, nonatomic, strong) id<XMPPCredentialsProvider> credentialsProvider;

@property (readwrite, assign) BOOL authorized;


- (void)storeDirectMessage:(nonnull XMPPTextMessage *)message outgoing:(BOOL)outgoing;
- (nullable XMPPRoom *)roomWithId:(nonnull NSString *)roomId;

@property (nonatomic, copy, nonnull) NSString *currentUserId;
@property (nonatomic, strong, nonnull) NSMutableDictionary *directMessages;
@property (nonatomic, strong, nonnull) NSMutableDictionary *rooms;

@end


@implementation XMPPClient

#pragma mark - Conversations -

- (void)joinRoom:(nonnull NSString *)roomJID nickName:(nonnull NSString *)nickName lastHistoryStamp:(nonnull NSDate *)date {
    XMPPLogInfo(@"Joining room %@ (%@)", roomJID, nickName);
    XMPPJID  * jid = [XMPPJID jidWithString:roomJID];
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage new] jid: jid];
    [room activate:self.xmppStream];
    [room addDelegate:self delegateQueue:[self delegateQueue]];
    self.rooms[jid.user] = room;
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
//    [history addAttributeWithName:@"maxstanzas" intValue:20];
    [history addAttributeWithName:@"since" stringValue:[date xmppDateTimeString]];
    [room joinRoomUsingNickname:nickName history:history];
}

- (void)cleanRooms {
    for (XMPPRoom *room in [self.rooms allValues]) {
        [room removeDelegate:self];
        [room deactivate];
    }
    self.rooms = [NSMutableDictionary new];
}

- (nullable XMPPRoom *)roomWithId:(nonnull NSString *)roomId {
    return  self.rooms[roomId];
}


- (nonnull NSArray *)messagesForRoom:(nonnull NSString *)roomId {
    XMPPRoom *room = [self roomWithId:roomId];
    if (room) {
        XMPPRoomMemoryStorage *storage = room.xmppRoomStorage;
        NSMutableArray *messages = [NSMutableArray new];
        for (XMPPRoomMessageMemoryStorageObject *storedMessage in [storage messages]) {
            XMPPMessage *msg = storedMessage.message;
            if ([msg isGroupChatMessageWithBody]) {
                if (msg.from == nil) {
                    [msg addAttributeWithName:@"from" stringValue:[room.myRoomJID full]];
                }
                XMPPTextMessage *textMsg = [[XMPPTextMessage alloc] initWithMessage:msg];
                [messages addObject:textMsg];
            }
        }
        return messages;
    }
    return @[];
}


- (void)joinChat:(nonnull NSString *)userId {
    if (self.directMessages[userId] == nil) {
        self.directMessages[userId] = [NSMutableArray array];
    }
}

- (nonnull NSArray *)messagesForChat:(nonnull NSString *)userId {
    return self.directMessages[userId] != nil ? self.directMessages[userId] : @[];
}


- (void)storeDirectMessage:(nonnull XMPPTextMessage *)message outgoing:(BOOL)outgoing {
    if (outgoing) {
        message.from = self.currentUserId;
    } else {
        message.to = self.currentUserId;
    }
    NSString *chatId = outgoing ? message.to : message.from;
    [self joinChat:chatId];
    NSMutableArray *messages = self.directMessages[chatId];
    [messages addObject:message];
}


#pragma mark - Lifecycle -

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

- (dispatch_queue_t)delegateQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

#pragma mark - Stream LifeCycle -

- (void)setupStreamWithConfig:(XMPPClientConfiguration *)configuration {
    self.xmppDelegate = [XMPPDelegate new];
    self.xmppStream = [XMPPStream new];
    dispatch_queue_t delegateQueue = [self delegateQueue];
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
}


- (void)teardownStream {
    [self cleanRooms];
    
    [self.xmppPing deactivate];

    [self.xmppReconect removeDelegate:self];
    [self.xmppReconect removeDelegate:self.xmppDelegate];
    [self.xmppReconect deactivate];
    
    [self.xmppStream removeDelegate:self];
    [self.xmppStream removeDelegate:self.xmppDelegate];
    [self.xmppStream disconnect];
    
    self.xmppPing = nil;
    self.xmppReconect = nil;
    self.xmppStream = nil;
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

- (void)auth {
    XMPPCredentials *credentials = [self.credentialsProvider getChatCredentials];
    if (credentials != nil) {
        XMPPJID *jid = [XMPPJID jidWithString:credentials.jid];
        self.directMessages = [NSMutableDictionary new];
        self.currentUserId = [jid user];
        [self cleanRooms];
        XMPPAuthProcess *process = [[XMPPAuthProcess alloc] initWithStream:self.xmppStream queue:[XMPPProcess defaultProcessingQueue]];
        process.password = credentials.password;
        process.jid = jid;
        __weak XMPPClient *weakClient = self;
        [process executeWithCompletion:^(id __nullable result, NSError * __nullable error) {
            XMPPClient *client = weakClient;
            client.authorized = (error == nil);
            if (error) {
                XMPPLogError(@"Auth error: %@", [error localizedDescription]);
            }
            if (client.isAuthorized) {
                [client.delegate chatClientDidAuthorize:client];
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
        [[self roomWithId:username] sendMessageWithBody:text];
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
        [self storeDirectMessage:textMessage outgoing:true];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody]) {
        XMPPTextMessage *textMessage = [[XMPPTextMessage alloc] initWithMessage:message];
        [self storeDirectMessage:textMessage outgoing:false];
        [self.delegate chatClient:self didUpdateDirectChat:textMessage.from];
        [self broadcastMessage:textMessage room:nil];
    }
}

- (void)broadcastMessage:(XMPPTextMessage *)textMessage room:(NSString *)roomId {
    NSArray *listeners = nil;
    @synchronized(self) {
        listeners = self.messageListeners;
    }
    for (id<XMPPMessageListener> listener in listeners) {
        if (roomId) {
            [listener didReceiveGroupTextMessage:roomId text:textMessage.text from:textMessage.from to:textMessage.to date:textMessage.date];
        } else {
            [listener didReceiveTextMessage:textMessage.text from:textMessage.from to:textMessage.to date:textMessage.date];
        }
    }

}


#pragma mark - Stream disconnect -

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    [self.delegate chatClientDidDisconnect:self];
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

#pragma mark - Room Delegate -


- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    XMPPLogTrace();
}

/**
 * Invoked with the results of a request to fetch the configuration form.
 * The given config form will look something like:
 *
 * <x xmlns='jabber:x:data' type='form'>
 *   <title>Configuration for MUC Room</title>
 *   <field type='hidden'
 *           var='FORM_TYPE'>
 *     <value>http://jabber.org/protocol/muc#roomconfig</value>
 *   </field>
 *   <field label='Natural-Language Room Name'
 *           type='text-single'
 *            var='muc#roomconfig_roomname'/>
 *   <field label='Enable Public Logging?'
 *           type='boolean'
 *            var='muc#roomconfig_enablelogging'>
 *     <value>0</value>
 *   </field>
 *   ...
 * </x>
 *
 * The form is to be filled out and then submitted via the configureRoomUsingOptions: method.
 *
 * @see fetchConfigurationForm:
 * @see configureRoomUsingOptions:
 **/
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult {
    XMPPLogTrace();
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    XMPPLogTrace();
    XMPPLogInfo(@"My jid : %@ in room %@", [sender.myRoomJID full], [sender.roomJID full]);
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender {
    XMPPLogTrace();
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender didFailToDestroy:(XMPPIQ *)iqError {
    XMPPLogTrace();
}


- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    XMPPLogTrace();
}

/**
 * Invoked when a message is received.
 * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
 **/
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    XMPPLogTrace();
    XMPPLogInfo(@"MUC Message from: %@,\n msg %@", [occupantJID full], [message compactXMLString]);
    if ([message isGroupChatMessageWithBody]) {
        [self.delegate chatClient:self didUpdateGroupChat:sender.roomJID.user];
        [self broadcastMessage:[[XMPPTextMessage alloc] initWithMessage:message] room:sender.roomJID.user];
    }
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult {
    XMPPLogTrace();
}

- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError {
    XMPPLogTrace();
}


@end