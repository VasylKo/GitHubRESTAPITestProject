//
//  EplusMemberCardView.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 14/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EplusMemberCardView: UIView {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var expirationDateTitleLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var cardIdLabel: UILabel!
    
    //MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let subview = NSBundle.mainBundle().loadNibNamed(String(EplusMemberCardView.self), owner: self, options: nil).first as? UIView {
            self.addSubViewOnEntireSize(subview)
        }
    }
    
    //MARK: Public
    
    func configureWith(profile profile : UserProfile, plan: EplusMembershipPlan) {
        
        let noValueLabel = "-"
        
        lastNameLabel.text = profile.lastName
        firstNameLabel.text = profile.firstName
        if let avatarURL = profile.avatar {
            profileImageView.setImageFromURL(avatarURL)
        }
        cardIdLabel.text = profile.eplusMembershipDetails?.membershipCardId ?? noValueLabel
        priceLabel.text = String("\(AppConfiguration().currencySymbol) \(plan.price ?? 0)")
        planNameLabel.text = plan.name ?? noValueLabel
        backgroundImageView.image = UIImage(named: profile.eplusMembershipDetails?.membershipCardImageName ?? "")
        if let endDate = profile.eplusMembershipDetails?.endDate {
            expirationDateLabel.text = stringFromDate(endDate)
        } else {
            expirationDateLabel.text = noValueLabel
        }
    }
    
    private func stringFromDate(date : NSDate?) -> String {
        if date != nil {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            return dateFormatter.stringFromDate(date!)
        } else {
            return String()
        }
    }

}
