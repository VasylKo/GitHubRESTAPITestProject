//
//  XMPPChatHistory.m
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

#import "XMPPChatHistory+Private.h"
#import "XMPPFramework.h"
#import "XMPPConversation+Private.h"

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
        self.from = [message from].user;
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

- (nonnull instancetype)initWithUserId:(nonnull NSString *)currentUserId nick:(nonnull NSString *)nick {
    self = [super init];
    if (self) {
        self.conversations = [NSMutableDictionary new];
        self.rooms = [NSMutableDictionary new];
        self.currentUserId = currentUserId;
        self.nickName = nick;
    }
    return self;
}

- (void)didDiscoverRooms:(nonnull NSArray *)rooms stream:(nonnull XMPPStream *)stream {
    self.rooms = [NSMutableDictionary new];
    dispatch_queue_t delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSXMLElement *roomXML in rooms) {
        NSString * __nonnull roomId = [[roomXML attributeForName:@"jid"] stringValue];
        NSString *roomName = [[roomXML attributeForName:@"name"] stringValue];
        XMPPConversation *conversation = [[XMPPConversation alloc] initWithCommunity:roomId name:roomName imageURL:nil];
        XMPPJID  * roomJid = [XMPPJID jidWithString:roomId];
        XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomMemoryStorage new] jid:roomJid];
        [room activate:stream];
        [room addDelegate:self delegateQueue:delegateQueue];
#warning check if already exist
        self.rooms[conversation] = room;
        NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
        [history addAttributeWithName:@"maxstanzas" intValue:20];
        [room joinRoomUsingNickname:self.nickName history:history];
    }
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


- (NSArray *)conversationList {
    return  [[self.conversations allKeys] arrayByAddingObjectsFromArray:[self.rooms allKeys]];
}

- (nonnull XMPPConversation *)startConversationWithUser:(nonnull NSString *)userId name:(nonnull NSString*)displayName imageURL:(nullable NSURL *)url {
    XMPPConversation *conversation = [[XMPPConversation alloc] initWithUser:userId name:displayName imageURL:url];
    return [self startConversation:conversation];
}

- (nonnull XMPPConversation *)startConversation:(nonnull XMPPConversation *)conversation {
    if (self.conversations[conversation] == nil) {
        self.conversations[conversation] = [NSMutableArray new];
    }
    return conversation;
}


- (nonnull NSArray *)messagesForConversationWithUser:(nonnull NSString *)userId {
    XMPPConversation *conversation = [[XMPPConversation alloc] initWithUser:userId];
    return self.conversations[conversation] ?: @[];
}

- (nonnull NSArray *)messagesForConversationWithCommunity:(nonnull NSString *)roomId {
    XMPPRoom *room = [self roomWithId:roomId];
    if (room) {
        XMPPRoomMemoryStorage *storage = room.xmppRoomStorage;
        NSMutableArray *messages = [NSMutableArray new];
        for (XMPPRoomMessageMemoryStorageObject *storedMessage in [storage messages]) {
            XMPPTextMessage *msg = [[XMPPTextMessage alloc] initWithMessage:storedMessage.message];
            [messages addObject:msg];
        }
        return messages;
    }
    return @[];
}

- (nullable XMPPRoom *)roomWithId:(nonnull NSString *)roomId {
    XMPPConversation *conversation = [[XMPPConversation alloc] initWithCommunity:roomId];
    return  self.rooms[conversation];
}

- (void)addTextMessage:(nonnull XMPPTextMessage *)message outgoing:(BOOL)outgoing {
    if (outgoing) {
        message.from = self.currentUserId;
    } else {
        message.to = self.currentUserId;
    }
    NSString *user = outgoing ? message.to : message.from;
    NSArray *conversationList = [self conversationList];
    NSUInteger index = [conversationList indexOfObjectPassingTest:^BOOL(XMPPConversation *conversation, NSUInteger idx, BOOL *stop) {
        return [conversation.participants containsObject:user];
    }];
    XMPPConversation *conversation = nil;
    if (index == NSNotFound) {
        NSString *userId = (outgoing)? message.to : message.from;
        conversation = [self startConversation:[[XMPPConversation alloc] initWithUser:userId]];
    } else {
        conversation = conversationList[index];
    }
    conversation.lastActivityDate = [NSDate date];
    NSMutableArray *messages = self.conversations[conversation];
    [messages addObject:message];
    self.conversations[conversation] = messages;
    
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