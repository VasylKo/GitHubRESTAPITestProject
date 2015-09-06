//
//  MainMenuCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 18/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

final class MainMenuUserCell: TableViewCell {
    
    @IBOutlet private weak var avatarView: AvatarView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? TableViewCellImageTextModel
        assert(m != nil, "Invalid model passed")
        titleLabel?.text = m!.title
        avatarView.setImageFromURL(NSURL(string: m!.image))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.cancelSetImage()
    }
    
}