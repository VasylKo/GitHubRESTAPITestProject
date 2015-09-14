//
//  PostCellModelFactory.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore


struct PostCellModelFactory {
    func modelsForPost(post: Post) -> [TableViewCellModel] {
        var models: [TableViewCellModel] = []
        if let url = post.photos?.first?.url {
            models.append(TableViewCellURLModel(url: url))
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let date: String? = map(post.date) { dateFormatter.stringFromDate($0) }
        models.append(PostInfoModel(firstLine: post.author?.title, secondLine: date, imageUrl: post.author?.avatar, userId: post.author?.objectId))
        models.append(TableViewCellTextModel(title: post.name ?? ""))
        
        return models
    }
    
    func postCellsReuseId() -> [String]  {
        return [PostImageCell.reuseId(),PostBodyCell.reuseId(),PostInfoCell.reuseId()]
    }
    
    func cellReuseIdForModel(model: TableViewCellModel) -> String {
        if model is TableViewCellURLModel {
            return PostImageCell.reuseId()
        }
        if model is PostInfoModel {
            return PostInfoCell.reuseId()
        }
        if model is TableViewCellTextModel {
            return PostBodyCell.reuseId()
        }

        return TableViewCell.reuseId()
    }

    
    
}
