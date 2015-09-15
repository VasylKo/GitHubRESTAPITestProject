//
//  MessageListCellModel.swift
//  PositionIn
//
//  Created by Alex Goncharov on 9/15/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore

final class MessageTableViewCellModel: TableViewCellModel {
    let title: String?
    let info: String?
    let date: String?
    let imageUrl: NSURL?
    let state: MessageCellState = MessageCellState.Unread
    
    init(title: String, info: String?, imageURL: NSURL?, date: String) {
        self.title = title
        self.info = info
        self.date = date
        self.imageUrl = imageURL
    }
}

enum MessageCellState: Int {
    case Read = 0, Unread
}