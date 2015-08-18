//
//  MyProfileViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/08/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import BrightFutures
import CleanroomLogger

final class MyProfileViewController: BaseProfileViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let page = APIService.Page()
        //Future<CollectionResponse<Post>,NSError>
        api().getMyProfile().flatMap {[weak self] (profile: UserProfile) -> Future<CollectionResponse<Post>,NSError> in
            self?.didReceiveProfile(profile)
            return api().getUserPosts(profile.objectId, page: page)
        }.onSuccess { [weak self] (posts: CollectionResponse<Post>) -> () in
            self?.didReceivePosts(posts.items, page: page)
        }
    }

    private func didReceivePosts(posts: [Post], page: APIService.Page) {
        Log.debug?.value(posts)
    }
    
    private func didReceiveProfile(profile: UserProfile) {
        dataSource.items[0] = [
            ProfileInfoCellModel(name: profile.firstName, avatar: profile.avatar, background: profile.backgroundImage),
            ProfileStatsCellModel(countPosts: 113, countFollowers: 23, countFollowing: 2),
        ]
        tableView.reloadData()
    }
}
