//
//  Post.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 23/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger

struct ShopItemProduct: CRUDObject {
    var objectId: CRUDObjectId = CRUDObjectInvalidId
    var name: String?
    var descriptionProd: String?
    var category: Int = 1
    var price: Int? 
    var quantity: Int = 1
    var deliveryMethod: Int = 1
    //"date": <datetime>,
    var photos: [PhotoInfo]?
    var likes: Int?
    
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
        objectId <- (map["id"], CRUDObjectIdTransform())
        name <- map["name"]
        descriptionProd <- map["description"]
        photos <- map["photos"]
        likes <- map["likes"]
        location <- map["location"]
        category <- map["category"]
        deliveryMethod <- map["deliveryMethod"]
        price <- map["price"]
        quantity <- map["quantity"]
    }
    
    static func endpoint() -> String {
        if let shopId = NSUserDefaults.standardUserDefaults().valueForKey("shopId")  as? String {
            return "/v1.0/shops/\(shopId)/items"
        }
        return "/v1.0/shops"
    }
    
    static func endpoint(productId: CRUDObjectId) -> String {
        if let shopId = NSUserDefaults.standardUserDefaults().valueForKey("shopId")  as? String {
            return "/v1.0/shops/\(shopId)/items/\(productId)"
        }
        return "/v1.0/shops/1c7e5c2b-2b47-4d87-b173-98761058b868/items/\(productId)"
    }
    
    static func userProductsEndpoint(userId: CRUDObjectId) -> String {
        if let shopId = NSUserDefaults.standardUserDefaults().valueForKey("shopId")  as? String {
            return "/v1.0/shops/\(shopId)/items"
        }
        return "v1.0/shops/1c7e5c2b-2b47-4d87-b173-98761058b868/items"
    }
    
    static func communityProductsEndpoint(communityId: CRUDObjectId) -> String {
        if let shopId = NSUserDefaults.standardUserDefaults().valueForKey("shopId")  as? String {
            Community.endpoint().stringByAppendingPathComponent("\(communityId)/shops/\(shopId)/items")
        }
        
        return Community.endpoint().stringByAppendingPathComponent("\(communityId)/shops/1c7e5c2b-2b47-4d87-b173-98761058b868/items")
    }
    
    static func allEndpoint(userId: CRUDObjectId) -> String {
        return UserProfile.endpoint().stringByAppendingPathComponent(userId).stringByAppendingPathComponent("items")
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}