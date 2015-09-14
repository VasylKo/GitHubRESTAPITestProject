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