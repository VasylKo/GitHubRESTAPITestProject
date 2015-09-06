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
        let countFormat = NSLocalizedString("%d Members", comment: "Browse community: count members")
        countLabel.text = map(m!.membersCount) { String(format:countFormat, $0) }
        descriptionLabel.text = m!.text    
    }    
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}
