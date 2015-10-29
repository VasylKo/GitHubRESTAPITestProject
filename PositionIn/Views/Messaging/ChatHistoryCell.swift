//
//  MessageListCell.swift
//  PositionIn
//
//  Created by Alex Goncharov on 9/15/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import UIKit

final class ChatHistoryCell: TableViewCell {
    
    @IBOutlet private weak var avatar: AvatarView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var badgeView: BadgeView!
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? ChatHistoryCellModel
        assert(m != nil, "Invalid model passed")
        avatar.setImageFromURL(m!.imageUrl)
        titleLabel.text = m!.name
        infoLabel.text = m!.message
        dateLabel.text = m!.date
        badgeView.hidden = m!.unreadCount == 0
        badgeView.setText(String(m!.unreadCount),  animated: false)
        badgeView.badgeColor = UIScheme.mainThemeColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.cancelSetImage()
    }
}