//
//  MembershipPlansCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 02/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class MembershipPlansCell: UITableViewCell {
    
    var titleString: String? {
        didSet {
            self.topLabel.text = titleString
        }
    }
    
    var descriptionString: String? {
        didSet {
            self.descriptionLabel.text = descriptionString
        }
    }
    
    var membershipIcon: UIImage? {
        didSet {
            self.membershipImageView.image = membershipIcon
        }
    }
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var membershipImageView: UIImageView!
}
