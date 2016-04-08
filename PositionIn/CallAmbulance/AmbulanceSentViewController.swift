//
//  AmblanceSentViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 29/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

class AmbulanceSentViewController: AmbulanceBaseController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenToAnalytics("CallAmbulanceConfirmed")
    }
}
