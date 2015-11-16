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
        return []
    }
    
    func storeConversations(conversations: [Conversation]) {
        
    }
    
    func storeMessage(msg: XMPPTextMessage, room: RoomType) {
        let item = ChatHistoryItem(textMessage: msg, room: room)
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
        return currentRealm.objects(ChatHistoryItem).filter("room == %@", room).sorted("date", ascending: true).map { $0.message() }
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

class ChatHistoryItem: Object {
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

