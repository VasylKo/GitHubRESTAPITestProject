//
//  ItemCategory.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 25/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation

enum ItemCategory: Int, DebugPrintable {
    case Unknown
    case AnimalsPetSupplies, ApparelAccessories, ArtsEntertainment, BabyToddler, BusinessIndustrial,
         CamerasOptics, Electronics, Food, Furniture, Hardware, HealthBeauty, HomeGarden, LuggageBags
    
    static func all() -> [ItemCategory] {
        return [
            .AnimalsPetSupplies, .ApparelAccessories, .ArtsEntertainment, .BabyToddler, .BusinessIndustrial,
            .CamerasOptics, .Electronics, .Food, .Furniture, .Hardware, .HealthBeauty, .HomeGarden, .LuggageBags
        ]
    }
    
    func displayString() -> String {
        switch self {
        case .AnimalsPetSupplies:
            return NSLocalizedString("Blood", comment: "ItemCategory: AnimalsPetSupplies")
        case .ApparelAccessories:
            return NSLocalizedString("Construction", comment: "ItemCategory: ApparelAccessories")
        case .ArtsEntertainment:
            return NSLocalizedString("Clothes", comment: "ItemCategory: ArtsEntertainment")
        case .BabyToddler:
            return NSLocalizedString("Electronics", comment: "ItemCategory: BabyToddler")
        case .BusinessIndustrial:
            return NSLocalizedString("Fire", comment: "ItemCategory: BusinessIndustrial")
        case .CamerasOptics:
            return NSLocalizedString("Food", comment: "ItemCategory: CamerasOptics")
        case .Electronics:
            return NSLocalizedString("Hardware", comment: "ItemCategory: Electronics")
        case .Food:
            return NSLocalizedString("Healthcare", comment: "ItemCategory: Food")
        case .Furniture:
            return NSLocalizedString("Medicine", comment: "ItemCategory: Furniture")
        case .Hardware:
            return NSLocalizedString("Manpower", comment: "ItemCategory: Hardware")
        case .HealthBeauty:
            return NSLocalizedString("Religious & Ceremonial", comment: "ItemCategory: HealthBeauty")
        case .HomeGarden:
            return NSLocalizedString("Vehicles & Parts", comment: "ItemCategory: HomeGarden")
        case .LuggageBags:
            return NSLocalizedString("Water", comment: "ItemCategory: LuggageBags")
        case .Unknown:
            fallthrough
        default:
            return NSLocalizedString("All", comment: "ItemCategory: Unknown")
        }
    }
        
    var debugDescription: String {
        return "<ItemCategory:\(displayString())>"
    }
}