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
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = "sdf"
    }
    
}
//class SearchBar: NibView {
//    @IBOutlet private weak var textField: UITextField!
//}
