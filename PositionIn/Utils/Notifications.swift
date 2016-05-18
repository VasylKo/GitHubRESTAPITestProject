//
//  Notifications.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 02/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import JDStatusBarNotification

func showWarning(message: String) {
    JDStatusBarNotification.showWithStatus(message, dismissAfter: 3.0, styleName: JDStatusBarStyleWarning)
}

func showError(message: String) {
    JDStatusBarNotification.showWithStatus(message, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
}

func showSuccess(message: String) {
    JDStatusBarNotification.showWithStatus(message, dismissAfter: 3.0, styleName: JDStatusBarStyleSuccess)
}