//
//  CommunitySearchViewController.swift
//  PositionIn
//
//  Created by ng on 1/12/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit
import XLForm
import CleanroomLogger
import Box

class CommunitySearchViewController: UIViewController, XLFormRowDescriptorViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let cellIdentifier = "CellIdentifier"
    var items : [Community] = []
    var rowDescriptor : XLFormRowDescriptor?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var communityTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.communityTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.communityTableView.tableFooterView = UIView(frame: CGRect.zero)
        api().currentUserId().flatMap { userId in
            return api().getUserCommunities(userId)
            }.onSuccess { [weak self] response in
                if self != nil {
                    self?.items = response.items
                    self?.communityTableView?.reloadData()
                    self?.activityIndicator.stopAnimating()
                }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let community = items[indexPath.row]
        cell.textLabel?.text = community.name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let community = self.items[indexPath.row]
        rowDescriptor?.value = Box(community)
        
        if self.navigationController != nil {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
}
