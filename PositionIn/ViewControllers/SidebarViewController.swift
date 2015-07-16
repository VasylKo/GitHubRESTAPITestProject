//
//  SidebarViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 16/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import UISidebarViewController

class SidebarViewController: UISidebarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIViewController {
    var sideBarController: UISidebarViewController? {
        return searchSideBarController(self)
    }
    
    private func searchSideBarController(controller: UIViewController?) -> UISidebarViewController? {
        switch controller {
        case .None:
            return nil
        default:
            if let c = controller as? UISidebarViewController {
                return c
            }
        }
        return searchSideBarController(controller?.parentViewController)
    }
}