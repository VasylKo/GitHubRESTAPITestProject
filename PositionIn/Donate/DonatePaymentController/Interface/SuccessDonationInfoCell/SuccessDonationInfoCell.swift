//
//  SuccessDonationInfoCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 25/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class SuccessDonationInfoCell: UITableViewCell {

    @IBOutlet weak var donateMessageLabel: UILabel?
    
    var amountString: String? {
        didSet {
            donateMessageLabel?.text = donateMessageLabel?.text?.stringByReplacingOccurrencesOfString("{amount}", withString: amountString ?? "", options: .LiteralSearch, range: nil)
        }
    }
    
    static let cellHeight = CGFloat(500.0)
}
