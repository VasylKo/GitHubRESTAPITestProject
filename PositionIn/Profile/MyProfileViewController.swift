//
//  MyProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit

final class MyProfileViewController: BaseProfileViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        api().getMyProfile().onSuccess { [weak self] profile in
            self?.didReceiveProfile(profile)
        }
    }

    private func didReceiveProfile(profile: UserProfile) {
        dataSource.items = [
            ProfileInfoCellModel(name: profile.firstName, avatar: profile.avatar, background: profile.backgroundImage),
            ProfileStatsCellModel(countPosts: 113, countFollowers: 23, countFollowing: 2),
        ]
        tableView.reloadData()
    }
}
