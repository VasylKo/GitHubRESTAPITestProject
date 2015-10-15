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
    }
    
    internal func getHistory(conversation: Conversation) -> [XMPPTextMessage] {
        if conversation.isGroupChat {
            return chat().messagesForRoom(conversation.roomId) as! [XMPPTextMessage]
        } else {
            return chat().messagesForChat(conversation.roomId)as! [XMPPTextMessage]
        }
    }
    
    internal func getSenderId(conversation: Conversation) -> String {
        if conversation.isGroupChat,
           let senderId = chat().senderIdForRoom(conversation.roomId) {
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
        nickName = ""
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
        let chatClient = chat()
        for conversation in conversations {
            chatClient.joinRoom(jid(conversation.roomId), nickName: nickName)
        }
    }
    
    class func sharedInstance() -> ConversationManager {
        struct Shared {
            static let instance = ConversationManager()
        }
        return Shared.instance
    }
    
    override init() {
        super.init()
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


extension ConversationManager: XMPPClientDelegate {
    func chatClient(client: XMPPClient, didUpdateDirectChat userId: String) {
        if let conversation = (Array(directConversations).filter { $0.roomId == userId }).first {
            conversation.lastActivityDate = NSDate()
        } else {
            api().getUsers([userId]).onSuccess { [weak self] response in
                if let info = response.items.first {
                    self?.directConversations.insert(Conversation(user: info))
                }
            }
        }
    }
    
    func chatClient(client: XMPPClient, didUpdateGroupChat roomId: String) {
        if let conversation = (Array(mucConversations).filter { $0.roomId == roomId }).first {
            conversation.lastActivityDate = NSDate()
        } else {
             Log.error?.message("Unknown group chat \(roomId)")
        }

    }
   
}