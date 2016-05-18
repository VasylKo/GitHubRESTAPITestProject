//
//  NewRelicController.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 3/25/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation
import PosInCore


final class NewRelicController {
    
    static let sharedInstance = NewRelicController()
    private init() {} //This prevents others from using the default '()' initializer for this class.

    func start() {
        #if DEBUG
            NewRelic.setApplicationBuild("Debug build")
        #else
            NewRelic.startWithApplicationToken(AppConfiguration().newRelicToken)
        #endif
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("trackNetworkFailure:"), name: NewRelicObserverNotifications.networkFailureNotification, object: nil)
    }
    
    func logWithUser(name: String, var attributes: [String: String]) {
        attributes["UserId"] = api().currentUserId()
        NewRelic.recordEvent(name, attributes: attributes)
    }
    
    @objc func trackNetworkFailure(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        NewRelic.recordEvent("NetworkFailure", attributes: userInfo)
    }
}