//
//  XMPPAuthProcess.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 28/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPAuthProcess.h"

static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_TRACE;

@implementation XMPPAuthProcess

- (void)run {
    self.xmppStream.myJID = self.jid;
    if ([self.xmppStream isDisconnected] && ![self.xmppStream isConnecting]) {
        NSError *error = nil;
        if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
            XMPPLogError(@"Error while connecting: %@", error);
            [self complete:nil error:error];
        }

    } else {
        [self auth];
    }
}

- (void)auth {
    NSError *error = nil;
    if(![self.xmppStream authenticateWithPassword:self.password error:&error]) {
        XMPPLogError(@"Error while authenticating: %@", error);
        [self complete:nil error:error];
    }
}

#pragma mark - stream delegate -

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    XMPPLogTrace();
    [self auth];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    XMPPLogTrace();
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addChild:[NSXMLElement elementWithName:@"priority" stringValue:@"24"]];
    [presence addChild:[NSXMLElement elementWithName:@"show" stringValue:@"chat"]];
    [self.xmppStream sendElement:presence];
    [self complete:nil error:nil];
}

/**
 * This method is called if authentication fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    XMPPLogTrace();
    [self complete:nil error:[self errorFromElement:error]];
}

@end
