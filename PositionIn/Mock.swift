//
//  Mock.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import ObjectMapper

struct Mock {
    static func userProfile() -> UserProfile {
        let json: [String : AnyObject] = [
            "id" : CRUDObjectInvalidId,
            "firstName" : "First",
            "middleName" : "middle",
        ]
        let mapper: Mapper<UserProfile> = Mapper()
        return mapper.map(json)!
    }
}