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
    
    internal func refresh() {
        updateUserId(currentUserId)
    }
    
    internal func updateUserId(objectId: CRUDObjectId) {
        saveConversations()
        currentUserId = objectId
        loadConversations()
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
        saveConversations()
        sendConversationDidChangeNotification()
    }
    
    internal func getHistory(conversation: Conversation) -> [XMPPTextMessage] {
        guard let chatHistory = chatHistory else {
            return []
        }
        if conversation.isGroupChat {
            return chatHistory.messagesForRoom(conversation.roomId)
        } else {
            return chatHistory.messagesForChat(conversation.roomId)
        }
    }
    
    internal func getSenderId(conversation: Conversation) -> String {
        return currentUserId
    }
    
    internal func conversations() ->  [Conversation] {
        return directConversations.union(visibleGroupConversations()).sort {
            return $0.lastActivityDate.compare($1.lastActivityDate) == NSComparisonResult.OrderedDescending
        }
    }
    
    func visibleGroupConversations() -> [Conversation] {
        return mucConversations.filter { $0.visible == true }
    }
    
    func hiddenGroupConversations() -> [Conversation] {
        return mucConversations.filter { $0.visible == false }
    }
    
    internal func countUnreadConversations() -> UInt {
        return conversations().reduce(0) { count, conversation in conversation.unreadCount > 0 ? count + 1 : count }
    }
    
    
    internal func groupConversation(roomId: String) -> Conversation? {
        return Array(mucConversations).filter { $0.roomId == roomId }.first
    }
    
    internal func directConversation(roomId: String) -> Conversation? {
        return Array(directConversations).filter { $0.roomId == roomId }.first
    }
    
    private func loadConversations() {
        directConversations = Set()
        mucConversations = Set()
        if let allConversations = chatHistory?.loadConversations() {
            directConversations = Set(allConversations.filter( { $0.isGroupChat == false }))
            sendConversationDidChangeNotification()
            let storedMucConversations = allConversations.filter { $0.isGroupChat == true }
            api().getUserCommunities(currentUserId).onSuccess { [weak self] response in
                if let strongSelf = self {
                    strongSelf.populateMucConversations(storedMucConversations, communities: response.items, user: strongSelf.currentUserId)
                }
            }
        }

    }

    
    func saveConversations() {
        chatHistory?.storeConversations(Array(directConversations.union(mucConversations)))
    }
    
    private func populateMucConversations(stored: [Conversation], communities: [Community], user: CRUDObjectId) {
        if currentUserId != user {
            Log.warning?.message("Trying to populate conversations for invalid user")
            return
        }
        if chat().isAuthorized == false {
            Log.warning?.message("Trying to populate conversations for unathorized client")
            return
        }

        let currentList = communities.map { Conversation(community: $0) }
        let currentIds = currentList.map { $0.roomId }
        let validStored = stored.filter { currentIds.contains($0.roomId) }
        let validIds = validStored.map { $0.roomId }
        let hidden = currentList.filter { validIds.contains($0.roomId) == false }
        for c in hidden {
            c.visible = false
        }
        
        mucConversations = Set(validStored + hidden)
        
        let chatClient = chat()
        chatClient.cleanRooms()
        let host = AppConfiguration().xmppHostname
        let jid: (String) -> String = { user in
            return "\(user)@conference.\(host)"
        }

        for conversation in mucConversations {
            chatClient.joinRoom(jid(conversation.roomId), nickName: currentUserId, lastHistoryStamp: conversation.lastActivityDate)
        }


        sendConversationDidChangeNotification()
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
    private var currentUserId: CRUDObjectId = CRUDObjectInvalidId {
        didSet {
            chatHistory = ChatHistory(storageName: currentUserId)
        }
    }
    private var chatHistory: ChatHistory?
    
    
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
                    self?.directConversations.insert(conversation)
                    self?.sendConversationDidChangeNotification()
                }
            }
        }
    }
    
    func chatClient(client: XMPPClient, didUpdateGroupChat roomId: String) {
        if let conversation = (mucConversations.filter { $0.roomId == roomId }).first {
            conversation.visible = true
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
    
    func storeDirectMessage(message: XMPPTextMessage, outgoing: Bool) {
        let room = outgoing ? message.to : message.from
        chatHistory?.storeMessage(message, room: room)
    }
    
    func storeRoomMessage(message: XMPPTextMessage, room: CRUDObjectId) {
        chatHistory?.storeMessage(message, room: room)        
    }
}
