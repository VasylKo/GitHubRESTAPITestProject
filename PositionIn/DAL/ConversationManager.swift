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


final class ConversationManager {
    
    internal func all() ->  [Conversation] {
        return (directConversations + mucConversations).sorted {
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
    }
    
    internal func groupConversation(roomId: String) -> Conversation? {
        return mucConversations.filter { $0.roomId == roomId }.first
    }
    
    internal func directConversation(roomId: String) -> Conversation? {
        return directConversations.filter { $0.roomId == roomId }.first
    }
    
    private func loadConversations(userId: CRUDObjectId, nickName: String) {
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
        mucConversations = conversations
        let chatClient = chat()
        for conversation in conversations {
            
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
    
    private var directConversations: [Conversation] = []
    private var mucConversations: [Conversation] = []
    private var currentUserId: CRUDObjectId = CRUDObjectInvalidId
    private var userDidChangeObserver: NSObjectProtocol!
}