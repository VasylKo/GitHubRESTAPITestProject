//
//  XMPPRegisterProcess.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 02/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPRegisterProcess.h"

static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_TRACE;

@implementation XMPPRegisterProcess

- (void)run {
    self.xmppStream.myJID = self.jid;
    if ([self.xmppStream isDisconnected] && ![self.xmppStream isConnecting]) {
        NSError *error = nil;
        if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
            XMPPLogError(@"Error while connecting: %@", error);
            [self complete:nil error:error];
        }
        
    } else {
        [self tryToRegister];
    }
}

- (void)tryToRegister {
    XMPPLogVerbose(@"supportsInBandRegistration %d, isSecure %d"
                   ,[self.xmppStream supportsInBandRegistration]
                   ,[self.xmppStream isSecure]
                   );
    
    NSError *error = nil;
    if(![self.xmppStream registerWithPassword:self.password error:&error]) {
        XMPPLogError(@"Error while authenticating: %@", error);
        [self complete:nil error:error];
    }
}

#pragma mark - stream delegate -

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    XMPPLogTrace();
    [self tryToRegister];
}

/**
 * This method is called after registration of a new user has successfully finished.
 * If registration fails for some reason, the xmppStream:didNotRegister: method will be called instead.
 **/
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    XMPPLogTrace();
    [self complete:nil error:nil];
}

/**
 * This method is called if registration fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {
    XMPPLogTrace();
    [self complete:nil error:[self errorFromElement:error]];
}

@end
