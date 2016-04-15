//
//  EplusMemberCardView.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 14/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

@IBDesignable
class EPlusMemberCardView: UIView {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var expirationDateTitleLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var cardIdLabel: UILabel!
    
    // MARK: init methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonSetup()
    }
    
    // MARK: setup view
    
    private func loadViewFromNib() -> UIView {
        let viewBundle = NSBundle(forClass: self.dynamicType)
        //  An exception will be thrown if the xib file with this class name not found,
        let view = viewBundle.loadNibNamed(String(self.dynamicType), owner: self, options: nil)[0]
        return view as! UIView
    }
    
    private func commonSetup() {
        let nibView = loadViewFromNib()
        nibView.frame = bounds
        // Adding nibView on the top of our view
        addSubViewOnEntireSize(nibView)
    }
    
    //MARK: Public
    
    func configureWith(profile profile : UserProfile, plan: EPlusMembershipPlan) {
        
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
