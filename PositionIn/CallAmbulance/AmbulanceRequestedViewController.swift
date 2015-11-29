//
//  AmbulanceRequestedViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 29/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

class AmbulanceRequestedViewController: AmbulanceBaseController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(3) * NSEC_PER_SEC)),
            dispatch_get_main_queue(), {[weak self] _ in
                self?.performSegue(AmbulanceRequestedViewController.Segue.AmbulanceSentSegueId)
            }
        )
    }
    
}
