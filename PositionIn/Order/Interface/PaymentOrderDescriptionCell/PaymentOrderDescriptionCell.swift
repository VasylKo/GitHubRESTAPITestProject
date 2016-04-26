//
//  PaymentOrderDescriptionCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 26/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class PaymentOrderDescriptionCell: UITableViewCell {

    internal var pickUpAvailability: String? {
        didSet {
            if let _ = pickUpAvailability {
                pickUpAvailabilityLabel?.text = pickUpAvailability
            } else {
               pickUpAvaiabililityCellHeightConstraint?.constant = 0.0
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var itemNameLabel: UILabel?
    @IBOutlet weak var pickUpAvailabilityLabel: UILabel?
    @IBOutlet weak var quintityLabel: UILabel?
    @IBOutlet weak var totalLabel: UILabel?
    @IBOutlet weak var pickUpAvaiabililityCellHeightConstraint: NSLayoutConstraint?
    
}
