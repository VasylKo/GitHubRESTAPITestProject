//
//  Location.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

struct Location: Mappable {
    private(set) var x: Double!
    private(set) var y: Double!
    private(set) var street1: String?
    private(set) var street2: String?
    private(set) var country: String?
    private(set) var state: String?
    private(set) var city: String?
    private(set) var zip: String?
    
    
    init?(_ map: Map) {
        mapping(map)
        switch (x, y) {
        case (.Some, .Some):
            break
        default:
            println("Error while parsing object \(self)")
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        x <- map["x"]
        y <- map["y"]
        street1 <- map["street1"]
        street2 <- map["street2"]
        country <- map["country"]
        state <- map["state"]
        city <- map["city"]
        zip <- map["zip"]
    }
}