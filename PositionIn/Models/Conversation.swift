//
//  Conversation.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 17/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

final class Conversation {

    let name: String
    let imageURL: NSURL?
    var lastActivityDate: NSDate
    var unreadCount: UInt = 1
    
    let roomId: String
    let isGroupChat: Bool
    
    convenience init(community: Community) {
        let name = community.name ?? NSLocalizedString("Unnamed community", comment: "Chat: community default")
        self.init(roomID: community.objectId, isMultiUser: true, caption: name, url: community.avatar)
    }
    
    convenience init(user: UserInfo) {
        let name = user.title ?? NSLocalizedString("Unnamed user", comment: "Chat: user default")
        self.init(roomID: user.objectId, isMultiUser: false, caption: name, url: user.avatar)
    }
    
    init(roomID: String, isMultiUser: Bool, caption: String, url: NSURL?) {
        roomId = roomID
        isGroupChat = isMultiUser
        name = caption
        imageURL = url
        
        lastActivityDate = NSDate()
        unreadCount = 0
        
    }
}

extension Conversation: Hashable {
    var hashValue: Int {
        return (roomId.hashValue << 8) + isGroupChat.hashValue
    }
}

func == (lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.roomId == rhs.roomId && lhs.isGroupChat == rhs.isGroupChat
}