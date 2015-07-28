//
//  XMPPClient.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPClient.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "DDTTYLogger.h"
#import "XMPPLogFormatter.h"

#import "XMPPAuthProcess.h"

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
    config.userJid = @"ixmpp@beewellapp.com";
    config.userpwd = @"1HateD0m2";
    return config;
}
@end

#pragma mark - Client

@interface XMPPClient ()
@property (nonatomic, strong) XMPPClientConfiguration *config;
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, readwrite, assign) BOOL isConnected;
@end


@implementation XMPPClient

+ (void)initialize {
    if(self == [XMPPClient class]) {
        [XMPPClient setupLog];
    }
}

- (instancetype)init {
    return [self initWithConfiguration:[XMPPClientConfiguration defaultConfiguration]];
}

- (instancetype)initWithConfiguration:(XMPPClientConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.config = configuration;
        [self setupStreamWithConfig:configuration];
    }
    return self;
}

- (void)dealloc {
    [self teardownStream];
}

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

#pragma mark - Strem LifeCycle -

- (void)setupStreamWithConfig:(XMPPClientConfiguration *)configuration {
    self.xmppStream = [XMPPStream new];
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
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.xmppStream.myJID = [XMPPJID jidWithString:configuration.userJid];
    self.xmppStream.hostName = configuration.hostName;
    self.xmppStream.hostPort = configuration.port;
/*
 self.xmppReconect = [XMPPReconnect new];
 [self.xmppReconect activate:self.xmppStream];
 [self.xmppReconect addDelegate:self delegateQueue:dispatch_get_main_queue()];
*/

}


- (void)teardownStream {
//    [self.xmppReconect removeDelegate:self];
    [self.xmppStream removeDelegate:self];
    
//    [self.xmppReconect deactivate];
    
    [self.xmppStream disconnect];
    
//    self.xmppReconect = nil;
    self.xmppStream = nil;
}


- (void)connect {
    XMPPLogInfo(@"Connecting");
    NSError *error = nil;
    
    if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        XMPPLogError(@"Error while connecting: %@", error);
    }
}

- (XMPPProcess *)auth:(XMPPJID *)jid password:(NSString *)password {
    XMPPAuthProcess *process = [[XMPPAuthProcess alloc] initWithStream:self.xmppStream queue:nil];
    process.password = password;
    process.jid = jid;
    return process;
}

- (void)auth {
    [[self auth:[XMPPJID jidWithString:self.config.userJid] password:self.config.userpwd] executeWithCompletion:^(id result, NSError *error) {
        if (error != nil) {
            XMPPLogError(@"Auth %@", error);
        } else {
            XMPPLogWarn(@"Auth done");
        }
        
    }];
    return;
    XMPPLogVerbose(@"supportsInBandRegistration %d, isSecure %d"
          ,[self.xmppStream supportsInBandRegistration]
          ,[self.xmppStream isSecure]
          );
    
    
    XMPPLogInfo(@"Start auth");
    NSString *passowrd = self.config.userpwd;
    NSError *error = nil;
    if(![self.xmppStream authenticateWithPassword:passowrd error:&error]) {
        XMPPLogError(@"Error while authenticating: %@", error);
    }
}

- (void)registerJiD:(XMPPJID *)jid {
    XMPPLogInfo(@"Registering JID: %@", jid.user);
    NSError *error = nil;
    NSString *passowrd = self.config.userpwd;
    if(![self.xmppStream registerWithPassword:passowrd error:&error]) {
        XMPPLogError(@"Error while registering: %@", error);
    }
}

- (void)didAuth {
    [self logPresense:self.xmppStream.myPresence];
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addChild:[DDXMLNode elementWithName:@"show" stringValue:@"chat"]];
    
    [self.xmppStream sendElement:presence];
}

- (void)sendTestMessage {
    
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:@"adan@beewellapp.com"]];
    [msg addBody:@"Test message"];
    XMPPLogInfo(@"Sending message %@", [msg XMLString]);
    [self.xmppStream sendElement:msg];
}


#pragma mark - Logs -

- (void)logPresense:(XMPPPresence *)presence {
    XMPPLogVerbose(@"Presense %@ %@ %@",[presence type], [presence status], [presence show]);
    XMPPLogVerbose(@"%@",[presence XMLString]);
}

- (void)logMessage:(XMPPMessage *)msg {
    XMPPLogVerbose(@"Message %@ %@ %@ %@",[msg type], [msg subject], [msg body], [msg thread]);
    XMPPLogVerbose(@"%@",[msg XMLString]);
}

@end

#pragma mark - Delegate -

@interface XMPPClient (XMPPStreamDelegate)

@end

@implementation XMPPClient (XMPPStreamDelegate)

/**
 * This method is called before the stream begins the connection process.
 *
 * If developing an iOS app that runs in the background, this may be a good place to indicate
 * that this is a task that needs to continue running in the background.
 **/
- (void)xmppStreamWillConnect:(XMPPStream *)sender {
    XMPPLogTrace();
}

/**
 * This method is called after the tcp socket has connected to the remote host.
 * It may be used as a hook for various things, such as updating the UI or extracting the server's IP address.
 *
 * If developing an iOS app that runs in the background,
 * please use XMPPStream's enableBackgroundingOnSocket property as opposed to doing it directly on the socket here.
 **/
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    XMPPLogTrace();
}

/**
 * This method is called after a TCP connection has been established with the server,
 * and the opening XML stream negotiation has started.
 **/
- (void)xmppStreamDidStartNegotiation:(XMPPStream *)sender {
    XMPPLogTrace();
}

/**
 * This method is called immediately prior to the stream being secured via TLS/SSL.
 * Note that this delegate may be called even if you do not explicitly invoke the startTLS method.
 * Servers have the option of requiring connections to be secured during the opening process.
 * If this is the case, the XMPPStream will automatically attempt to properly secure the connection.
 *
 * The dictionary of settings is what will be passed to the startTLS method of the underlying GCDAsyncSocket.
 * The GCDAsyncSocket header file contains a discussion of the available key/value pairs,
 * as well as the security consequences of various options.
 * It is recommended reading if you are planning on implementing this method.
 *
 * The dictionary of settings that are initially passed will be an empty dictionary.
 * If you choose not to implement this method, or simply do not edit the dictionary,
 * then the default settings will be used.
 * That is, the kCFStreamSSLPeerName will be set to the configured host name,
 * and the default security validation checks will be performed.
 *
 * This means that authentication will fail if the name on the X509 certificate of
 * the server does not match the value of the hostname for the xmpp stream.
 * It will also fail if the certificate is self-signed, or if it is expired, etc.
 *
 * These settings are most likely the right fit for most production environments,
 * but may need to be tweaked for development or testing,
 * where the development server may be using a self-signed certificate.
 *
 * Note: If your development server is using a self-signed certificate,
 * you likely need to add GCDAsyncSocketManuallyEvaluateTrust=YES to the settings.
 * Then implement the xmppStream:didReceiveTrust:completionHandler: delegate method to perform custom validation.
 **/
- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings {
    XMPPLogTrace();
    XMPPLogInfo(@"Settings: %@", settings);
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
    XMPPLogTrace();
#warning validation needed
    /* Custom validation for your certificate on server should be performed */
    
    completionHandler(YES); // After this line, SSL connection will be established
}

/**
 * This method is called after the stream has been secured via SSL/TLS.
 * This method may be called if the server required a secure connection during the opening process,
 * or if the secureConnection: method was manually invoked.
 **/
- (void)xmppStreamDidSecure:(XMPPStream *)sender {
    XMPPLogTrace();
}

/**
 * This method is called after the XML stream has been fully opened.
 * More precisely, this method is called after an opening <xml/> and <stream:stream/> tag have been sent and received,
 * and after the stream features have been received, and any required features have been fullfilled.
 * At this point it's safe to begin communication with the server.
 **/
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    XMPPLogTrace();
    [self auth];
}

/**
 * This method is called after registration of a new user has successfully finished.
 * If registration fails for some reason, the xmppStream:didNotRegister: method will be called instead.
 **/
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    XMPPLogTrace();
    [self auth];
}

/**
 * This method is called if registration fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {
    XMPPLogTrace();
    XMPPLogError(@"Error while registering: %@", error);
}

/**
 * This method is called after authentication has successfully finished.
 * If authentication fails for some reason, the xmppStream:didNotAuthenticate: method will be called instead.
 **/
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    XMPPLogTrace();
    [self didAuth];
}

/**
 * This method is called if authentication fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    XMPPLogTrace();
    XMPPLogError(@"Error while authenticating: %@", error);
    [self registerJiD:sender.myJID];
}

/**
 * Binding a JID resource is a standard part of the authentication process,
 * and occurs after SASL authentication completes (which generally authenticates the JID username).
 *
 * This delegate method allows for a custom binding procedure to be used.
 * For example:
 * - a custom SASL authentication scheme might combine auth with binding
 * - stream management (xep-0198) replaces binding if it can resume a previous session
 *
 * Return nil (or don't implement this method) if you wish to use the standard binding procedure.
 **/
- (id <XMPPCustomBinding>)xmppStreamWillBind:(XMPPStream *)sender {
    XMPPLogTrace();
    return nil;
}

/**
 * This method is called if the XMPP server doesn't allow our resource of choice
 * because it conflicts with an existing resource.
 *
 * Return an alternative resource or return nil to let the server automatically pick a resource for us.
 **/
- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource {
    XMPPLogTrace();
    return nil;
}

/**
 * These methods are called before their respective XML elements are broadcast as received to the rest of the stack.
 * These methods can be used to modify elements on the fly.
 * (E.g. perform custom decryption so the rest of the stack sees readable text.)
 *
 * You may also filter incoming elements by returning nil.
 *
 * When implementing these methods to modify the element, you do not need to copy the given element.
 * You can simply edit the given element, and return it.
 * The reason these methods return an element, instead of void, is to allow filtering.
 *
 * Concerning thread-safety, delegates implementing the method are invoked one-at-a-time to
 * allow thread-safe modification of the given elements.
 *
 * You should NOT implement these methods unless you have good reason to do so.
 * For general processing and notification of received elements, please use xmppStream:didReceiveX: methods.
 *
 * @see xmppStream:didReceiveIQ:
 * @see xmppStream:didReceiveMessage:
 * @see xmppStream:didReceivePresence:
 **/
- (XMPPIQ *)xmppStream:(XMPPStream *)sender willReceiveIQ:(XMPPIQ *)iq {
    XMPPLogTrace();
    return iq;
}
- (XMPPMessage *)xmppStream:(XMPPStream *)sender willReceiveMessage:(XMPPMessage *)message {
    XMPPLogTrace();
    [self logMessage:message];
    return message;
}
- (XMPPPresence *)xmppStream:(XMPPStream *)sender willReceivePresence:(XMPPPresence *)presence {
    XMPPLogTrace();
    [self logPresense:presence];
    return presence;
}

/**
 * This method is called if any of the xmppStream:willReceiveX: methods filter the incoming stanza.
 *
 * It may be useful for some extensions to know that something was received,
 * even if it was filtered for some reason.
 **/
- (void)xmppStreamDidFilterStanza:(XMPPStream *)sender {
    XMPPLogTrace();
}

/**
 * These methods are called after their respective XML elements are received on the stream.
 *
 * In the case of an IQ, the delegate method should return YES if it has or will respond to the given IQ.
 * If the IQ is of type 'get' or 'set', and no delegates respond to the IQ,
 * then xmpp stream will automatically send an error response.
 *
 * Concerning thread-safety, delegates shouldn't modify the given elements.
 * As documented in NSXML / KissXML, elements are read-access thread-safe, but write-access thread-unsafe.
 * If you have need to modify an element for any reason,
 * you should copy the element first, and then modify and use the copy.
 **/
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    XMPPLogTrace();
    return YES;
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    XMPPLogTrace();
    [self logMessage:message];
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    XMPPLogTrace();
    [self logPresense:presence];
    [self sendTestMessage];
}

/**
 * This method is called if an XMPP error is received.
 * In other words, a <stream:error/>.
 *
 * However, this method may also be called for any unrecognized xml stanzas.
 *
 * Note that standard errors (<iq type='error'/> for example) are delivered normally,
 * via the other didReceive...: methods.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error {
    XMPPLogTrace();
}

/**
 * These methods are called before their respective XML elements are sent over the stream.
 * These methods can be used to modify outgoing elements on the fly.
 * (E.g. add standard information for custom protocols.)
 *
 * You may also filter outgoing elements by returning nil.
 *
 * When implementing these methods to modify the element, you do not need to copy the given element.
 * You can simply edit the given element, and return it.
 * The reason these methods return an element, instead of void, is to allow filtering.
 *
 * Concerning thread-safety, delegates implementing the method are invoked one-at-a-time to
 * allow thread-safe modification of the given elements.
 *
 * You should NOT implement these methods unless you have good reason to do so.
 * For general processing and notification of sent elements, please use xmppStream:didSendX: methods.
 *
 * @see xmppStream:didSendIQ:
 * @see xmppStream:didSendMessage:
 * @see xmppStream:didSendPresence:
 **/
- (XMPPIQ *)xmppStream:(XMPPStream *)sender willSendIQ:(XMPPIQ *)iq {
    XMPPLogTrace();
    return iq;
}
- (XMPPMessage *)xmppStream:(XMPPStream *)sender willSendMessage:(XMPPMessage *)message {
    XMPPLogTrace();
    return message;
}
- (XMPPPresence *)xmppStream:(XMPPStream *)sender willSendPresence:(XMPPPresence *)presence {
    XMPPLogTrace();
    [self logPresense:presence];
    return presence;
}

/**
 * These methods are called after their respective XML elements are sent over the stream.
 * These methods may be used to listen for certain events (such as an unavailable presence having been sent),
 * or for general logging purposes. (E.g. a central history logging mechanism).
 **/
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq {
    XMPPLogTrace();
}
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    XMPPLogTrace();
}
- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence {
    NSLog(@"%@>%@",[[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent],NSStringFromSelector(_cmd));
    [self logPresense:presence];
}

/**
 * These methods are called after failing to send the respective XML elements over the stream.
 * This occurs when the stream gets disconnected before the element can get sent out.
 **/
- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error {
    XMPPLogTrace();
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    XMPPLogTrace();
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error {
    XMPPLogTrace();
    [self logPresense:presence];
}
/**
 * This method is called if the XMPP Stream's jid changes.
 **/
- (void)xmppStreamDidChangeMyJID:(XMPPStream *)xmppStream {
    XMPPLogTrace();
    XMPPLogInfo(@"JID(user:%@ domain:%@ resource:%@)",xmppStream.myJID.user,xmppStream.myJID.domain,xmppStream.myJID.resource);
}

/**
 * This method is called if the disconnect method is called.
 * It may be used to determine if a disconnection was purposeful, or due to an error.
 *
 * Note: A disconnect may be either "clean" or "dirty".
 * A "clean" disconnect is when the stream sends the closing </stream:stream> stanza before disconnecting.
 * A "dirty" disconnect is when the stream simply closes its TCP socket.
 * In most cases it makes no difference how the disconnect occurs,
 * but there are a few contexts in which the difference has various protocol implications.
 *
 * @see xmppStreamDidSendClosingStreamStanza
 **/
- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender {
    XMPPLogTrace();
}

/**
 * This method is called after the stream has sent the closing </stream:stream> stanza.
 * This signifies a "clean" disconnect.
 *
 * Note: A disconnect may be either "clean" or "dirty".
 * A "clean" disconnect is when the stream sends the closing </stream:stream> stanza before disconnecting.
 * A "dirty" disconnect is when the stream simply closes its TCP socket.
 * In most cases it makes no difference how the disconnect occurs,
 * but there are a few contexts in which the difference has various protocol implications.
 **/
- (void)xmppStreamDidSendClosingStreamStanza:(XMPPStream *)sender {
    XMPPLogTrace();
}

/**
 * This methods is called if the XMPP stream's connect times out.
 **/
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    XMPPLogTrace();
}

/**
 * This method is called after the stream is closed.
 *
 * The given error parameter will be non-nil if the error was due to something outside the general xmpp realm.
 * Some examples:
 * - The TCP socket was unexpectedly disconnected.
 * - The SRV resolution of the domain failed.
 * - Error parsing xml sent from server.
 *
 * @see xmppStreamConnectDidTimeout:
 **/
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    XMPPLogTrace();
    //ENOTCONN	57		/* Socket is not connected */
    XMPPLogInfo(@"Disconnected: %@", error);
}

/**
 * This method is only used in P2P mode when the connectTo:withAddress: method was used.
 *
 * It allows the delegate to read the <stream:features/> element if/when they arrive.
 * Recall that the XEP specifies that <stream:features/> SHOULD be sent.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveP2PFeatures:(NSXMLElement *)streamFeatures {
    XMPPLogTrace();
}

/**
 * This method is only used in P2P mode when the connectTo:withSocket: method was used.
 *
 * It allows the delegate to customize the <stream:features/> element,
 * adding any specific featues the delegate might support.
 **/
- (void)xmppStream:(XMPPStream *)sender willSendP2PFeatures:(NSXMLElement *)streamFeatures {
    XMPPLogTrace();
}

/**
 * These methods are called as xmpp modules are registered and unregistered with the stream.
 * This generally corresponds to xmpp modules being initailzed and deallocated.
 *
 * The methods may be useful, for example, if a more precise auto delegation mechanism is needed
 * than what is available with the autoAddDelegate:toModulesOfClass: method.
 **/
- (void)xmppStream:(XMPPStream *)sender didRegisterModule:(id)module {
    XMPPLogTrace();
}
- (void)xmppStream:(XMPPStream *)sender willUnregisterModule:(id)module {
    XMPPLogTrace();
}

/**
 * Custom elements are Non-XMPP elements.
 * In other words, not <iq>, <message> or <presence> elements.
 *
 * Typically these kinds of elements are not allowed by the XMPP server.
 * But some custom implementations may use them.
 * The standard example is XEP-0198, which uses <r> & <a> elements.
 *
 * If you're using custom elements, you must register the custom element name(s).
 * Otherwise the xmppStream will treat non-XMPP elements as errors (xmppStream:didReceiveError:).
 *
 * @see registerCustomElementNames (in XMPPInternal.h)
 **/
- (void)xmppStream:(XMPPStream *)sender didSendCustomElement:(NSXMLElement *)element {
    XMPPLogTrace();
}
- (void)xmppStream:(XMPPStream *)sender didReceiveCustomElement:(NSXMLElement *)element {
    XMPPLogTrace();
}


@end

/*
@interface XMPPClient (XMPPReconnectDelegate)

@end

@implementation XMPPClient (XMPPReconnectDelegate)

// * This method may be used to fine tune when we
// * should and should not attempt an auto reconnect.
// *
// * For example, if on the iPhone, one may want to prevent auto reconnect when WiFi is not available.


- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
    NSLog(@"%@>%@",[[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent],NSStringFromSelector(_cmd));
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags {
    NSLog(@"%@>%@",[[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent],NSStringFromSelector(_cmd));
    return YES;
}


@end

*/