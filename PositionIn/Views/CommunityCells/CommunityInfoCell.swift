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
        switch m!.type {
        case .Volunteer:
            countFormat = NSLocalizedString("%d Volunteers", comment: "Browse community: count members")
        default:
            countFormat = NSLocalizedString("%d Members", comment: "Browse volunteering: count Volunteers")
        }
        
        if m!.isClosed {
            communityTypeLabel.text = NSLocalizedString("Closed")
            communityTypeIcon.image = UIImage(named: "closed_comm")
        }
        else {
            communityTypeLabel.text = NSLocalizedString("Public")
            communityTypeIcon.image = UIImage(named: "public_comm")
        }
        
        countLabel.text = (m!.membersCount).map { String(format:countFormat, $0) }
        descriptionLabel.text = m!.text
        
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = UIEdgeInsetsZero
        self.separatorInset = UIEdgeInsetsZero
    }
    
    @IBOutlet weak var communityTypeIcon: UIImageView!
    @IBOutlet weak var communityTypeLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}
