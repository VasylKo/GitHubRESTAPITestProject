//
//  BrowseTabbar.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 22/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

@objc protocol BrowseTabbarDelegate {
    func tabbarDidChangeMode(tabbar: BrowseTabbar)
}

class BrowseTabbar: UITabBar {
    
    weak var browseDelegate: BrowseTabbarDelegate?

    var selectedMode: BrowseViewController.BrowseMode {
        get {
            if let selectedItem = selectedItem,
               let items = items as? [UITabBarItem],
               let index = find(items, selectedItem),
               let mode = BrowseViewController.BrowseMode(rawValue: index) {
                    return mode
            }
            return .ForYou
        }
        set {
            let index = newValue.rawValue
            
            if let items = items as? [UITabBarItem] where indices(items) ~= index {
                    selectedItem = items[index]
            }
        }
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        items = [
            UITabBarItem(title: NSLocalizedString("For You", comment: "Tabbar: For You"), image: UIImage(named: "TabbarForYou"), selectedImage: UIImage(named: "TabbarForYouSelected")),
            UITabBarItem(title: NSLocalizedString("Near", comment: "Tabbar: Near"), image: UIImage(named: "TabbarNear"), selectedImage: UIImage(named: "TabbarNearSelected")),
        ]
        delegate = self
    }
}

extension BrowseTabbar: UITabBarDelegate {
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        browseDelegate?.tabbarDidChangeMode(self)
    }
}
