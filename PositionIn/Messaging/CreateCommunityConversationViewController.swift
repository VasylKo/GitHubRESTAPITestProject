
//
//  CreateCommunityConversationViewController.swift
//  PositionIn
//
//  Created by Mikhail Polyevin on 24/12/15.
//  Copyright © 2015 Soluna Labs. All rights reserved.
//

import PosInCore

class CreateCommunityConversationViewController: CreateConversationViewController {
    
    @IBOutlet weak var tableView: TableView!
    
    @IBOutlet weak var followLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(self.tableView)
        reloadData()
    }
    
    override func reloadData() {
        let communities = ConversationManager.sharedInstance().hiddenGroupConversations().map { c  -> UserInfoTableViewCellModel in
            let userInfo = UserInfo(objectId: c.roomId)
            userInfo.title = c.name
            userInfo.isCommunity = true
            userInfo.avatar = c.imageURL
            return UserInfoTableViewCellModel(userInfo: userInfo)
        }
        
        trackEventToAnalytics(AnalyticCategories.messages, action: AnalyticActios.clickNewCommunities, value: NSNumber(integer: communities.count))
        
        self.tableView.hidden = communities.count == 0
        self.followLabel.hidden = communities.count != 0
        self.dataSource.setUserList(communities)
        self.tableView.reloadData()
    }

}
