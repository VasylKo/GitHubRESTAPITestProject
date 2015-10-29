//
//  Conversation.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 17/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore

final class Conversation {

    let name: String
    let imageURL: NSURL?
    var lastActivityDate: NSDate
    var unreadCount: UInt  {
        var result: UInt = 0
        synced(self) {
            result = self._unreadCount
        }
        return result
    }
    
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
        _unreadCount = 0
    }
    
    func resetUnreadCount() {
        synced(self) {
            self._unreadCount = 0
        }
    }
    
    func didChange() {
        synced(self) {
            self._unreadCount += 1
        }
        lastActivityDate = NSDate()
    }
    
    private var _unreadCount: UInt  = 0
}

extension Conversation: Hashable {
    var hashValue: Int {
        return (roomId.hashValue << 8) + isGroupChat.hashValue
    }
}

func == (lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.roomId == rhs.roomId && lhs.isGroupChat == rhs.isGroupChat
}

extension Conversation: NSCoding {
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: CodingKeys.name)
        map(imageURL) { aCoder.encodeObject($0, forKey: CodingKeys.image) }
        aCoder.encodeObject(lastActivityDate, forKey: CodingKeys.date)
        aCoder.encodeObject(roomId, forKey: CodingKeys.roomId)
        aCoder.encodeBool(isGroupChat, forKey: CodingKeys.isGroup)
        aCoder.encodeInteger(Int(unreadCount), forKey: CodingKeys.unread)
    }
    
    @objc convenience init(coder aDecoder: NSCoder) {
        let image = aDecoder.decodeObjectForKey(CodingKeys.image) as? NSURL
        let caption = aDecoder.decodeObjectForKey(CodingKeys.name) as? String ?? NSLocalizedString("Unnamed", comment: "Chat: Unknown conversation")
        let isGroupChat = aDecoder.decodeBoolForKey(CodingKeys.isGroup)
        let roomId = aDecoder.decodeObjectForKey(CodingKeys.roomId) as? CRUDObjectId ?? CRUDObjectInvalidId
        let date  = aDecoder.decodeObjectForKey(CodingKeys.date) as? NSDate
        let unread = UInt(aDecoder.decodeIntegerForKey(CodingKeys.unread))
        
        self.init(roomID: roomId, isMultiUser: isGroupChat, caption: caption, url: image)
        map(date) { lastActivityDate = $0 }
        _unreadCount = unread
    }
    
    private struct CodingKeys {
        static let name = "name"
        static let image = "image"
        static let date = "date"
        static let isGroup = "isGroup"
        static let roomId = "roomId"
        static let unread = "unread"
    }

}