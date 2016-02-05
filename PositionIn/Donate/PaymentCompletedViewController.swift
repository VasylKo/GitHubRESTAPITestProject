//
//  PaymentCompletedViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 03/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class PaymentCompletedViewController: UIViewController {

    @IBOutlet private weak var projectImageView: UIImageView!
    @IBOutlet private weak var projectNameLabel: UILabel!

    var projectName: String?
    var projectIconURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.projectImageView.setImageFromURL(projectIconURL)
        self.projectNameLabel.text = projectName
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        sideBarController?.executeAction(SidebarViewController.defaultAction)
        dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}
