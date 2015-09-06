//
//  ProfileStatsCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 9/6/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore

class CommunityStatsCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        let m = model as? CommunityStatsCellModel
        assert(m != nil, "Invalid model passed")
        let emptyValue = NSLocalizedString("-", comment: "Counter empty value")
        postsLabel.text = m!.countPosts.map { String($0) } ?? emptyValue
        membersLabel.text = m!.countMembers.map { String($0) } ?? emptyValue
        eventsLabel.text = m!.countEvents.map { String($0) } ?? emptyValue
        selectionStyle = .None
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        membersLabel.text = nil
        postsLabel.text = nil
        eventsLabel.text = nil
    }
    
    @IBOutlet private weak var membersLabel: UILabel!
    @IBOutlet private weak var postsLabel: UILabel!
    @IBOutlet private weak var eventsLabel: UILabel!
}

public struct CommunityStatsCellModel: CommunityCellModel {
    let countMembers: Int?
    let countPosts: Int?
    let countEvents: Int?
}
