//
//  ConversationViewController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import CleanroomLogger

final class ConversationViewController: JSQMessagesViewController {
    class func conversationController(conversation: Conversation) -> ConversationViewController {
        let instance = ConversationViewController()
        instance.senderDisplayName = NSLocalizedString("Me", comment: "Chat: Current user name")
        instance.senderId = ConversationManager.sharedInstance().getSenderId(conversation)
        instance.chatController = ChatController(conversation: conversation)
        instance.chatController.delegate = instance
        instance.title = conversation.name
        return instance
    }
    
    private var chatController: ChatController!
    
    deinit {
        chatController?.closeSession()
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
        let sendCompletion: () -> () = { [weak self] in
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self?.finishSendingMessageAnimated(true)
        }
        let sheet = UIAlertController(
            title: NSLocalizedString("Media messages", comment: "Chat Actions: Title"),
            message: nil,
            preferredStyle: .ActionSheet)
        sheet.addAction(UIAlertAction(
            title: NSLocalizedString("Send location", comment: "Chat Actions: Location"),
            style: .Default,
            handler: { [weak self] action in
                if let strongSelf = self {
                    weak var collectionView = strongSelf.collectionView
                    self?.sendLocationMediaMessage {
                        collectionView?.reloadData()
                    }
                    sendCompletion()
                }
        }))
        sheet.addAction(UIAlertAction(
            title: NSLocalizedString("Send image", comment: "Chat Actions: Image"),
            style: .Default,
            handler: { [weak self] action in
                self?.sendPhotoMessage()
                sendCompletion()
            }))
        sheet.addAction(UIAlertAction(
            title: NSLocalizedString("Send video", comment: "Chat Actions: Video"),
            style: .Default,
            handler: { [weak self] action in
                self?.sendVideoMessage()
                sendCompletion()
            }))
        
        sheet.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Chat Actions: Cancel"),
            style: .Cancel,
            handler: nil))
        presentViewController(sheet, animated: true, completion: nil)
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        /**
        *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
        *  The other label text delegate methods should follow a similar pattern.
        *
        *  Show a timestamp for every 3rd message
        */
        if indexPath.item % 3 == 0 {
            let message = self.collectionView(collectionView, messageDataForItemAtIndexPath: indexPath)
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date())
        }
        return nil
    }
    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
//        let message = self.collectionView(collectionView, messageDataForItemAtIndexPath: indexPath)
//        if message.senderId() == senderId {
//            return nil
//        }
//        if indexPath.item - 1 > 0 {
//            let previousIndexPath = NSIndexPath(forItem: indexPath.item - 1, inSection: indexPath.section)
//            let previousMessage = self.collectionView(collectionView, messageDataForItemAtIndexPath: previousIndexPath)
//            if previousMessage.senderId() == message.senderId() {
//                return nil
//            }
//        }
//        return NSAttributedString(string: message.senderDisplayName())
//    }
    
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
    
    //MARK: - JSQMessages collection view flow layout delegate -
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return  (indexPath.item % 3 == 0) ? kJSQMessagesCollectionViewCellLabelHeightDefault : 0.0
    }
    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
//        if let _ = self.collectionView(collectionView, attributedTextForMessageBubbleTopLabelAtIndexPath: indexPath) {
//            return kJSQMessagesCollectionViewCellLabelHeightDefault
//        }
//        return 0.0
//    }
    
    //MARK: - Helpers -
    
    lazy private var outgoingBubbleImageData: JSQMessagesBubbleImage = {
       let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }()
    
    lazy private var incomingBubbleImageData: JSQMessagesBubbleImage = {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }()
    
}

//MARK: - Media data -

extension ConversationViewController {

    func sendLocationMediaMessage(completion: JSQLocationMediaItemCompletionBlock) {
        locationController().getCurrentCoordinate().onSuccess { [weak self] coordinate in
            if let strongSelf = self {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let locationItem = JSQLocationMediaItem()
                locationItem.setLocation(location, withCompletionHandler: completion)
                let locationMessage = JSQMessage(senderId: strongSelf.senderId, senderDisplayName: strongSelf.senderDisplayName, date: NSDate(), media: locationItem)
                strongSelf.chatController.sendMessage(locationMessage)
            }
        }.onFailure { error in
            Log.error?.value(error)
        }
    }
    
    func sendVideoMessage() {
        let videoURL: NSURL = NSURL(string: "file://")!
        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        let videoMessage = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: videoItem)
        chatController.sendMessage(videoMessage)
    }
    
    func sendPhotoMessage() {
        let photoItem = JSQPhotoMediaItem(image: UIImage(named:"MenuLogo")!)
        let photoMessage = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: photoItem)
        chatController.sendMessage(photoMessage)
    }
}

//MARK: - Chat Controller delegate -

extension ConversationViewController: ChatControllerDelegate {
    func didUpdateMessages() {
        if chatController.messagesCount() > 0 {
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        }
        scrollToBottomAnimated(true)
        finishReceivingMessage()
    }
}

//MARK: - Navigation  -

extension UIViewController {
    func showChatViewController(userId: CRUDObjectId) {
        api().getUsers([userId]).onSuccess { [weak self] response in
            if let info = response.items.first {
                self?.showChatViewController(Conversation(user: info))
            }
            
        }
    }
    
    func showChatViewController(conversation: Conversation) {
        api().isUserAuthorized().onSuccess { [weak self] _ in
            let chatController = ConversationViewController.conversationController(conversation)
            self?.navigationController?.pushViewController(chatController, animated: true)
        }
    }
}

