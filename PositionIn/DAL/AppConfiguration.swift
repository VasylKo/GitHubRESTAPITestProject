//
//  AppConfiguration.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

final class AppConfiguration {
    init() {
        baseURL = NSURL(string: "https://app-dev.positionin.com/api/")!
        amazonURL = NSURL(string: "https://pos-dev.s3.amazonaws.com/")!
    }
    
    let baseURL : NSURL
    let amazonURL : NSURL

}
