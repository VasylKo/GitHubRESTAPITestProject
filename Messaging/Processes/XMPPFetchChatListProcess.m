//
//  XMPPFetchChatList.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 24/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

#import "XMPPFetchChatListProcess.h"
#import "XMPPMUC.h"

static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_TRACE;

@interface XMPPFetchChatListProcess ()
@property (nonatomic, strong) XMPPMUC *xmppMuc;
@end

@implementation XMPPFetchChatListProcess


- (void)run {
    if ( self.serviceName == nil ) {
        NSError *error = [self errorWithReason:NSLocalizedString(@"Invalid Service Name", "XMPP Invalid Service Name")];
        [self complete:nil error:error];
        return;
    }

    self.xmppMuc = [XMPPMUC new];
    [self.xmppMuc activate:self.xmppStream];
    [self.xmppMuc addDelegate:self delegateQueue:[[self class] defaultProcessingQueue]];
    [self.xmppMuc discoverServices];
    
}

- (void)dealloc {
    [self.xmppMuc removeDelegate:self];
    [self.xmppMuc deactivate];
}

#pragma mark - Muc Delegate -

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message {
    
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitationDecline:(XMPPMessage *)message {
    
}

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverServices:(NSArray *)services {
    XMPPLogInfo(@"Services: \n%@", services);
    NSString *const kChatServiceName = @"Public Chatrooms";
    for (NSXMLElement *service in services) {
        if ([[[service attributeForName:@"name"] stringValue] isEqualToString:kChatServiceName]) {
            [self.xmppMuc discoverRoomsForServiceNamed:[[service attributeForName:@"jid"] stringValue]];
            return;
        }
    }
    NSError *error = [self errorWithReason:NSLocalizedString(@"Could not find service", "XMPP Could not find service")];
    
    [self complete:nil error:error];
}

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverRooms:(NSArray *)rooms forServiceNamed:(NSString *)serviceName {
    XMPPLogInfo(@"Rooms: \n%@", rooms);
    [self complete:rooms error:nil];
}


- (void)xmppMUC:(XMPPMUC *)sender failedToDiscoverRoomsForServiceNamed:(NSString *)serviceName withError:(NSError *)error {
    [self complete:nil error:error];
}

- (void)xmppMUCFailedToDiscoverServices:(XMPPMUC *)sender withError:(NSError *)error {
    [self complete:nil error:error];
}

@end
