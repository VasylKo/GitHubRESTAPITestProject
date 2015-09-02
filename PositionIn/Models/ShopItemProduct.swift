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
    var author: CRUDObjectId?
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
        author <- (map["author"], CRUDObjectIdTransform())
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
        return "/v1.0/shops/items"
    }
    
    static func endpoint(productId: CRUDObjectId, author: UserProfile) -> String {
        if let shop = author.shops?.first, let shopId = shop["id"]  {
            return "/v1.0/shops/\(shopId)/items/\(productId)"
        }
        return "/v1.0/shops/items/\(productId)"
    }
    
    static func userProductsEndpoint(profile: UserProfile) -> String {
        if let shop = profile.shops?.first, let shopId = shop["id"]  {
            return "/v1.0/shops/\(shopId)/items"
        }
        return "v1.0/shops/items"
    }
    
    static func communityProductsEndpoint(community: Community) -> String {
         if let shop = community.shops?.first, let shopId = shop["id"]  {
            Community.endpoint().stringByAppendingPathComponent("\(community.objectId)/shops/\(shopId)/items")
        }
        
        return Community.endpoint().stringByAppendingPathComponent("\(community.objectId)/shops/items")
    }
    
    static func allEndpoint(userId: CRUDObjectId) -> String {
        return UserProfile.endpoint().stringByAppendingPathComponent(userId).stringByAppendingPathComponent("items")
    }
    
    var description: String {
        return "<\(self.dynamicType):\(objectId)>"
    }
}