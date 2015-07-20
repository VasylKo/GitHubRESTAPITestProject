//
//  MainMenuCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class MainMenuUserCell: TableViewCell {
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellImageTextModel
        assert(m != nil, "Invalid model passed")
        titleLabel?.text = m!.title
        if let imageURL = NSURL(string: m!.image) {
            avatarView.setImageFromURL(imageURL)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.cancelSetImage()
    }
    
}