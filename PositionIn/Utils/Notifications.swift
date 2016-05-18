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
    let container = NotificationViewContainer(frame: CGRectZero)
    container.show(title: message, type: .Yellow)
}

func showError(message: String) {
    let container = NotificationViewContainer(frame: CGRectZero)
    container.show(title: message, type: .Yellow)
}

func showSuccess(message: String) {
    let container = NotificationViewContainer(frame: CGRectZero)
    container.show(title: message, type: .Green)
}