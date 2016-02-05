//
//  CardTableViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 03/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {

    var cardName: String? {
        didSet {
            self.cardNameLabel.text = cardName
        }
    }

    var cardDescription: String? {
        didSet {
            self.cardDescriptionLabel.text = cardDescription
        }
    }
    
    var cardImage: UIImage? {
        didSet {
            self.cardIconImageView.image = cardImage
        }
    }
    
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardDescriptionLabel: UILabel!
    @IBOutlet weak var cardIconImageView: UIImageView!
}
