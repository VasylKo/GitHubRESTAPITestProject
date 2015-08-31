//
//  SearchBar.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

final class SearchBar: UISearchBar {
    enum Style {
        case Categories
        case Location
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInt()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInt()
    }
    
    
    private func commonInt() {
        placeholder = NSLocalizedString("Search", comment: "Search placeholder")
//        backgroundColor = UIScheme.searchbarActiveColor
//        backgroundImage = UIImage()
//        setSearchFieldBackgroundImage(UIImage(), forState: UIControlState.Normal)
        tintColor = UIColor.whiteColor()
//        layer.cornerRadius = 5
    }
    
}
