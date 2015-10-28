//
//  SearchSectionCell.swift
//  PositionIn
//
//  Created by mpol on 10/5/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class SearchSectionCell: TableViewCell {

    override func setModel(model: TableViewCellModel) {
        let m = model as? SearchSectionCellModel
        assert(m != nil, "Invalid model passed")
        titleLabel?.text = m!.title
        if m!.isTappable {
            self.contentView.backgroundColor = UIColor(white: 240/255, alpha: 1)
            self.selectionStyle = UITableViewCellSelectionStyle.Gray
            self.userInteractionEnabled = true
            self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        else {
            self.selectionStyle = UITableViewCellSelectionStyle.None
            self.contentView.backgroundColor = UIColor(white: 240/255, alpha: 1)
            self.userInteractionEnabled = false
            self.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
}
