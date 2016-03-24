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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        var size = self.scrollView.contentSize
//        size.height = self.contentView.frame.size.height
//        self.scrollView.contentSize = size
    }
//    
    @IBAction func becomeMemberTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var becomeMemberButton: UIButton!
    @IBOutlet weak var becomeMemberContainerView: UIView!
    @IBOutlet weak var bottomInfoLabel: UILabel!
    @IBOutlet weak var topInfoLabel: UILabel!
    @IBOutlet weak var makeDiffLabel: UILabel!
    @IBOutlet weak var becomeMemberLabel: UILabel!
}
