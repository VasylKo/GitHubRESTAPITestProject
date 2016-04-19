//
//  EPlusCorporatePlanOptionTableViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 18/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusCorporatePlanOptionTableViewCell: UITableViewCell {
    
    var planInfoString: String? {
        didSet {
            if let planInfoString = planInfoString {
                infoLabel.text = planInfoString
            }
        }
    }
    
    var priceString: String? {
        didSet {
            if let priceString = priceString {
                priceLabel.text = priceString
            }
        }
    }
    
    var peopleAmountString: String? {
        didSet {
            if let peopleAmountString = peopleAmountString {
                peopleAmountLabel.text = peopleAmountString
            }
        }
    }
    
    var attributedPeopleAmountString: NSAttributedString? {
        didSet {
            if let attributedPeopleAmountString = attributedPeopleAmountString {
                peopleAmountLabel.attributedText = attributedPeopleAmountString
            }
        }
    }
    
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var peopleAmountLabel: UILabel!
}
