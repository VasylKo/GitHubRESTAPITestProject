//
//  MessageListCell.swift
//  PositionIn
//
//  Created by Alex Goncharov on 9/15/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import UIKit

final class MessageListCell: TableViewCell {
    
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? MessageTableViewCellModel
        assert(m != nil, "Invalid model passed")
        
        avatar.setImageFromURL(m!.imageUrl, placeholder: UIImage(named: "placeholderEvent"))
        titleLabel.text = m!.title
        infoLabel.text = m!.info
        dateLabel.text = m!.date
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.hnk_cancelSetImage()
    }
}