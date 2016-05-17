//
//  NotificationView.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 17/05/16.
//  Copyright © 2016 Soluna Labs. All rights reserved.
//

import PosInCore

public enum NotificationViewType {
    case Yellow, Green
}

final class NotificationView: NibView {

    
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var type: NotificationViewType? {
        didSet {
            if let type = type {
                switch type {
                case .Yellow:
                    self.backgroundColor = UIColor.bt_colorFromHex("FAEECB", alpha: 1)
                case .Green:
                    self.backgroundColor = UIColor.bt_colorFromHex("D8F7BB", alpha: 1)
                }
            }
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
}