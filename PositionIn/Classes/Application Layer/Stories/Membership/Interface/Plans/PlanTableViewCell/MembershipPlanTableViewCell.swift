//
//  MembershipPlanTableViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipPlanTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var membershipImageView: UIImageView!
    
    func configure(with plan : MembershipPlan) {
        self.titleLabel.text = plan.name
        self.membershipImageView.image = UIImage(named : plan.membershipImageName)
        
        if let lifetime = plan.lifetime where lifetime {
            self.descriptionLabel.text = String("\(AppConfiguration().currencySymbol) \(plan.price ?? 0)")
        } else {
            self.descriptionLabel.text = String("\(AppConfiguration().currencySymbol) \(plan.price ?? 0) Annually")
        }
    }
    
    func configureAsGuest () {
        self.titleLabel.text = "Continue as guest"
        self.descriptionLabel.text = "Free"
        self.membershipImageView.image = UIImage(named : "dont_rename_ic_guest")
    }
        
}
