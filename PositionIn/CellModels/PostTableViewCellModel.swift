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
    let isLiked: Bool
    let comments: Int
    let actionConsumer: NewsActionConsumer?
}

struct PostAttachmentsModel: TableViewCellModel {
    let attachments: [Attachment]?
    let links: [NSURL]?
}

struct PostInfoModel: TableViewCellModel {
    let firstLine: String?
    let secondLine: String?
    let imageUrl: NSURL?
    let userId: CRUDObjectId?
}

struct PostCommentCellModel: TableViewCellModel {
    let userId: CRUDObjectId
    let name: String?
    let comment: String?
    let date: String?
    let imageUrl: NSURL?
}