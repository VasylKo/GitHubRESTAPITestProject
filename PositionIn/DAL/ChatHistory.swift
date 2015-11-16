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
        setDefaultRealmWithName(realmName)
    }
    
    func storeDirectMessage(msg: XMPPTextMessage, room: RoomType) {
        let item = ChatHistoryItem()
        item.room = room
        item.from = msg.from
        item.to = msg.to
        item.text = msg.text
        item.date = msg.date
        insertItem(item)
    }
    
    func messagesForChat(room: RoomType) -> [XMPPTextMessage] {
        return itemsForRoom(room)
    }
    
    func messagesForRoom(room: RoomType) -> [XMPPTextMessage] {
        return itemsForRoom(room)
    }
    
    
    private func itemsForRoom(room: RoomType) -> [ XMPPTextMessage] {
        let realm = try! Realm()
        return realm.objects(ChatHistoryItem).filter("room == %@", room).sorted("date", ascending: true).map { $0.message() }
    }
    
    private func insertItem(item: ChatHistoryItem) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(item)
        }
    }
    
    private func setDefaultRealmWithName(realmName: String) {
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.path = NSURL.fileURLWithPath(config.path!)
            .URLByDeletingLastPathComponent?
            .URLByAppendingPathComponent("\(realmName).realm")
            .path
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    
    private class ChatHistoryItem: Object {
        dynamic var room: RoomType =  CRUDObjectInvalidId
        
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
    }
    
}


