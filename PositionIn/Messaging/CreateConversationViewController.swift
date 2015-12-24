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


class CreateConversationViewController: BesideMenuViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func reloadData() {
        fatalError("Abstract method – subclasses must implement \(__FUNCTION__).")
    }

//    @IBOutlet weak var tableView: TableView!
    
    lazy var dataSource: CreateConversationDataSource = { [unowned self] in
        let dataSource = CreateConversationDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

    
    class CreateConversationDataSource: TableViewDataSource {
        private var items: [UserInfoTableViewCellModel] = []
        
        func setUserList(users: [UserInfoTableViewCellModel]) {
            items = users
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



