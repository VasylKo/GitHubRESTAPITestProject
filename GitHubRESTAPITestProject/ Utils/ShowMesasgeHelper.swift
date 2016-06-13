//
//  ShowMesasgeHelper.swift
//  GitHubRESTAPITestProject
//
//  Created by Vasyl Kotsiuba on 13.06.16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation
import BRYXBanner

enum UIUserMessageType {
    case success, warning
}

func showMessage(type messageType: UIUserMessageType  = .success, title: String? = nil, subtitle: String? = nil, duration: NSTimeInterval = 2.0) {
    let backgroundColor: UIColor
    
    switch messageType {
    case .success:
        backgroundColor = UIColor(red: 32/255, green: 151/255, blue: 81/255, alpha: 1)
    case .warning:
        backgroundColor = .orangeColor()
    }
    
    let banner = Banner(title: title, subtitle: subtitle, backgroundColor: backgroundColor)
    banner.dismissesOnSwipe = true
    banner.show(duration: duration)
}