//
//  EPlusPlanInfoTableViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 14/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusPlanInfoTableViewCell: UITableViewCell {

    var planInfoString: String? {
        didSet {
            if let planInfoString = planInfoString {
                self.infoLabel.text = planInfoString
            }
        }
    }
    
    var showBullet: Bool = true {
        didSet {
            bulletView.hidden = !showBullet
            labelLeftMarginConstraint.constant = showBullet ? 28 : 12
            self.setNeedsUpdateConstraints()
        }
    }
    
    @IBOutlet weak var labelLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var bulletView: UIView!
    @IBOutlet private weak var infoLabel: UILabel!
    
}
