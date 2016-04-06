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
        subscribeForNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        trackScreenToAnalytics(AnalyticsLabels.messages)
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

    private func subscribeForNotifications() {
        let conversationChangeBlock: NSNotification! -> Void = { [weak self] notification in
            self?.reloadData()
        }
        
        conversationDidChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            ConversationManager.ConversationsDidChangeNotification,
            object: nil,
            queue: nil,
            usingBlock: conversationChangeBlock)
    }

    private var conversationDidChangeObserver: NSObjectProtocol!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(conversationDidChangeObserver)
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newMessage" {
            trackEventToAnalytics(AnalyticCategories.messages, action: AnalyticActios.clickNew)
        }
    }
    
}


extension MessagesListViewController {
    class ChatHistoryDataSource: TableViewDataSource {
        
        override func configureTable(tableView: UITableView) {
            tableView.estimatedRowHeight = 80.0
            super.configureTable(tableView)
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return models.count
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
                if let conversation = conversation {
                    parentViewController?.showChatViewController(conversation)
                }
            }
        }
        
        func setItems(messages: [ChatHistoryResponseItem]) {
            models = messages.map { conversation -> ChatHistoryCellModel in
                return ChatHistoryCellModel(
                    user: conversation.roomId,
                    name: conversation.name,
                    message: "",
                    imageURL: conversation.imageURL,
                    date: Optional(conversation.lastActivityDate).map { $0.formattedAsTimeAgo() },
                    muc: conversation.isGroupChat,
                    unreadCount: conversation.unreadCount
                )
            }
        }
        
        
        private var models: [ChatHistoryCellModel] = []
    }
}