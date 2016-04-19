//
//  EPlusServisesTableViewFooter.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 19/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class EPlusServisesTableViewFooter: UIView {

    var infoLabelString: String? {
        didSet {
            if let infoLabelString = infoLabelString {
                self.infoLabel.text = infoLabelString
            }
        }
    }
    
    @IBOutlet private weak var infoLabel: UILabel!
}
