//
//  CreateConversationViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

final class CreateConversationViewController: BesideMenuViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        reloadData()
    }
    
    func reloadData() {
        api().getMySubscriptions().onSuccess { [weak self] response in
            if let userList = response.items {
                Log.debug?.value(userList)
                self?.dataSource.setUserList(userList)
                self?.tableView.reloadData()
            }
        }
    }

    @IBOutlet private weak var tableView: TableView!    
    
    private lazy var dataSource: PeopleListDataSource = { [unowned self] in
        let dataSource = PeopleListDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

}

extension CreateConversationViewController: PeopleActionConsumer {
    func showProfileScreen(userId: CRUDObjectId) {
        if let navigationController = navigationController {
            navigationController.popViewControllerAnimated(false)
            dispatch_delay(0.0) {
                navigationController.visibleViewController?.showChatViewController(Conversation(userId: userId))
            }
        }
    }
}