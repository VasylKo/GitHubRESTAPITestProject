//
//  PostCellModelFactory.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger

struct PostCellModelFactory {
    func modelsForPost(post: Post, actionConsumer: PostActionConsumer?) -> [[TableViewCellModel]] {
        var models: [[TableViewCellModel]] = []
        var firstSection: [TableViewCellModel] = []
        
        if let url = post.photos?.first?.url {
            firstSection.append(TableViewCellURLModel(url: url))
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let date: String? = post.date.map { dateFormatter.stringFromDate($0) }
        firstSection.append(PostInfoModel(firstLine: post.author?.title, secondLine: date, imageUrl: post.author?.avatar, userId: post.author?.objectId))
        firstSection.append(TableViewCellTextModel(title: post.name ?? ""))
        
        Log.verbose?.value(post.likes)
        Log.verbose?.value(post.comments)
        firstSection.append(PostLikesCountModel(likes: post.likes, comments: post.comments.count, actionConsumer: actionConsumer))
        models.append(firstSection)
        
        var secondSection: [TableViewCellModel] = []
        
        for comment: Comment in post.comments {
            let dateString = dateFormatter.stringFromDate(comment.date ?? NSDate())
            secondSection.append(PostCommentCellModel(userId: comment.author!.objectId, name: comment.author!.title, comment: comment.text, date:dateString, imageUrl: comment.author!.avatar))
        }
        
        models.append(secondSection)
        return models
    }
    
    func postCellsReuseId() -> [String]  {
        return [PostImageCell.reuseId(),PostBodyCell.reuseId(),PostInfoCell.reuseId(), PostLikeCommentCell.reuseId(),  CommentCell.reuseId()]
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
        if model is PostLikesCountModel {
            return PostLikeCommentCell.reuseId()
        }
        if model is PostCommentCellModel {
            return CommentCell.reuseId()
        }
        
        return TableViewCell.reuseId()
    }
}
