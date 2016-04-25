//
//  DonatePaymentController.swift
//  PositionIn
//
//  Created by Vasyl Kotsiuba on 4/24/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class DonatePaymentController: CommonPaymentViewController {
    private var sectionsCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

//MARK: - Override UITableViewDataSource
extension DonatePaymentController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        <#code#>
    }
}

//MARK: - Override UITableViewDelegate
extension DonatePaymentController {
    
}
