//
//  UserListTableViewCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 13/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

final class UserListCell: TableViewCell {

    override func prepareForReuse() {
        super.prepareForReuse()
        userImages.map() { view in
            view.cancelSetImage()
        }
    }
    
    override func setModel(model: TableViewCellModel) {
        let m = model as? UserListCellModel
        assert(m != nil, "Invalid model passed")
        userImages.map() { view in
            view.removeFromSuperview()
        }
        
        userImages = m!.users.map() { profile in
            let view = AvatarView(image: UIImage(named: "MainMenuForYou")!)
            self.contentView.addSubview(view)
            if let url = NSURL(string: "https://www.daycounts.com/images/stories/virtuemart/product/Virtuemart_Bundl_4f6eaee37356e.png") {
                view.setImageFromURL(url)
            }
            return view
        }
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let itemsPadding: CGFloat = 5
        userImages.reduce(itemsPadding) { offset, view in
            view.frame = CGRect(origin: CGPoint(x: offset, y: 0), size: view.bounds.size)
            return view.frame.maxX
        }
    }
    
    private var userImages: [AvatarView] = []
    
}


public struct UserListCellModel: TableViewCellModel {
    let users: [UserProfile]
}

