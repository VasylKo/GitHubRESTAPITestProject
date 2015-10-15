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

final class ConversationManager {
    
    internal func sendText(text: String, conversation: Conversation) {
        chat().sendTextMessage(text, to: conversation.roomId, groupChat: conversation.isGroupChat)
    }
    
    internal func didEnterConversation(conversation: Conversation) {
        if conversation.isGroupChat == false {
            directConversations.insert(conversation)
        } else if mucConversations.contains(conversation) == false {
            fatalError("Unknown group chat")
        }
    }
    
    internal func getHistory(conversation: Conversation) -> [XMPPTextMessage] {
        if conversation.isGroupChat {
            return chat().history.messagesForRoom(conversation.roomId) as! [XMPPTextMessage]
        } else {
            return chat().history.messagesForChat(conversation.roomId)as! [XMPPTextMessage]
        }
    }
    
    internal func getSenderId(conversation: Conversation) -> String {
        if conversation.isGroupChat,
           let senderId = chat().history.senderIdForRoom(conversation.roomId) {
            return senderId
        }
        return currentUserId
    }
    
    internal func conversations() ->  [Conversation] {
        return Array(directConversations.union(mucConversations)).sorted {
            return $0.lastActivityDate.compare($1.lastActivityDate) == NSComparisonResult.OrderedDescending
        }
    }
    
    internal func refresh() {
        refreshDirectConversations()
        refreshMucConversations()
    }
    
    internal func flush() {
        currentUserId = CRUDObjectInvalidId
        directConversations = []
        mucConversations = []
        nickName = ""
    }
    
    internal func groupConversation(roomId: String) -> Conversation? {
        return Array(mucConversations).filter { $0.roomId == roomId }.first
    }
    
    internal func directConversation(roomId: String) -> Conversation? {
        return Array(directConversations).filter { $0.roomId == roomId }.first
    }
    
    private func loadConversations(userId: CRUDObjectId, nickName: String) {
        self.nickName =  nickName
        currentUserId = userId
        refresh()
    }
    
    private func refreshDirectConversations() {
    }
    
    private func refreshMucConversations() {
        api().getUserCommunities(currentUserId).onSuccess { [weak self] response in
            self?.populateMucConversations(response.items.map { Conversation(community: $0) })
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
        let history = chat().history
        for conversation in conversations {
            history.joinRoom(jid(conversation.roomId), nickName: nickName)
        }
    }
    
    class func sharedInstance() -> ConversationManager {
        struct Shared {
            static let instance = ConversationManager()
        }
        return Shared.instance
    }
    
    init() {
        let userChangeBlock: NSNotification! -> Void = { [weak self] notification in
            
            dispatch_async(dispatch_get_main_queue()) {
                if let manager = self {
                    manager.flush()
                    map(notification.object as? UserProfile) {
                        manager.loadConversations($0.objectId, nickName: $0.displayName)
                    }
                }
            }
        }
        userDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserProfile.CurrentUserDidChangeNotification,
            object: nil,
            queue: nil,
            usingBlock: userChangeBlock)
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(userDidChangeObserver)
    }
    
    private var nickName: String = ""
    private var directConversations = Set<Conversation>()
    private var mucConversations = Set<Conversation>()
    private var currentUserId: CRUDObjectId = CRUDObjectInvalidId
    private var userDidChangeObserver: NSObjectProtocol!
}