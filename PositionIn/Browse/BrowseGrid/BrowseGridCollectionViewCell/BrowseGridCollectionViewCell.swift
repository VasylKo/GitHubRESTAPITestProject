//
//  BrowseGridCollectionViewCell.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 25/11/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import UIKit

class BrowseGridCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.homeItemNameLabel.text = name
    }
    
    var image: UIImage? {
        didSet {
            self.homeItemImage.image = image
        }
    }
    
    var name: String? {
        didSet {
            self.homeItemNameLabel.text = name
        }
    }
    
    @IBOutlet weak var homeItemImage: UIImageView!
    @IBOutlet weak var homeItemNameLabel: UILabel!
}