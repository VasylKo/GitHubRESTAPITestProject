//
//  ChatHistory.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import Foundation
import Messaging
import RealmSwift

typealias ChatRoomType = CRUDObjectId

protocol ChatHistory {
    func loadConversations() -> [Conversation]
    func storeConversations(conversations: [Conversation])
    func storeMessage(msg: XMPPTextMessage, room: ChatRoomType)
    func messagesForChat(room: ChatRoomType) -> [XMPPTextMessage]
    func messagesForRoom(room: ChatRoomType) -> [XMPPTextMessage]
}

class RealmChatHistory: ChatHistory {
    
    init(storageName realmName: String) {
        currentRealm = realmWithName(realmName)
    }
    
    func loadConversations() -> [Conversation] {
        return currentRealm.objects(ChatConversationStorageObject).map { Conversation(storage: $0) }
    }
    
    func storeConversations(conversations: [Conversation]) {
        let storedObjects = conversations.filter { $0.visible == true }.map { ChatConversationStorageObject(source: $0) }
        let realm = currentRealm
        try! realm.write {
            realm.add(storedObjects, update: true)
        }
    }
    
    func storeMessage(msg: XMPPTextMessage, room: ChatRoomType) {
        let item = ChatMessageStorageObject(textMessage: msg, room: room)
        let realm = currentRealm
        try! realm.write {
            realm.add(item)
        }
    }
    
    func messagesForChat(room: ChatRoomType) -> [XMPPTextMessage] {
        return itemsForRoom(room)
    }
    
    func messagesForRoom(room: ChatRoomType) -> [XMPPTextMessage] {
        return itemsForRoom(room)
    }
    
    private func itemsForRoom(room: ChatRoomType) -> [XMPPTextMessage] {
        return currentRealm.objects(ChatMessageStorageObject).filter("room == %@", room).sorted("date", ascending: true).map { $0.message() }
    }
    
    
    private var currentRealm: Realm!
    
    
    private func realmWithName(realmName: String) -> Realm {
        var config = Realm.Configuration()
        if realmName != CRUDObjectInvalidId {
            // Use the default directory, but replace the filename with the name
            config.path = NSURL.fileURLWithPath(config.path!)
                .URLByDeletingLastPathComponent?
                .URLByAppendingPathComponent("\(realmName).realm")
                .path
        }
        return try! Realm(configuration: config)
    }
    
}

class ChatMessageStorageObject: Object {
    dynamic var room: ChatRoomType =  CRUDObjectInvalidId
    
    dynamic var from =  CRUDObjectInvalidId
    dynamic var to =  CRUDObjectInvalidId
    dynamic var text : String? = nil
    dynamic var date =  NSDate()
    
    override static func indexedProperties() -> [String] {
        return ["room"]
    }
    
    func message() -> XMPPTextMessage {
        return XMPPTextMessage(text, from: from, to: to, date: date)
    }
    
    convenience init(textMessage: XMPPTextMessage, room: ChatRoomType) {
        self.init()
        self.room = room
        from = textMessage.from
        to = textMessage.to
        text = textMessage.text
        date = textMessage.date
        
    }
}


class ChatConversationStorageObject: Object {
    dynamic var name: String = ""
    dynamic var imageURL: String?
    dynamic var lastActivityDate: NSDate = NSDate()
    dynamic var unreadCount: Int64 = 0
    dynamic var roomId: String = CRUDObjectInvalidId
    
    var isGroupChat: Bool  {
        get {
            return _isGroupChat == 1
        }
        set {
            _isGroupChat = newValue ? 1 : 0
        }
    }
    
    dynamic var _isGroupChat: Int = 0

    override static func primaryKey() -> String? {
        return "roomId"
    }
    
    override static func indexedProperties() -> [String] {
        return ["_isGroupChat"]
    }
    
    convenience required init(source: Conversation) {
        self.init()
        self.roomId = source.roomId
        self.isGroupChat = source.isGroupChat
        self.name = source.name
        self.imageURL = source.imageURL?.absoluteString
        self.lastActivityDate = source.lastActivityDate
        self.unreadCount = Int64(source.unreadCount)
    }
    
    override static func ignoredProperties() -> [String] {
        return ["isGroupChat"]
    }
    
}
