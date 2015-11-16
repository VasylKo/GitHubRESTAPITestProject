//
//  CreateConversationViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 07/10/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

protocol CreateConversationActionConsumer {
    func openConversation(info: UserInfo)
}


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
    
    private lazy var dataSource: CreateConversationDataSource = { [unowned self] in
        let dataSource = CreateConversationDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

    
    final class CreateConversationDataSource: TableViewDataSource {
        private var items: [UserInfoTableViewCellModel] = []
        
        
        func setUserList(users: [UserInfo]) {
            let peoples = users.map { UserInfoTableViewCellModel(userInfo: $0) }
            let communities = ConversationManager.sharedInstance().hiddenGroupConversations().map { c  -> UserInfoTableViewCellModel in
                let userInfo = UserInfo(objectId: c.roomId)
                userInfo.title = c.name
                userInfo.isCommunity = true
                userInfo.avatar = c.imageURL
                return UserInfoTableViewCellModel(userInfo: userInfo)
            }
            items = peoples + communities
        }
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 60.0
            super.configureTable(tableView)
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return PeopleListCell.reuseId()
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return items[indexPath.row]
        }
        
        override func nibCellsId() -> [String] {
            return [ PeopleListCell.reuseId() ]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            
            if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? UserInfoTableViewCellModel,
                let parentViewController = parentViewController as? CreateConversationActionConsumer {
                    parentViewController.openConversation(model.userInfo)
            }
        }
        
    }
    
}

extension CreateConversationViewController: CreateConversationActionConsumer {
    func openConversation(info: UserInfo) {
        if let navigationController = navigationController {
            navigationController.popViewControllerAnimated(false)
            dispatch_delay(0.0) {
                if info.isCommunity == true {
                    navigationController.visibleViewController?.showGroupChatViewController(info.objectId)
                } else {
                    navigationController.visibleViewController?.showChatViewController(info.objectId)
                }
            }
        }
    }
}



