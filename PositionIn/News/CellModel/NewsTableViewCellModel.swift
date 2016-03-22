//
//  NewsTableViewCellModel.swift
//  PositionIn
//
//  Created by ng on 2/17/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore

struct NewsTableViewCellModel: TableViewCellModel {
    let item : FeedItem
    weak var actionConsumer: NewsListActionConsumer?
}

struct NewsDetailsTitleTableViewCellModel: TableViewCellModel {
    let title: String?
    let isFeautered: Bool?
    let distance: String?
    let author: String?
    let date: String?
}