//
//  MembershipBenefitCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

class MembershipBenefitCell: UITableViewCell {

    var benefitString: String? {
        didSet {
            self.benefitLabel.text = benefitString
        }
    }
    
    @IBOutlet weak var benefitLabel: UILabel!
}
