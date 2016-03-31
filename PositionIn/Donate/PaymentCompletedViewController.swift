//
//  PaymentCompletedViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 03/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class PaymentCompletedViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var projectImageView: UIImageView?
    @IBOutlet weak var projectNameLabel: UILabel?
    @IBOutlet weak var totalLabel: UILabel?
    @IBOutlet weak var donateMessageLabel: UILabel?
    
    // MARK: - Internal properties
    internal var projectName: String?
    internal var projectIconURL: NSURL?
    internal var amountDonation: Int = 0
    internal var viewControllerToOpenOnComplete: UIViewController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        projectImageView?.setImageFromURL(projectIconURL, placeholder: UIImage(named: "krfc"))
        projectNameLabel?.text = projectName
        let donationString = "\(amountDonation) \(AppConfiguration().currencySymbol)"
        totalLabel?.text = donationString
        donateMessageLabel?.text = donateMessageLabel?.text?.stringByReplacingOccurrencesOfString("{amount}", withString: donationString, options: .LiteralSearch, range: nil)
    }
    
    // MARK: - IBAction
    @IBAction func closeButtonTapped(sender: AnyObject) {
        if let viewController = viewControllerToOpenOnComplete {
            navigationController?.popToViewController(viewController, animated: true)
        } else {
            sideBarController?.executeAction(SidebarViewController.defaultAction)
            dismissViewControllerAnimated(true, completion: nil)
            navigationController?.popViewControllerAnimated(true)
        }
    }
}