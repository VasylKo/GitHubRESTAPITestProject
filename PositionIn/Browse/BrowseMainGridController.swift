//
//  BrowseMainGridController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 24/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

class BrowseMainGridController: BrowseModeTabbarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationBarButtonItem = UIBarButtonItem(image: UIImage(named: "notification_icon"), style: .Plain, target: self, action: "notificationTouched")
        self.navigationItem.rightBarButtonItem = notificationBarButtonItem
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        navigationController?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        api().hasNotifications().onSuccess { [weak self] (has : Bool) -> Void in
            self?.navigationItem.rightBarButtonItem?.enabled = has
        }
    }
    
    @objc func notificationTouched() {
        let controller = NotificationViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func presentSearchViewController(filter: SearchFilter) {
        childFilterUpdate = nil
        applyDisplayMode(displayMode)
        super.presentSearchViewController(filter)
    }
    
    override func prepareDisplayController(controller: UIViewController) {
        super.prepareDisplayController(controller)
        if let filterUpdate = childFilterUpdate,
            let filterApplicator = controller as? UpdateFilterProtocol {
                filterApplicator.applyFilterUpdate(filterUpdate)
        }
    }

}

// MARK: - UINavigationControllerDelegate
extension BrowseMainGridController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        // Hide title on back button
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = backItem
    }
}