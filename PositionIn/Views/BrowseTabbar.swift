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

final class BrowseTabbar: UITabBar {
    
    weak var browseDelegate: BrowseTabbarDelegate?

    var selectedMode: BrowseModeTabbarViewController.BrowseMode {
        get {
            if let selectedItem = selectedItem,
               let items = items as? [UITabBarItem],
               let index = find(items, selectedItem),
               let mode = BrowseModeTabbarViewController.BrowseMode(rawValue: index) {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        //TODO: need fix for selected relevant
        items = [
            UITabBarItem(title: NSLocalizedString("Recent", comment: "Tabbar: For You"), image: UIImage(named: "TabbarForYou"), selectedImage: UIImage(named: "TabbarForYouSelected")),
            UITabBarItem(title: NSLocalizedString("Relevant", comment: "Tabbar: New"), image: UIImage(named: "TabbarNear"), selectedImage: UIImage(named: "TabbarNear")),
        ]
        delegate = self
        
        self.tintColor = UIColor.bt_colorWithBytesR(237, g: 27, b: 46)
    }
}

extension BrowseTabbar: UITabBarDelegate {
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        browseDelegate?.tabbarDidChangeMode(self)
    }
}
