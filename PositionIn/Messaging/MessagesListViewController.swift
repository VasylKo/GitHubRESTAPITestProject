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

final class MessagesListViewController: BesideMenuViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        reloadData()
    }

    func reloadData() {
        let items = mockData()
        dataSource.setItems(items)
        tableView.reloadData()
    }
    
    typealias ChatHistoryResponse = (UserInfo, JSQMessage)
    
    func mockData() -> [ChatHistoryResponse] {
        let dolph = UserInfo()
        dolph.title = "Dolph Lundgren"
        dolph.avatar = NSURL(string: "http://www.flickeringmyth.com/wp-content/uploads/2014/09/dolph-lundgren.jpg")
        let tony =  UserInfo()
        tony.title = "Tony Soprano"
        tony.avatar = NSURL(string: "http://static.giantbomb.com/uploads/original/2/23298/1058360-tonysoprano1.jpg")
        let charlie = UserInfo()
        charlie.title = "Charlie Sheen"
        charlie.avatar = NSURL(string: "http://img2-2.timeinc.net/people/i/2011/news/110314/charlie-sheen-5240.jpg")
        let users: [UserInfo] = [dolph, tony, charlie]
        
        let messages: [JSQMessage] = [
            JSQMessage(senderId: "", senderDisplayName: "", date: NSDate(timeIntervalSinceNow: (-60) * 14), text: "Nicolas Cage is a great actor and he's done some good action movies too."),
            JSQMessage(senderId: "", senderDisplayName: "", date: NSDate(timeIntervalSinceNow: (-60) * 60 * 3 - 60 * 4 ), text: "We're soldiers. Soldiers don't go to hell. It's war. Soldiers kill other soldiers. We're in a situation where everyone involved knows the stakes and if you are going to accept those stakes, you've got to do certain things. It's business."),
            JSQMessage(senderId: "", senderDisplayName: "", date: NSDate(timeIntervalSinceNow: (-60) * 60 * 4 - 60 * 23), text: "The only thing I'm addicted to is winning. This bootleg cult, arrogantly referred to as Alcoholics Anonymous, reports a 5 percent success rate. My success rate is 100 percent."),
        ]
        
        return Array(zip(users, messages))
    }

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
            //TODO: move logic to the controller
            let chatController = ConversationViewController.conversationController()
            parentViewController?.navigationController?.pushViewController(chatController, animated: true)
        }
        
        func setItems(messages: [ChatHistoryResponse]) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .MediumStyle
            models = messages.map { (user, message) -> ChatHistoryCellModel in
                return ChatHistoryCellModel(
                    user: user.objectId,
                    name: user.title,
                    message: message.text,
                    imageURL: user.avatar,
                    date: map(message.date) { dateFormatter.stringFromDate($0) }
                )
            }
        }
        
        
        private var models: [ChatHistoryCellModel] = []
    }
}