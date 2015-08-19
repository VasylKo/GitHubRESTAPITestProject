//
//  XLFormOptionsObject+Community.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 19/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import XLForm


extension XLFormOptionsObject {
    
    //TODO: remove Box
    
    class func formOptionsObjectWithCommunity(community: Community) -> XLFormOptionsObject! {
        return XLFormOptionsObject(value: community.objectId, displayText: community.name ?? "")
    }
    
    var communityId: CRUDObjectId? {
        return formValue() as? CRUDObjectId
    }
}