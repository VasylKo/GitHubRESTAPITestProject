//
//  UIScheme.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 21/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

struct UIScheme {
    static let promotionAddMenuColor = UIColor(red: 245/255.0, green: 188/255.0, blue: 69/255.0, alpha: 1.0)
    static let inviteAddMenuColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    static let eventAddMenuColor = UIColor(red: 198/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1.0)
    static let productAddMenuColor = UIColor(red: 162/255.0, green: 185/255.0, blue: 40/255.0, alpha: 1.0)
    static let postAddMenuColor = UIColor(red: 35/255.0, green: 113/255.0, blue: 213/255.0, alpha: 1.0)
    
    static let mainThemeColor = UIColor(red: 237/255.0, green: 27/255.0, blue: 46/255.0, alpha: 1.0)
    static let tabbarBackgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    
    static let searchbarBgColor = UIColor(red: 142/255.0, green: 16/255.0, blue: 27/255.0, alpha: 1.0)
    
    static let communityActionColor = UIColor(red: 237/255.0, green: 27/255.0, blue: 46/255.0, alpha: 1.0)
    
    static let followActionColor = UIColor(red: 35/255.0, green: 113/255.0, blue: 213/255.0, alpha: 0.0)
    static let unfollowActionColor = UIColor(red: 237/255.0, green: 27/255.0, blue: 46/255.0, alpha: 1.0)
    
    static let enableActionColor = UIColor(red: 237/255.0, green: 27/255.0, blue: 46/255.0, alpha: 1.0)
    static let disableActionColor = UIColor(red: 243/255.0, green: 130/255.0, blue: 140/255.0, alpha: 1.0)
    
    static func appRegularFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica Neue", size: size) ?? UIFont.systemFontOfSize(size)
    }
}