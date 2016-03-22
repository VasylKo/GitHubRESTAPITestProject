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
    
    func modelsForPost(post: Post, isFeautered: Bool, actionConsumer: NewsActionConsumer?) -> [[TableViewCellModel]] {
        var models: [[TableViewCellModel]] = []
        var firstSection: [TableViewCellModel] = []
        
        firstSection.append(TableViewCellURLModel(url: post.photoURL, height: 180, placeholderString: "news_placeholder"))
        
        let dateString = post.date?.formattedAsFeedTime()
        
        firstSection.append(NewsDetailsTitleTableViewCellModel(title: post.name, isFeautered: isFeautered, distance: nil,author: post.author?.title, date: dateString))
        
        if let text = post.descriptionString {
            firstSection.append(TableViewCellTextModel(title: text))
        }

        if post.links?.isEmpty == false || post.attachments?.isEmpty == false {
            firstSection.append(TableViewCellImageTextModel(title: "More Information", imageName: "productTerms&Info"))
        }

        firstSection.append(PostLikesCountModel(likes: post.likes, isLiked:post.isLiked, isCommented: false, comments: post.comments.count, actionConsumer: actionConsumer))
        models.append(firstSection)
        
        var secondSection: [TableViewCellModel] = []

        for comment: Comment in post.comments {
            let dateString = comment.date?.formattedAsCommentTime()
            secondSection.append(PostCommentCellModel(userId: comment.author!.objectId, name: comment.author!.title, comment: comment.text, date:dateString, imageUrl: comment.author!.avatar))
        }
        
        models.append(secondSection)
        return models
    }
    
    func postCellsReuseId() -> [String] {
        return [PostImageCell.reuseId(), PostBodyCell.reuseId(), PostInfoCell.reuseId(), PostLikeCommentCell.reuseId(), CommentCell.reuseId(), PostAttachmentsCell.reuseId(), NewsItemTitleCell.reuseId(), ActionCell.reuseId()
]
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
        if model is TableViewCellImageTextModel {
            return ActionCell.reuseId()
        }
        if model is NewsDetailsTitleTableViewCellModel {
            return NewsItemTitleCell.reuseId()
        }
        return TableViewCell.reuseId()
    }
}