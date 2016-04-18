//
//  AboutEplusServiceTableViewCell.swift
//  PositionIn
//
//  Created by Vasiliy Kotsiuba on 18/04/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import UIKit

class AboutEplusServiceTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView?
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var subTitle: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
