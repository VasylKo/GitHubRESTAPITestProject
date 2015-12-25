//
//  CreateUserConversationViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 24/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import PosInCore

class CreateUserConversationViewController: CreateConversationViewController {
    
    @IBOutlet weak var tableView: TableView!
    
    @IBOutlet weak var followLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        reloadData()
    }
    
    override func reloadData() {
        api().getMySubscriptions().onSuccess { [weak self] response in
            if let userList = response.items {
                let users = userList.map { UserInfoTableViewCellModel(userInfo: $0) }
                
                self?.tableView.hidden = users.count == 0
                self?.followLabel.hidden = users.count != 0
                
                self?.dataSource.setUserList(users)
                self?.tableView.reloadData()
            }
        }
    }
}
