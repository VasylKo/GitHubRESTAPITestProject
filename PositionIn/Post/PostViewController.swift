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


protocol PostActionConsumer: class {
    func showProfileScreen(userId: CRUDObjectId)
    func likePost()
}

protocol PostActionProvider {
    var actionConsumer: PostActionConsumer? { get set }
}

final class PostViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configureTable(tableView)
        self.enterCommentField.delegate = self;
        self.getPost()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeOnKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotification()
    }
    
    private func getPost(completion: () -> Void = {}) {
        if let objectId = objectId {
            api().getPost(objectId).onSuccess { [weak self] post in
                self?.post = post
                self?.dataSource.setPost(post)
                self?.tableView.reloadData()
                self?.tableView.layoutIfNeeded();
                
                completion()
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
    
    private var post: Post?
    
    private lazy var dataSource: PostDataSource = { [unowned self] in
        let dataSource = PostDataSource()
        dataSource.parentViewController = self
        return dataSource
        }()


    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var enterCommentField: UITextField!
    @IBOutlet weak var enterCommentFieldBottomSpaceConstraint: NSLayoutConstraint!
    var objectId: CRUDObjectId?
}

extension PostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField.text.characters.count > 0) {
            var comment = Comment()
            comment.text = textField.text
            if let tempPost = post {
                
                api().createPostComment(tempPost.objectId, object: comment).onSuccess {[weak self] comment in
                    self?.getPost(completion: {
                        
                        //TODO: need scroll to bottom if tableView
                        
                    })
                    textField.text = nil
                }
            }
        }
        
        return true;
    }
}

extension PostViewController: PostActionConsumer {
    func showProfileScreen(userId: CRUDObjectId) {
        let profileController = Storyboards.Main.instantiateUserProfileViewController()
        profileController.objectId = userId
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    func likePost() {
        if let tempPost = post {
            if (tempPost.isLiked) {
                api().unlikePost(tempPost.objectId).onSuccess{[weak self] in
                    self?.getPost()
                }
            }
            else {
                api().likePost(tempPost.objectId).onSuccess{[weak self] in
                    self?.getPost()
                }
            }
        }
    }
}

extension PostViewController {
    internal class PostDataSource: TableViewDataSource {
        
        var actionConsumer: PostActionConsumer? {
            return parentViewController as? PostActionConsumer
        }
        
        private let cellFactory = PostCellModelFactory()
        private var items: [[TableViewCellModel]] =  [[],[]]
        
        func setPost(post: Post) {
            items = cellFactory.modelsForPost(post, actionConsumer: self.actionConsumer)
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
            if  let actionConsumer = parentViewController as? PostActionConsumer,
                let model = self.tableView(tableView, modelForIndexPath: indexPath) as? PostInfoModel,
                let userId = model.userId {
                    actionConsumer.showProfileScreen(userId)
            }
        }
    }
}