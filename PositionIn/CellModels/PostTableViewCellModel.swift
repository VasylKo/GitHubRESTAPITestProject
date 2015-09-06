//
//  PostTableViewCellModel.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore

struct PostLikesCountModel: TableViewCellModel {
    let likes: Int
    let comments: Int
}

struct PostInfoModel: TableViewCellModel {
    let firstLine: String?
    let secondLine: String?
    let imageUrl: NSURL?
}