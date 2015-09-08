//
//  BesideMenuViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

/// Controller with Main menu button
class BesideMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if  let rootController = navigationController?.viewControllers.first as? UIViewController
            where rootController == self {
                drawerButtonVisible = true
        }
    }
    
    var drawerButtonVisible: Bool = false {
        didSet {
            let (backVisible: Bool, leftItem: UIBarButtonItem?) = {
                return self.drawerButtonVisible
                    ? (true, self.drawerBarButtonItem())
                    : (false, nil)
                
            }()
            self.navigationItem.hidesBackButton = backVisible
            self.navigationItem.leftBarButtonItem = leftItem
        }
    }
    
    @IBAction func showMainMenu(sender: AnyObject) {
        sideBarController?.setDrawerState(.Opened, animated: true)
    }
    
    func drawerBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "MainMenuIcon")!, style: .Plain, target: self, action: "showMainMenu:")
    }

    //MARK: Notifications
    
    func subscribeForContentUpdates(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "didReceiveContentUpdateNotification:",
            name: BaseAddItemViewController.NewContentAvailableNotification,
            object: sender
        )
    }
    
    func didReceiveContentUpdateNotification(notification: NSNotification) {
        contentDidChange(notification.object, info: notification.userInfo)
    }
    
    func contentDidChange(sender: AnyObject?, info: [NSObject : AnyObject]?) {
        Log.debug?.message("Receive update notification from \(sender)")
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
