//
//  NotificationViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 17/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class NotificationViewController: UITableViewController {
    
    private var notifications: [Notification]?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
        api().getNotifications().onSuccess(callback: { [weak self] (response : CollectionResponse<Notification>) in
            self?.notifications = response.items
            self?.tableView.reloadData()
            })
    }
    
    //MARK: Setup Interface
    
    func setupInterface() {
        self.title = NSLocalizedString("Notification", comment:"")
        
        let reuseIdentifier = NSStringFromClass(NotificationTableViewCell.self)
        
        self.tableView.registerNib(UINib(nibName: reuseIdentifier, bundle: nil),
            forCellReuseIdentifier:reuseIdentifier)
        self.tableView.estimatedRowHeight = 50

    }
    
    //MARK: Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        if let notifications = self.notifications {
            numberOfRowsInSection = notifications.count
        }
        return numberOfRowsInSection
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(NotificationTableViewCell.self), forIndexPath: indexPath)
        if let notification = self.notifications,
        cell = cell as? NotificationTableViewCell {
            let notification = notification[indexPath.row]
            cell.configureWithNotification(notification)
        }
        return cell
    }
}