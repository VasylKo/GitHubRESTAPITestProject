//
//  Conversation.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 17/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

final class Conversation {
    
    convenience init(userId: CRUDObjectId) {
        self.init(room: userId, interlocutors: [userId])
    }
    
    init(room: CRUDObjectId, interlocutors: [CRUDObjectId]) {
        roomId = room
        recipients = interlocutors
    }
    
    let currentUserId: CRUDObjectId = api().currentUserId() ?? CRUDObjectInvalidId
    let roomId: CRUDObjectId
    var participants: [CRUDObjectId] {
        return recipients + [currentUserId]
    }
    
    private var recipients: [CRUDObjectId]
}