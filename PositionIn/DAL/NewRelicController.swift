//
//  NewRelicController.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 3/25/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import Foundation

final class NewRelicController {
    static func start() {
        NewRelic.startWithApplicationToken(AppConfiguration().newRelicToken)
    }
    
    static func logWithUser(name: String, var attributes: [String: String]) {
        attributes["UserId"] = api().currentUserId()
        NewRelic.recordEvent(name, attributes: attributes)
    }
}