//
//  InfoGroup.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 04/15/16.
//  Copyright (c) 2016 Soluna Labs. All rights reserved.
//

import ObjectMapper

struct InfoGroup: Mappable {
    var title: String?
    var infoBlocks: [String]?
   
    
    // FIXME: Ambulance Hot fix - need to remove
    init(title: String, infoBlocks: [String]) {
        self.title = title
        self.infoBlocks = infoBlocks
    }
    
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        title       <-  map["name"]
        infoBlocks  <-  map["items"]
    }
}