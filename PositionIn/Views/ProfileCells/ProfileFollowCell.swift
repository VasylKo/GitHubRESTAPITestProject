//
//  ProfileFollowCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 10/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import Haneke


final class ProfileFollowCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        selectionStyle = .None
        let m = model as? ProfileFollowCellModel
        assert(m != nil, "Invalid model passed")
        updateButtonForState(m!.state)
        actionDelegate = m!.actionDelegate
    }
    
    @IBAction func actionTapped(sender: UIButton) {
        if let action = UserProfileViewController.ProfileAction(rawValue: sender.tag) where action != .None {
            actionDelegate?.shouldExecuteAction(action)
        }
    }
    
    private func updateButtonForState(state: UserProfile.SubscriptionState) {
        let action:UserProfileViewController.ProfileAction
        let title: String?
        let backColor: UIColor
        var textColor: UIColor = UIColor.whiteColor()
        switch state {
        case .Following:
            action = .UnFollow
            title = NSLocalizedString("Following", comment: "Follow button: Following")
            backColor = UIScheme.unfollowActionColor
            textColor = UIColor.whiteColor()
        case .NotFollowing:
            action = .Follow
            title = NSLocalizedString("Follow", comment: "Follow button: Follow")
            backColor = UIScheme.followActionColor
            textColor = UIColor.bt_colorWithBytesR(237, g: 27, b: 46)
        case .SameUser:
            action = .None
            title = nil
            backColor = UIColor.clearColor()
            textColor = UIColor.clearColor()
        }
        actionButton.tag = action.rawValue
        actionButton.setTitle(title, forState: .Normal)
        actionButton.backgroundColor = backColor
        actionButton.titleLabel!.textColor = textColor
        actionButton.layer.borderWidth = 2
        actionButton.layer.cornerRadius = 2
        actionButton.layer.borderColor = UIColor.bt_colorWithBytesR(237, g: 27, b: 46).CGColor
        actionButton.clipsToBounds = true
    }
    
    @IBOutlet private weak var actionButton: UIButton!

    private weak var actionDelegate: UserProfileActionConsumer?
}

struct ProfileFollowCellModel: ProfileCellModel {
    let state: UserProfile.SubscriptionState
    let actionDelegate: UserProfileActionConsumer?
}
