//
//  FeedItemNewsCellModelFactory.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 15/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore
import CleanroomLogger

struct FeedItemNewsCellModelFactory {
    
    func modelsForPost(post: Post, actionConsumer: NewsActionConsumer?) -> [[TableViewCellModel]] {
        var models: [[TableViewCellModel]] = []
        var firstSection: [TableViewCellModel] = []
        
        firstSection.append(TableViewCellURLModel(url: post.photoURL, height: 180, placeholderString: "news_placeholder"))
        
        let date: String? = post.date?.formattedAsFeedTime()
        firstSection.append(NewsDetailsTitleTableViewCellModel(title: post.name, distance: nil,author: post.author?.title, date: date))
        
        if let text = post.descriptionString {
            firstSection.append(TableViewCellTextModel(title: text))
        }


        firstSection.append(PostLikesCountModel(likes: post.likes, isLiked:post.isLiked, comments: post.comments.count, actionConsumer: actionConsumer))
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
        return [PostImageCell.reuseId(), PostBodyCell.reuseId(), PostInfoCell.reuseId(), PostLikeCommentCell.reuseId(), CommentCell.reuseId(), PostAttachmentsCell.reuseId(), NewsItemTitleCell.reuseId()]
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
        if model is NewsDetailsTitleTableViewCellModel {
            return NewsItemTitleCell.reuseId()
        }
        return TableViewCell.reuseId()
    }
}