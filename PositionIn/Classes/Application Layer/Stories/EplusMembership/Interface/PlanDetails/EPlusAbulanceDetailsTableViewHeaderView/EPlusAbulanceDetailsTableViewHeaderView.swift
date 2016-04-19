//
//  EPlusAbulanceDetailsTableViewHeaderView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 14/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusAbulanceDetailsTableViewHeaderView: UIView {

    var planImageViewString: String? {
        didSet {
            if let planImageViewString = planImageViewString {
                self.planImageView.image = UIImage(named: planImageViewString)
            }
        }
    }
    
    var planNameString: String? {
        didSet {
            if let planNameString = planNameString {
                self.planNameLabel.text = planNameString
            }
        }
    }
    
    var priceString: String? {
        didSet {
            if let priceString = priceString {
                self.priceLabel.text = priceString
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //To make labels shrink in size for table view heare
        //See: http://roadfiresoftware.com/2015/05/how-to-size-a-table-header-view-using-auto-layout-in-interface-builder/
        planNameLabel.preferredMaxLayoutWidth = planNameLabel.bounds.width
        priceLabel.preferredMaxLayoutWidth = priceLabel.bounds.width
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var planImageView: UIImageView!
    @IBOutlet weak var planNameLabel: UILabel!
}
