//
//  UIApplication+TopViewController.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 17/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        if let childViewController = base?.childViewControllers.last {
            return topViewController(childViewController)
        }
        
        return base
    }
}