//
//  ConversationManager.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import BrightFutures
import CleanroomLogger
import PosInCore
import Messaging

final class ConversationManager: NSObject {
    
    internal func updateUserId(objectId: CRUDObjectId) {
        flush()
        currentUserId = objectId
        refresh()
    }
    
    internal func sendText(text: String, conversation: Conversation) {
        conversation.lastActivityDate = NSDate()
        chat().sendTextMessage(text, to: conversation.roomId, groupChat: conversation.isGroupChat)
    }
    
    internal func didEnterConversation(conversation: Conversation) {
        if conversation.isGroupChat == false {
            directConversations.insert(conversation)
        } else if mucConversations.contains(conversation) == false {
            Log.error?.message("Unknown group chat \(conversation.roomId)")
        }
        conversation.resetUnreadCount()
        sendConversationDidChangeNotification()
    }
    
    internal func didLeaveConversation(conversation: Conversation) {
        sendConversationDidChangeNotification()
    }
    
    internal func getHistory(conversation: Conversation) -> [XMPPTextMessage] {
        if conversation.isGroupChat {
            return chat().messagesForRoom(conversation.roomId) as! [XMPPTextMessage]
        } else {
            return chat().messagesForChat(conversation.roomId)as! [XMPPTextMessage]
        }
    }
    
    internal func getSenderId(conversation: Conversation) -> String {
        return currentUserId
    }
    
    internal func conversations() ->  [Conversation] {
        return Array(directConversations.union(mucConversations)).sort {
            return $0.lastActivityDate.compare($1.lastActivityDate) == NSComparisonResult.OrderedDescending
        }
    }
    
    internal func countUnreadConversations() -> UInt {
        return conversations().reduce(0) { count, conversation in conversation.unreadCount > 0 ? count + 1 : count }
    }
    
    internal func refresh() {
        refreshDirectConversations()
        refreshMucConversations()
    }
    
    
    internal func groupConversation(roomId: String) -> Conversation? {
        return Array(mucConversations).filter { $0.roomId == roomId }.first
    }
    
    internal func directConversation(roomId: String) -> Conversation? {
        return Array(directConversations).filter { $0.roomId == roomId }.first
    }
    
    func flush() {
        currentUserId = CRUDObjectInvalidId
        directConversations = []
        mucConversations = []
    }
    
    private func refreshDirectConversations() {
    }
    
    private func refreshMucConversations() {
        api().getUserCommunities(currentUserId).onSuccess { [weak self] response in
            self?.populateMucConversations(response.items.map { Conversation(community: $0) })
            self?.sendConversationDidChangeNotification()
        }
    }
    
    private func populateMucConversations(conversations: [Conversation]) {
        if chat().isAuthorized == false {
            dispatch_delay(0.5) { [weak self] in
                self?.populateMucConversations(conversations)
            }
            return
        }
        mucConversations = Set(conversations)
        let host = AppConfiguration().xmppHostname
        let jid: (String) -> String = { user in
            return "\(user)@conference.\(host)"
        }
        let chatClient = chat()
        chatClient.cleanRooms()
        for conversation in conversations {
            chatClient.joinRoom(jid(conversation.roomId), nickName: currentUserId, lastHistoryStamp: conversation.lastActivityDate)
        }
    }
    
    class func sharedInstance() -> ConversationManager {
        struct Shared {
            static let instance = ConversationManager()
        }
        return Shared.instance
    }
    
    private func sendConversationDidChangeNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(ConversationManager.ConversationsDidChangeNotification, object: self)
    }
    
    private var directConversations = Set<Conversation>()
    private var mucConversations = Set<Conversation>()
    private var currentUserId: CRUDObjectId = CRUDObjectInvalidId
    
    static let ConversationsDidChangeNotification = "ConversationsDidChangeNotification"
}


extension ConversationManager: XMPPClientDelegate {
    func chatClient(client: XMPPClient, didUpdateDirectChat userId: String) {
        if let conversation = (Array(directConversations).filter { $0.roomId == userId }).first {
            conversation.didChange()
            sendConversationDidChangeNotification()
        } else {
            api().getUsers([userId]).onSuccess { [weak self] response in
                if let info = response.items.first {
                    let conversation = Conversation(user: info)
                    conversation.didChange()
                    self?.directConversations.insert(Conversation(user: info))
                }
            }
        }
    }
    
    func chatClient(client: XMPPClient, didUpdateGroupChat roomId: String) {
        if let conversation = (Array(mucConversations).filter { $0.roomId == roomId }).first {
            conversation.didChange()
            sendConversationDidChangeNotification()
        } else {
             Log.error?.message("Unknown group chat \(roomId)")
        }
    }
    
    func chatClientDidAuthorize(client: XMPPClient) {
        refresh()
    }
    
    func chatClientDidDisconnect(client: XMPPClient) {
        //TODO: clean
    }
   
}