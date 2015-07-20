//
//  SidebarViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import KYDrawerController

class SidebarViewController: KYDrawerController {
/*
    override init!(centerViewController center: UIViewController!, andSidebarViewController sidebar: UIViewController!) {
        super.init(centerViewController: center, andSidebarViewController: sidebar)
        sidebar.view.bounds = CGRect(origin: CGPointZero, size: CGSize(width: sidebarWidth, height: sidebar.view.bounds.height))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("\(__FUNCTION__) does not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 */
}

extension UIViewController {
    var sideBarController: SidebarViewController? {
        return searchSideBarController(self.navigationController)
    }
    
    private func searchSideBarController(controller: UIViewController?) -> SidebarViewController? {
        switch controller {
        case .None:
            return nil
        default:
            if let c = controller as? SidebarViewController {
                return c
            }
        }
        return searchSideBarController(controller?.parentViewController)
    }

}