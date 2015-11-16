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

class ChatHistory {
    typealias RoomType = CRUDObjectId
    
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
    
    func storeMessage(msg: XMPPTextMessage, room: RoomType) {
        let item = ChatMessageStorageObject(textMessage: msg, room: room)
        let realm = currentRealm
        try! realm.write {
            realm.add(item)
        }
    }
    
    func messagesForChat(room: RoomType) -> [XMPPTextMessage] {
        return itemsForRoom(room)
    }
    
    func messagesForRoom(room: RoomType) -> [XMPPTextMessage] {
        return itemsForRoom(room)
    }
    
    private func itemsForRoom(room: RoomType) -> [ XMPPTextMessage] {
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
    dynamic var room: ChatHistory.RoomType =  CRUDObjectInvalidId
    
    dynamic var from =  CRUDObjectInvalidId
    dynamic var to =  CRUDObjectInvalidId
    dynamic var text : String? = nil
    dynamic var date =  NSDate()
    
    override static func indexedProperties() -> [String] {
        return ["room", "date"]
    }
    
    func message() -> XMPPTextMessage {
        return XMPPTextMessage(text, from: from, to: to, date: date)
    }
    
    convenience init(textMessage: XMPPTextMessage, room: ChatHistory.RoomType) {
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
    dynamic var isGroupChat: Bool = false

    override static func primaryKey() -> String? {
        return "roomId"
    }
    
    override static func indexedProperties() -> [String] {
        return ["isGroupChat", "lastActivityDate"]
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
    
}
