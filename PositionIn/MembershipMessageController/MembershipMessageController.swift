//
//  MembershipMessageController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 23/03/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipMessageController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        becomeMemberButton.layer.cornerRadius = 3
        
        becomeMemberContainerView.layer.cornerRadius = 2
        
        becomeMemberContainerView.layer.masksToBounds = false
        becomeMemberContainerView.layer.shadowColor = UIColor.blackColor().CGColor
        becomeMemberContainerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        becomeMemberContainerView.layer.shadowOpacity = 0.1
    }
    
    @IBAction func becomeMemberTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var becomeMemberButton: UIButton!
    @IBOutlet private weak var becomeMemberContainerView: UIView!
    @IBOutlet private weak var bottomInfoLabel: UILabel!
    @IBOutlet private weak var topInfoLabel: UILabel!
    @IBOutlet private weak var makeDiffLabel: UILabel!
    @IBOutlet private weak var becomeMemberLabel: UILabel!
}
