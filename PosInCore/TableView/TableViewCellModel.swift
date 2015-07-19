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

public struct TableViewCellTextModel: TableViewCellModel {
    public let title: String
    
    public init(title: String) {
        self.title = title
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
