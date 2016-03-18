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
        
        if let distance = m!.distance {
            distanceIcon.hidden = false
            distanceLabel.hidden = false
            distanceLabel.text = distance
        }
        else {
            distanceLabel.text = nil
            if (m!.date == nil) {
                bottomContainerHeightConstaint.constant = 0
            }
        }
        
        self.selectionStyle = .None
    }
    
    @IBOutlet weak var bottomContainerHeightConstaint: NSLayoutConstraint!
    @IBOutlet weak var distanceIcon: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var newsTitleLabel: UILabel!
}
