//
//  VolunteerSearchViewController.swift
//  PositionIn
//
//  Created by ng on 1/12/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CleanroomLogger


class VolunteerSearchViewController: UIViewController, XLFormRowDescriptorViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var volunteerTableView: UITableView!
    
    let cellIdentifier = "CellIdentifier"
    var rowDescriptor : XLFormRowDescriptor?
    var volunteers : [Community]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.volunteerTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = "vol"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        rowDescriptor?.value = "test"
        if self.navigationController != nil {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
}