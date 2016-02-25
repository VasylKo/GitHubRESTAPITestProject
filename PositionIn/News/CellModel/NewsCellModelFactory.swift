//
//  NewsCellModelFactory.swift
//  PositionIn
//
//  Created by ng on 2/17/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore
import CleanroomLogger

struct NewsCellModelFactory {
    
    func model(item: FeedItem, actionConsumer: NewsListActionConsumer?) -> [[TableViewCellModel]] {
        let model = NewsTableViewCellModel(item: item, actionConsumer: actionConsumer)
        return [[model]]
    }
    
    func cellsReuseId() -> [String] {
        return [NewsTableViewCell.reuseId()]
    }
    
    func cellReuseIdForModel(model: TableViewCellModel) -> String {
        return NewsTableViewCell.reuseId()
    }
    
}