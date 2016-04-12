//
//  NotificationViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 17/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class NotificationViewController: UITableViewController {
    
    private var notifications: [SystemNotification]?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
        self.loadData()
    }
    
    //MARK: Load Data 
    
    func loadData() {
        api().getNotifications().onSuccess(callback: { [weak self] (response : CollectionResponse<SystemNotification>) in
            trackEventToAnalytics(AnalyticCategories.notifications, action: AnalyticActios.notificationCount, value: NSNumber(integer: response.items.count))
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
        if let notifications = self.notifications,
        cell = cell as? NotificationTableViewCell {
            let notification = notifications[indexPath.row]
            cell.configureWithNotification(notification)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let notification = notifications![indexPath.row]
        if notification.isRead != true {
            api().readNotifications([notification.objectId]).onSuccess(callback: { [weak self] in
                self?.loadData()
                })
        }
    }
}
