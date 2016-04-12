//
//  PostAttachmentsCell.swift
//  PositionIn
//
//  Created by ng on 2/12/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import PosInCore

class PostAttachmentsCell: TableViewCell {
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? PostAttachmentsModel
        assert(m != nil, "Invalid model passed")
        self.imageView?.image = UIImage(named: "productTerms&Info")
        self.imageView?.tintColor = UIScheme.mainThemeColor
        self.textLabel?.text = NSLocalizedString("Attachments")
        self.textLabel?.textAlignment = .Left
    }
    
}