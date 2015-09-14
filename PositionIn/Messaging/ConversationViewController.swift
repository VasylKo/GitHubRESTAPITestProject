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
    class func conversationController(interlocutor: CRUDObjectId = CRUDObjectInvalidId) -> ConversationViewController {
        let instance = ConversationViewController()
        instance.senderId = api().currentUserId()
        instance.senderDisplayName = NSLocalizedString("Me", comment: "Chat: Current user name")
        instance.chatController = ChatController(interlocutor: interlocutor)
        return instance
    }
    
    private var chatController: ChatController!
    
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
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        chatController.sendMessage(message)
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

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return chatController.messageAtIndex(indexPath.item)
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.collectionView(collectionView, messageDataForItemAtIndexPath: indexPath)
        return senderId == message.senderId() ? outgoingBubbleImageData : incomingBubbleImageData
    }
    

    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.collectionView(collectionView, messageDataForItemAtIndexPath: indexPath)
        return chatController.avatarForSender(message.senderId())
    }
    
    //MARK: - UICollectionView DataSource -
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatController.messagesCount()
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as?  JSQMessagesCollectionViewCell {
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    //MARK: - Helpers -
    
    lazy private var outgoingBubbleImageData: JSQMessagesBubbleImage = {
       let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }()
    
    lazy private var incomingBubbleImageData: JSQMessagesBubbleImage = {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }()
    



}
