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
        tableView?.registerNib(UINib(nibName: String(DonateCell.self), bundle: nil), forCellReuseIdentifier: String(DonateCell.self))
    }


}

//MARK: - Override UITableViewDataSource
extension DonatePaymentController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath {
        case NSIndexPath(forRow: 0, inSection: 0):
            return DonateCell.cellHeight
        case NSIndexPath(forRow: 1, inSection: 0):
            return DonateCell.cellHeight
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(DonateCell.self), forIndexPath: indexPath) as! DonateCell
            return cell
        default:
            return UITableViewCell()
        }
    }
}

//MARK: - Override UITableViewDelegate
extension DonatePaymentController {
    
}
