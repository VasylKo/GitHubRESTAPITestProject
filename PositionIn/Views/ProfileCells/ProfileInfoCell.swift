//
//  ProfileInfoCell.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import Haneke

final class ProfileInfoCell: TableViewCell {
    override func setModel(model: TableViewCellModel) {
        selectionStyle = .None
        let m = model as? ProfileInfoCellModel
        assert(m != nil, "Invalid model passed")
        nameLabel.text = m!.name
        avatarView.setImageFromURL(m!.avatar)
        if let imageURL = m!.background {
            self.backImageView.hnk_setImageFromURL(imageURL)
        }
        updateButton(leftActionButton, forAction: m!.leftAction)
        updateButton(rightActionButton, forAction: m!.rightAction)
        actionDelegate = m!.actionDelegate
    }
    
    @IBAction func actionTapped(sender: UIButton) {
        if let action = UserProfileViewController.ProfileAction(rawValue: sender.tag) where action != .None {
            actionDelegate?.shouldExecuteAction(action)
        }
    }
    
    private func updateButton(btn: UIButton, forAction action: UserProfileViewController.ProfileAction) {
        btn.tag = action.rawValue
        switch action {
        case .Edit:
            btn.setImage(UIImage(named: "profileEdit"), forState: .Normal)
        case .Chat:
            btn.setImage(UIImage(named: "profileChat"), forState: .Normal)
        case .Call:
            btn.setImage(UIImage(named: "profileCall"), forState: .Normal)
        case .None:
            fallthrough
        default:
            btn.setImage(nil, forState: .Normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backImageView.hnk_cancelSetImage()
        avatarView.cancelSetImage()
    }
    
    
    @IBOutlet private weak var backImageView: UIImageView!
    @IBOutlet private weak var avatarView: AvatarView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var leftActionButton: UIButton!
    @IBOutlet private weak var rightActionButton: UIButton!
    
    private weak var actionDelegate: UserProfileActionConsumer?
}

public struct ProfileInfoCellModel: ProfileCellModel {
    let name: String?
    let avatar: NSURL?
    let background: NSURL?
    let leftAction: UserProfileViewController.ProfileAction
    let rightAction: UserProfileViewController.ProfileAction
    let actionDelegate: UserProfileActionConsumer?
}
