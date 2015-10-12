//
//  MessageListCellModel.swift
//  PositionIn
//
//  Created by Alex Goncharov on 9/15/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore

final class ChatHistoryCellModel: TableViewCellModel {
    //TODO: use conversation instead of userId
    let userId: CRUDObjectId
    let name: String?
    let message: String?
    let date: String?
    let imageUrl: NSURL?
    let isGoupChat: Bool
    
    init(user: CRUDObjectId, name: String?, message: String?, imageURL: NSURL?, date: String?, muc: Bool = false) {
        userId = user
        self.name = name
        self.message = message
        self.date = date
        self.imageUrl = imageURL
        isGoupChat = muc
    }
}

