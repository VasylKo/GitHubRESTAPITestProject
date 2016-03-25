//
//  CommunityInfoCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

final class CommunityInfoCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? BrowseCommunityInfoCellModel
        assert(m != nil, "Invalid model passed")
        
        let countFormat: String
        if (m!.type == .Volunteer) {
            countFormat = NSLocalizedString("%d Volunteers", comment: "Browse community: count members")
        } else {
            countFormat = NSLocalizedString("%d Members", comment: "Browse volunteering: count Volunteers")
        }
        
        countLabel.text = (m!.membersCount).map { String(format:countFormat, $0) }
        descriptionLabel.text = m!.text
        
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = UIEdgeInsetsZero
        self.separatorInset = UIEdgeInsetsZero
    }
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}
