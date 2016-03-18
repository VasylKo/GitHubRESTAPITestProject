//
//  FeedEmergencyCellModel.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 16/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation


import Foundation
import PosInCore
import CleanroomLogger

struct FeedEmergencyCellModel {
    
    func modelsForEmergency(emergency: Product, actionConsumer: NewsActionConsumer?) -> [[TableViewCellModel]] {
        var models: [[TableViewCellModel]] = []
        var firstSection: [TableViewCellModel] = []
        
        firstSection.append(TableViewCellURLModel(url: emergency.imageURL, height: 180, placeholderString: "PromotionDetailsPlaceholder"))
        
        //TODO: uncomment when BE fix
        let date: String? = emergency.date?.formattedAsTimeAgo()
        firstSection.append(NewsDetailsTitleTableViewCellModel(title: emergency.name, distance: emergency.distanceString, author: nil, date: date))
        
        if let text = emergency.text {
            firstSection.append(TableViewCellTextModel(title: text))
        }
        
        firstSection.append(TableViewCellImageTextModel(title: "Donate", imageName: "home_donate"))
        
        models.append(firstSection)
        
        var secondSection: [TableViewCellModel] = []
        
        if emergency.author?.objectId != api().currentUserId() {
            secondSection.append(TableViewCellImageTextModel(title: "Send Message", imageName: "productSendMessage"))
            secondSection.append(TableViewCellImageTextModel(title: "Member Profile", imageName: "productSellerProfile"))
        }
        if emergency.links?.isEmpty == false || emergency.attachments?.isEmpty == false {
            secondSection.append(TableViewCellImageTextModel(title: "More Information", imageName: "productTerms&Info"))
        }
        
        if secondSection.count > 0 {
            models.append(secondSection)
        }
        return models
    }
    
    func emergencyCellsReuseId() -> [String] {
        return [PostImageCell.reuseId(), PostBodyCell.reuseId(), PostInfoCell.reuseId(), PostAttachmentsCell.reuseId(), NewsItemTitleCell.reuseId(), ActionCell.reuseId()]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        if model is NewsDetailsTitleTableViewCellModel {
            return NewsItemTitleCell.reuseId()
        }
        if model is TableViewCellImageTextModel {
            return ActionCell.reuseId()
        }
        if model is PostAttachmentsModel {
            return PostAttachmentsCell.reuseId()
        }
        return TableViewCell.reuseId()
    }
}