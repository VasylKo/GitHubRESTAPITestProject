//
//  MembershipPlanDetailsBenefitTableViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

class MembershipPlanDetailsBenefitTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var benefitLabel: UILabel!
    
    func configure(with benefits : String) {
        self.benefitLabel.text = benefits
    }
}
