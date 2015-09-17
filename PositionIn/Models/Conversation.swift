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
        self.init(interlocutors: [userId])
    }
    
    init(interlocutors: [CRUDObjectId]) {
        recipients = interlocutors
    }
    
    
    private(set) var recipients: [CRUDObjectId]
}