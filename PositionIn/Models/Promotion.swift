//
//  Post.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct Promotion: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name: String?
    var text: String?
    var discount: Float?
    var shopId: String?
    //"date": <datetime>,
    var photos: [PhotoInfo]?
    var likes: Int?
    var endDate: NSDate?
    var startDate: NSDate?
    /*
    "comments": {
    data:[],
    count: <number>
    },
    */
    /*
    "author": {
    "id": <guid>,
    "name": <string>,
    "avatar": <string>
    },
    */
    var location: Location?
    
    
    init(objectId: CRUDObjectId = CRUDObjectInvalidId) {
        self.objectId = objectId
    }
    
    init?(_ map: Map) {
        mapping(map)
        if objectId == CRUDObjectInvalidId {
            Log.error?.message("Error while parsing object")
            Log.debug?.trace()
            Log.verbose?.value(self)
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        let dateTransform =  CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        
        objectId <- (map["id"], CRUDObjectIdTransform())
        name <- map["name"]
        text <- map["text"]
        photos <- map["photos"]
        likes <- map["likes"]
        location <- map["location"]
        discount <- map["discount"]
        shopId <- map["shop"]
        endDate <- (map["endDate"], dateTransform)
        startDate <- (map["startDate"], dateTransform)
    }
    
    static func endpoint() -> String {
        return "/v1.0/promotions"
    }
    
    static func userPromotionsEndpoint(userId: CRUDObjectId) -> String {
        return "/v1.0/promotions"
    }
    
    static func communityPromotionsEndpoint(communityId: CRUDObjectId) -> String {
        return Community.endpoint().stringByAppendingPathComponent("/promotions")
    }
    
    static func allEndpoint(userId: CRUDObjectId) -> String {
        return UserProfile.endpoint().stringByAppendingPathComponent(userId).stringByAppendingPathComponent("promotions")
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}