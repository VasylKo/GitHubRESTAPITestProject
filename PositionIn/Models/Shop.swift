//
//  Shop.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 03/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import ObjectMapper
import CleanroomLogger
import BrightFutures

struct Shop {

    static func defaultUserShop() -> Future<CRUDObjectId, NSError> {        
        return api().getMyProfile().map { $0.defaultShopId }
    }
    
    static func defaultCommunityShop(communityId: CRUDObjectId) -> Future<CRUDObjectId, NSError> {
        return api().getCommunity(communityId).map { $0.defaultShopId }
    }
    
    static func endpoint() -> String {
        return "/v1.0/shops/"
    }
}
