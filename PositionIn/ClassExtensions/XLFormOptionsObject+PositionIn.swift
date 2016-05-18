//
//  XLFormOptionsObject+PositionIn.swift
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
    
    class func formOptionsObjectWithSearchDistance(distance: SearchFilter.Distance) -> XLFormOptionsObject! {
        return XLFormOptionsObject(value: distance.rawValue, displayText: distance.displayString())
    }
    
    var searchDistance: SearchFilter.Distance? {
        return enumValue()
    }
    
    var gender: Gender? {
        return enumValue()
    }
    
    var educationLevel: EducationLevel? {
        return enumValue()
    }
    
    private func enumValue<T: RawRepresentable>() -> T? {
        if let rawValue = formValue() as? T.RawValue {
            return T(rawValue: rawValue)
        }
        return nil
    }

}