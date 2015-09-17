//
//  ConversationController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Messaging
import JSQMessagesViewController
import CleanroomLogger

final class ChatController {
    init(conversation: Conversation) {
        messages = [
            JSQMessage(senderId: "123", displayName: "John Doe", text: "Hi!"),
            JSQMessage(senderId: "123", displayName: "John Doe", text: "Please give me a call."),            
        ]
    }
    
    func sendMessage(msg: JSQMessageData) {
        messages.append(msg)
    }
    
    func messagesCount() -> Int {
        return count(messages)
    }
    
    func messageAtIndex(index: Int) -> JSQMessageData {
        return messages[index] ?? JSQMessage()
    }
    
    func avatarForSender(senderId: CRUDObjectId) -> JSQMessageAvatarImageDataSource {
        return  avatarsCache[senderId] ??  defaultAvatar
    }
    
    private var messages: [JSQMessageData] = []
    
    private var avatarsCache: [CRUDObjectId: JSQMessageAvatarImageDataSource] = [:]
    lazy private var defaultAvatar: JSQMessagesAvatarImage = {
        return JSQMessagesAvatarImageFactory.avatarImageWithPlaceholder(UIImage(named: "AvatarPlaceholder")!, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    }()
}

