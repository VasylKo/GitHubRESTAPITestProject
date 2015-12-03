//
//  DonateNotificationViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 03/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class DonateNotificationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(3) * NSEC_PER_SEC)),
            dispatch_get_main_queue(), {[weak self] _ in
                let controller = Storyboards.Onboarding.instantiatePaymentCompletedViewController()
                self?.navigationController?.pushViewController(controller, animated: true)
            }
        )
    }
}
