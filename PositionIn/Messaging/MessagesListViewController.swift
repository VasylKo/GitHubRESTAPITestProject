//
//  MessagesListViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 20/07/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger
import JSQMessagesViewController
import Messaging

final class MessagesListViewController: BesideMenuViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    func reloadData() {
        dataSource.setItems(ConversationManager.sharedInstance().conversations())
        tableView.reloadData()
    }
    

    typealias ChatHistoryResponseItem = Conversation
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var dataSource: ChatHistoryDataSource = { [unowned self] in
        let dataSource = ChatHistoryDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()

}


extension MessagesListViewController {
    class ChatHistoryDataSource: TableViewDataSource {
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return count(models)
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return models[indexPath.row]
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return ChatHistoryCell.reuseId()
        }
        
        override func nibCellsId() -> [String] {
            return [ ChatHistoryCell.reuseId() ]
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if let model = self.tableView(tableView, modelForIndexPath: indexPath) as? ChatHistoryCellModel {
                //TODO: move logic to the controller
                let conversation: Conversation?
                if model.isGoupChat {
                    conversation = ConversationManager.sharedInstance().groupConversation(model.userId)
                } else {
                    conversation = ConversationManager.sharedInstance().directConversation(model.userId)
                }
                map(conversation) { parentViewController?.showChatViewController($0) }
            }
        }
        
        func setItems(messages: [ChatHistoryResponseItem]) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .MediumStyle
            models = messages.map { conversation -> ChatHistoryCellModel in
                return ChatHistoryCellModel(
                    user: conversation.roomId,
                    name: conversation.name,
                    message: "",
                    imageURL: conversation.imageURL,
                    date: map(conversation.lastActivityDate) { dateFormatter.stringFromDate($0) },
                    muc: conversation.isGroupChat
                )
            }
        }
        
        
        private var models: [ChatHistoryCellModel] = []
    }
}