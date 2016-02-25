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
        
        if let urlString = post.photoURL {
            firstSection.append(TableViewCellURLModel(url: urlString))
        }

        let date: String? = post.date?.formattedAsTimeAgo()
        firstSection.append(PostInfoModel(firstLine: post.author?.title, secondLine: date, imageUrl: post.author?.avatar, userId: post.author?.objectId))
        firstSection.append(TableViewCellTextModel(title: post.name ?? ""))
        
        
        if post.links?.isEmpty == false || post.attachments?.isEmpty == false {
            firstSection.append(PostAttachmentsModel(attachments: post.attachments, links: post.links))
        }
        
        firstSection.append(PostLikesCountModel(likes: post.likes, comments: post.comments.count, actionConsumer: actionConsumer))
        models.append(firstSection)
        
        var secondSection: [TableViewCellModel] = []
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        for comment: Comment in post.comments {
            let dateString = dateFormatter.stringFromDate(comment.date ?? NSDate())
            secondSection.append(PostCommentCellModel(userId: comment.author!.objectId, name: comment.author!.title, comment: comment.text, date:dateString, imageUrl: comment.author!.avatar))
        }
        
        models.append(secondSection)
        return models
    }
    
    func postCellsReuseId() -> [String] {
        return [PostImageCell.reuseId(), PostBodyCell.reuseId(), PostInfoCell.reuseId(), PostLikeCommentCell.reuseId(), CommentCell.reuseId(), PostAttachmentsCell.reuseId()]
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
        if model is PostAttachmentsModel {
            return PostAttachmentsCell.reuseId()
        }
        
        return TableViewCell.reuseId()
    }
}
