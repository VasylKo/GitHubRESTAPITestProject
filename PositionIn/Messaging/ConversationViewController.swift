//
//  ConversationViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import JSQMessagesViewController

final class ConversationViewController: JSQMessagesViewController {
    class func conversationController() -> ConversationViewController {
        let instance = ConversationViewController()
        instance.senderId = CRUDObjectInvalidId
        instance.senderDisplayName = "Display name"
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Chat", comment: "Chat: Default chat title")
    }
    
    //MARK: - Overrides -
    /**
    *  This method is called when the user taps the send button on the inputToolbar
    *  after composing a message with the specified data.
    *
    *  @param button            The send button that was pressed by the user.
    *  @param text              The message text.
    *  @param senderId          The message sender identifier.
    *  @param senderDisplayName The message sender display name.
    *  @param date              The message date.
    */
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessageAnimated(true)
        
    }
    
    /**
    *  This method is called when the user taps the accessory button on the `inputToolbar`.
    *
    *  @param sender The accessory button that was pressed by the user.
    */
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
    
    //MARK: - JSQMessages CollectionView DataSource -
    /*
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
    }
    */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as?  JSQMessagesCollectionViewCell {
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    //MARK: - UICollectionView DataSource -


}
