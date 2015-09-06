//
//  BrowseCommunityCellFactory.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore

struct BrowseCommunityCellFactory {
    func modelsForCommunity(community: Community, mode: BrowseCommunityViewController.BrowseMode) -> [TableViewCellModel] {
        var models: [TableViewCellModel] = []
        models.append(TableViewCellURLTextModel(title:community.name ?? "", url:community.avatar))
//        if let url = post.photos?.first?.url {
//            models.append(TableViewCellURLModel(url: url))
//        }
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
//        let date: String? = map(post.date) { dateFormatter.stringFromDate($0) }
//        models.append(PostInfoModel(firstLine: post.author?.title, secondLine: date, imageUrl: post.author?.avatar))
//        models.append(TableViewCellTextModel(title: post.name ?? ""))
        
        return models
    }
    
    func communityCellsReuseId() -> [String]  {
        return [CommunityInfoCell.reuseId(),CommunityActionCell.reuseId(), CommunityHeaderCell.reuseId()]
    }
    
    func cellReuseIdForModel(model: TableViewCellModel) -> String {
        
        if model is TableViewCellURLTextModel {
            return CommunityHeaderCell.reuseId()
        }
        
        return TableViewCell.reuseId()
    }
    

}
