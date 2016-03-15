//
//  NewsItemTitleCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 14/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class NewsItemTitleCell: TableViewCell {
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? NewsDetailsTitleTableViewCellModel
        assert(m != nil, "Invalid model passed")
        
        if let date = m!.date {
            dateLabel.text = date
        }
        else {
            newsTitleLabel.text = nil
        }
        
        if let author = m!.author {
            authorLabel.text = "By \(author)"
        }
        else {
            newsTitleLabel.text = nil
        }
        
        if let newsTitle = m!.title {
            newsTitleLabel.text = newsTitle
        }
        else {
            newsTitleLabel.text = nil
        }
        
        self.selectionStyle = .None
    }
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var newsTitleLabel: UILabel!
}
