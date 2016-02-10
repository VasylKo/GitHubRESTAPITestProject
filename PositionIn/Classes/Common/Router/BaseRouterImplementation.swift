//
//  BaseRouterImplementation.swift
//  PositionIn
//
//  Created by ng on 1/26/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import CleanroomLogger

class BaseRouterImplementation : NSObject, BaseRouter {
    
    func dismiss(viewController : UIViewController, animated : Bool) {
        if viewController.navigationController != nil || viewController.presentingViewController != nil {
            if viewController.navigationController?.viewControllers.count > 1 {
                viewController.navigationController?.popViewControllerAnimated(true)
            } else {
                viewController.dismissViewControllerAnimated(animated, completion: nil)
            }
        } else {
            Log.error?.message("Can't perform dismiss action")
        }
    }
    
}