//
//  EPlusServisesTableViewHeader.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 18/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusServisesTableViewHeader: UIView {
    
    var mainImageString: String? {
        didSet {
            if let mainImageString = mainImageString {
                self.mainImageView.image = UIImage(named: mainImageString)
            }
        }
    }
    
    var iconImageString: String? {
        didSet {
            if let iconImageString = iconImageString {
                self.iconImageView.image = UIImage(named: iconImageString)
            }
        }
    }
    
    var titleString: String? {
        didSet {
            if let titleString = titleString {
                self.titleLabel.text = titleString
            }
        }
    }

    
    @IBOutlet weak private var mainImageView: UIImageView!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
}
