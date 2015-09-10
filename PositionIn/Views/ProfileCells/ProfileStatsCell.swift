//
//  ProfileStatsCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class ProfileStatsCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? ProfileStatsCellModel
        assert(m != nil, "Invalid model passed")
        let emptyValue = NSLocalizedString("-", comment: "Counter empty value")
        postsLabel.text = m!.countPosts.map { String($0) } ?? emptyValue
        followersLabel.text = m!.countFollowers.map { String($0) } ?? emptyValue
        followingLabel.text = m!.countFollowing.map { String($0) } ?? emptyValue
        selectionStyle = .None
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postsLabel.text = nil
        followersLabel.text = nil
        followingLabel.text = nil
    }

    @IBOutlet private weak var postsLabel: UILabel!
    @IBOutlet private weak var followersLabel: UILabel!
    @IBOutlet private weak var followingLabel: UILabel!
}

public struct ProfileStatsCellModel: ProfileCellModel {
    let countPosts: Int?
    let countFollowers: Int?
    let countFollowing: Int?
}
