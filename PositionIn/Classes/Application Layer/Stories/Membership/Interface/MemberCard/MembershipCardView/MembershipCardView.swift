//
//  MembershipCardView.swift
//  PositionIn
//
//  Created by ng on 2/2/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

class MembershipCardView : UIView {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var cardIdLabel: UILabel!
    
    //MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let subview = NSBundle.mainBundle().loadNibNamed(String(MembershipCardView.self), owner: self, options: nil).first as? UIView {
            self.addSubViewOnEntireSize(subview)
        }
    }
    
    //MARK: Public
    
    func configure(with profile : UserProfile, plan : MembershipPlan) {
        self.lastNameLabel.text = profile.lastName
        self.firstNameLabel.text = profile.firstName
        if let avatarURL = profile.avatar {
            self.profileImageView.setImageFromURL(avatarURL)
        }
        self.cardIdLabel.text = profile.membershipDetails?.membershipCardId
        self.priceLabel.text = String("\(AppConfiguration().currencySymbol) \(plan.price ?? 0)")
        self.planNameLabel.text = plan.name
        self.expirationDateLabel.text = self.stringFromDate(profile.membershipDetails?.endDate)
        self.backgroundImageView.image = UIImage(named: profile.membershipDetails?.membershipCardImageName ?? "")
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