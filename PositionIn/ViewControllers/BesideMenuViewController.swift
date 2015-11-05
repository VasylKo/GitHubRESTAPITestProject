//
//  BesideMenuViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import CleanroomLogger

/// Base Controller with Main menu button
class BesideMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "didReceiveContentUpdateNotification:",
            name: SearchFilter.CurrentFilterDidChangeNotification,
            object: nil
        )

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard let rootController = navigationController?.viewControllers.first where rootController == self else {
            return
        }
        drawerButtonVisible = true
    }
    
    var drawerButtonVisible: Bool = false {
        didSet {
            let (backVisible, leftItem): (Bool, UIBarButtonItem?) = {
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
        Log.debug?.message("\(self) did receive update notification from \(sender) info: \(info)")
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
        
}
