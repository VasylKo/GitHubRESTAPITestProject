//
//  EPlusPlanTableViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 13/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusPlanTableViewCell: UITableViewCell {
    
    var planImageViewString: String? {
        didSet {
            if let planImageViewString = planImageViewString {
                self.planImageView.image = UIImage(named: planImageViewString)
            }
        }
    }
    
    var infoLabelString: String? {
        didSet {
            if let infoLabelString = infoLabelString {
                self.infoLabel.text = infoLabelString
            }
        }
    }
    
    var titleLabelString: String? {
        didSet {
            if let titleLabelString = titleLabelString {
                self.titleLabel.text = titleLabelString
            }
        }
    }
    
    @IBOutlet private weak var planImageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
}
