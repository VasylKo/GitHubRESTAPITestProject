//
//  PaymentCompletedViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 03/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class PaymentCompletedViewController: UIViewController {


    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}
