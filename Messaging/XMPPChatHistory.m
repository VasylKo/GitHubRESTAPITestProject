//
//  XMPPChatHistory.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPChatHistory+Private.h"
#import "XMPPFramework.h"
#import "XMPPMessage+XEP0045.h"

static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_TRACE;

@interface XMPPTextMessage()
@property (nonatomic, copy, readwrite, nullable) NSString *text;
@property (nonatomic, copy, readwrite, nonnull) NSString *from;
@property (nonatomic, copy, readwrite, nonnull)  NSString *to;
@property (nonatomic, strong, readwrite, nonnull) NSDate *date;
@end

@implementation XMPPTextMessage

- (nonnull instancetype)initWithMessage:(XMPPMessage *)message {
    self = [super init];
    if (self) {
        self.text = [message body];
        self.from = [message isGroupChatMessage]? [message from].full :[message from].user;
        self.to = [message to].user;
        NSDate *date = [NSDate date];
        if ([message wasDelayed]) {
            date = [message delayedDeliveryDate];
        }
        self.date = date;
    }
    return self;
}

@end


@implementation XMPPChatHistory

- (nonnull instancetype)initWithUserId:(nonnull NSString *)currentUserId stream:(nonnull XMPPStream *)stream {
    self = [super init];
    if (self) {
        self.stream = stream;
        self.directMessages = [NSMutableDictionary new];
        self.currentUserId = currentUserId;
        [self cleanRooms];
    }
    return self;
}

- (void)joinRoom:(nonnull NSString *)roomId nickName:(nonnull NSString *)nickName {
    XMPPLogInfo(@"Joining room %@ (%@)", roomId, nickName);
    dispatch_queue_t delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    XMPPJID  * roomJid = [XMPPJID jidWithString:roomId];
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage new] jid:roomJid];
    [room activate:self.stream];
    [room addDelegate:self delegateQueue:delegateQueue];
    self.rooms[roomJid.user] = room;
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"maxstanzas" intValue:20];
    [room joinRoomUsingNickname:nickName history:history];
}

- (void)cleanRooms {
    for (XMPPRoom *room in [self.rooms allValues]) {
        [room removeDelegate:self];
        [room deactivate];
    }
    self.rooms = [NSMutableDictionary new];
}

- (void)dealloc {
    [self cleanRooms];
}

- (nullable XMPPRoom *)roomWithId:(nonnull NSString *)roomId {
    return  self.rooms[roomId];
}


- (nullable NSString *)senderIdForRoom:(nonnull NSString *)roomId {
    return [self roomWithId:roomId].myRoomJID.full;
}

- (nonnull NSArray *)messagesForRoom:(nonnull NSString *)roomId {
    XMPPRoom *room = [self roomWithId:roomId];
    if (room) {
        XMPPRoomMemoryStorage *storage = room.xmppRoomStorage;
        NSMutableArray *messages = [NSMutableArray new];
        for (XMPPRoomMessageMemoryStorageObject *storedMessage in [storage messages]) {
            XMPPMessage *msg = storedMessage.message;
            if (msg.from == nil) {
                [msg addAttributeWithName:@"from" stringValue:[room.myRoomJID full]];
            }
            if (msg.to == nil) {
                [msg addAttributeWithName:@"to" stringValue:[room.myRoomJID full]];
            }
            XMPPTextMessage *textMsg = [[XMPPTextMessage alloc] initWithMessage:msg];
            [messages addObject:textMsg];
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


- (void)addDirectMessage:(nonnull XMPPTextMessage *)message outgoing:(BOOL)outgoing {
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