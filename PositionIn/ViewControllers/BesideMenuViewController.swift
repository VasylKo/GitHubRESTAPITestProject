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
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = drawerBarButtonItem()
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
