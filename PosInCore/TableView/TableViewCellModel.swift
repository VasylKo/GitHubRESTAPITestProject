//
//  TableViewCellModel.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 19/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

public protocol TableViewCellModel {
    
}

public struct  TableViewCellInvalidModel: TableViewCellModel {
    public init() {
    }
}

public struct TableViewCellTextModel: TableViewCellModel {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

public struct TableViewCellAttendEventModel: TableViewCellModel {
    public let attendEvent: Bool
    public let title: String
    
    public init(title: String, attendEvent: Bool) {
        self.title = title
        self.attendEvent = attendEvent
    }
}

public struct TableViewCellImageTextModel: TableViewCellModel {
    public let title: String
    public let image: String
    
    public init(title: String, imageName: String) {
        self.title = title
        image = imageName
    }
}

public struct TableViewCellURLTextModel: TableViewCellModel {
    public let title: String
    public let url: NSURL?
    
    public init(title: String, url: NSURL?) {
        self.title = title
        self.url = url
    }
}

public struct TableViewCellURLModel: TableViewCellModel {
    public let url: NSURL?
    public let height: integer_t
    
    public init(url: NSURL?, height: integer_t = 100) {
        self.url = url
        self.height = height
    }
}
