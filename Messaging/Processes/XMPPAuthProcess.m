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
    XMPPLogVerbose(@"supportsInBandRegistration %d, isSecure %d"
                   ,[self.xmppStream supportsInBandRegistration]
                   ,[self.xmppStream isSecure]
                   );

    XMPPLogInfo(@"Start auth");
    NSError *error = nil;
    if(![self.xmppStream authenticateWithPassword:self.password error:&error]) {
        XMPPLogError(@"Error while authenticating: %@", error);
    }
    [self complete:nil error:error];
}

@end
