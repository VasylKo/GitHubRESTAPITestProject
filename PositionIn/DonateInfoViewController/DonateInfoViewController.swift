//
//  DonateInfoViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 24/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class DonateInfoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        donateButton.layer.cornerRadius = 3
        
        donateInfoContainerView.layer.cornerRadius = 2
        donateInfoContainerView.layer.masksToBounds = false
        donateInfoContainerView.layer.shadowColor = UIColor.blackColor().CGColor
        donateInfoContainerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        donateInfoContainerView.layer.shadowOpacity = 0.1
        
        if let donateToString = donateToString {
            self.donateToLabel.text = donateToString
        }
        else {
            let appFullTitle = AppConfiguration().appFullTitle
            self.donateToLabel.text = NSLocalizedString(appFullTitle)
        }
        
    }
    
    @IBAction func donateTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var donateToString: String?
    
    @IBOutlet private weak var donateToLabel: UILabel!
    @IBOutlet private weak var donateButton: UIButton!
    @IBOutlet private weak var donateInfoContainerView: UIView!
}
