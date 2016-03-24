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
        
        dateLabel.text = m!.date
        newsTitleLabel.text = m!.title
        
        distanceIcon.hidden = true
        distanceLabel.hidden = true
        authorLabel.hidden = true
        
        if m!.isFeautered == true {
            bottomContainerHeightConstaint.constant = 0
            return
        }
        
        if let distance = m!.distance {
            distanceIcon.hidden = false
            distanceLabel.hidden = false
            distanceLabel.text = distance
        }
        else {
            
            if let author = m!.author {
                self.authorLabel.text = "By \(author)"
                self.authorLabel.hidden = false
            }
            
            distanceLabel.text = nil
            if (m!.date == nil && m!.author == nil) {
                bottomContainerHeightConstaint.constant = 0
            }
        }
        
        self.selectionStyle = .None
    }
    
    @IBOutlet weak var bottomContainerHeightConstaint: NSLayoutConstraint!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var distanceIcon: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var newsTitleLabel: UILabel!
}
