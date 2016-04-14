//
//  EPlusPlanTitleTableViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 14/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusPlanTitleTableViewCell: UITableViewCell {
    
    var planTitleString: String? {
        didSet {
            if let planTitleString = planTitleString {
                self.planTitleLabel.text = planTitleString
            }
        }
    }
    
    @IBOutlet weak private var planTitleLabel: UILabel!
}
