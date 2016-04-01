//
//  GoogleAnalystHelper.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 11/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import Foundation

func trackGoogleAnalyticsEvent(categoryName: String, action: String, label: String = "", value: NSNumber? = nil) {
    let tracker = GAI.sharedInstance().defaultTracker
    let builder = GAIDictionaryBuilder.createEventWithCategory(categoryName,
        action: action, label: label, value: value)
    tracker?.send(builder.build() as [NSObject : AnyObject])
}