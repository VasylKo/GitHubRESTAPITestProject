//
//  NotificationViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 17/02/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class NotificationViewController: UITableViewController {
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }
    
    //MARK: Setup Interface
    
    func setupInterface() {
        self.title = NSLocalizedString("Notification", comment:"")
    }
}
