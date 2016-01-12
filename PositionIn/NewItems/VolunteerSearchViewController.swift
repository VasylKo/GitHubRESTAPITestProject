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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var volunteerTableView: UITableView!
    
    let cellIdentifier = "CellIdentifier"
    var rowDescriptor : XLFormRowDescriptor?
    var volunteers : [Community] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api().getVolunteers().onSuccess(callback: {[weak self] response in
            self?.volunteers = response.items
            self?.activityIndicator.stopAnimating()
            self?.volunteerTableView.reloadData()
            })
        self.volunteerTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volunteers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let volunteer = self.volunteers[indexPath.row]
        cell.textLabel?.text = volunteer.name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let volunteer = self.volunteers[indexPath.row]
        
        rowDescriptor?.value = volunteer.name
        if self.navigationController != nil {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
}