//
//  UIImageView+URL.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 04/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Foundation
import Haneke

extension UIImageView {
    func setImageFromURL(url: NSURL?, placeholder: UIImage? = nil) {        
        if let url = url {
            self.hnk_setImageFromURL(url, placeholder: placeholder)
        } else {
            self.image = placeholder
        }

    }
}