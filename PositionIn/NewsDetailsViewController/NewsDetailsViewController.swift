//
//  PostViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 06/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import PosInCore
import CleanroomLogger
import BrightFutures

protocol NewsActionConsumer: class {
    func likePost()
    func commentPost()
}

final class NewsDetailsViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        tableView.separatorStyle = .None
        self.enterCommentField.delegate = self;
        self.reloadPost()
        
        self.title = NSLocalizedString("News")
        self.tableView.backgroundColor = UIColor.bt_colorWithBytesR(238, g: 238, b: 238)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeOnKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotification()
    }
    
    private func reloadPost() {
        if let objectId = objectId {
            api().getPost(objectId).onSuccess { [weak self] post in
                var post = post
                api().getPostComments(objectId).onSuccess(callback: { [weak self] response in
                    if let comments = response.items {
                        post.comments = comments
                    }
                    self?.post = post
                    self?.dataSource.setPost(post)
                    self?.tableView.reloadData()
                    self?.tableView.layoutIfNeeded();
                    })
            }
        }
    }
    
    private func subscribeOnKeyboardNotification() {
        
        let animationClosure : (NSNotification!) -> Void = {[weak self] (note: NSNotification!) -> Void in
            let userInfo: NSDictionary = note.userInfo!
            let keyboardEndFrameValue: NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue;
            let keyboardEndFrame: CGRect = keyboardEndFrameValue.CGRectValue();
            let duration = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as! NSTimeInterval
            let notificationName = note.name
            
            var bottomMargin: CGFloat = 5.0
            if notificationName == UIKeyboardWillShowNotification {
                bottomMargin += keyboardEndFrame.height
            }
            
            self?.enterCommentFieldBottomSpaceConstraint.constant = bottomMargin
            self?.view.setNeedsUpdateConstraints();
            
            UIView.animateWithDuration(duration, animations: {
                self?.view.layoutIfNeeded()
            })
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil, usingBlock: animationClosure)
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil, usingBlock: animationClosure)
    }
    
    private func unsubscribeFromKeyboardNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private lazy var dataSource: NewsDataSource = { [unowned self] in
        let dataSource = NewsDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()
    
    
    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var enterCommentField: UITextField!
    @IBOutlet weak var enterCommentFieldBottomSpaceConstraint: NSLayoutConstraint!
    var objectId: CRUDObjectId?
    private var post: Post?
    var isFeautered: Bool = false
}

extension NewsDetailsViewController {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = textField.text where text.characters.count > 0, let post = post else  {
            return true
        }
        
        var comment = Comment()
        comment.text = text
        
        api().createPostComment(post.objectId, object: comment).onSuccess {[weak self, weak textField] comment in
            self?.reloadPost()
            textField?.text = nil
        }
        
        return true;
    }
}

extension NewsDetailsViewController: NewsActionConsumer {
    
    func likePost() {
        if let tempPost = post {
            if (tempPost.isLiked) {
                api().unlikePost(tempPost.objectId).onSuccess{[weak self] in
                    self?.reloadPost()
                }
            }
            else {
                api().likePost(tempPost.objectId).onSuccess{[weak self] in
                    self?.reloadPost()
                }
            }
        }
    }
    
    func commentPost() {
        if !enterCommentField.isFirstResponder() {
            enterCommentField.becomeFirstResponder()
        }
    }
}


extension NewsDetailsViewController {
    internal class NewsDataSource: TableViewDataSource {
        
        var actionConsumer: NewsActionConsumer? {
            return parentViewController as? NewsActionConsumer
        }
        
        private let cellFactory = FeedItemNewsCellModelFactory()
        private var items: [[TableViewCellModel]] =  [[],[]]
        
        func setPost(post: Post) {
            let controller = self.parentViewController as! NewsDetailsViewController
            items = cellFactory.modelsForPost(post, isFeautered: controller.isFeautered, actionConsumer: self.actionConsumer)
        }
        
        override func configureTable(tableView: UITableView) {
            tableView.tableFooterView = UIView(frame: CGRectZero)
            super.configureTable(tableView)
        }
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return items.count
        }
        
        @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items[section].count
        }
        
        @objc override func tableView(tableView: UITableView, reuseIdentifierForIndexPath indexPath: NSIndexPath) -> String {
            return cellFactory.cellReuseIdForModel(self.tableView(tableView, modelForIndexPath: indexPath))
        }
        
        override func tableView(tableView: UITableView, modelForIndexPath indexPath: NSIndexPath) -> TableViewCellModel {
            return items[indexPath.section][indexPath.row]
        }
        
        override func nibCellsId() -> [String] {
            return cellFactory.postCellsReuseId()
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let controller = self.parentViewController as! NewsDetailsViewController
            if controller.post?.links?.isEmpty == false || controller.post?.attachments?.isEmpty == false {
                let moreInformationViewController = MoreInformationViewController(links: controller.post?.links,
                    attachments: controller.post?.attachments)
                controller.navigationController?.pushViewController(moreInformationViewController, animated: true)
            }
        }
    }
}