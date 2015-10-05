//
//  ConversationController.swift
//  PositionIn
//
//  Created by Alexandr Goncharov on 14/09/15.
//  Copyright (c) 2015 Soluna Labs. All rights reserved.
//

import Messaging
import JSQMessagesViewController
import CleanroomLogger
import PosInCore
import Haneke
import BrightFutures

protocol ChatControllerDelegate {
    func didUpdateMessages()
}

final class ChatController: NSObject {
    
    init(conversation: Conversation) {
        chatClient = chat()
        self.conversation = conversation
        super.init()
        prepareCache()
        loadInfoForUsers(conversation.participants)
        chatClient.addMessageListener(self)
    }
    
    deinit {
        //TODO: fix retain cycle
        chatClient.removeMessageListener(self)
    }
    
    func sendMessage(msg: JSQMessageData) {
        messages.append(msg)
        if msg.isMediaMessage() {
            //TODO: send media
        } else {
            chatClient.sendTextMessage(msg.text!(), to: conversation.roomId)
        }
    }
    
    func messagesCount() -> Int {
        return count(messages)
    }
    
    func messageAtIndex(index: Int) -> JSQMessageData {
        return messages[index] ?? JSQMessage()
    }
    
    func avatarForSender(senderId: CRUDObjectId) -> JSQMessageAvatarImageDataSource {
        return  avatarDataSourceForUser(senderId) ??  defaultAvatar
    }
    
    lazy private var defaultAvatar: JSQMessagesAvatarImage = {
        return JSQMessagesAvatarImageFactory.avatarImageWithPlaceholder(UIImage(named: "AvatarPlaceholder")!, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    }()
    
    private func prepareCache() {
        dispatch_once(&ChatController.cacheOnceToken) {
            let cache = Shared.imageCache
            let size = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height: kJSQMessagesCollectionViewAvatarSizeDefault)
            let format = Format<UIImage>(name: ChatController.avatarCacheFormatName, diskCapacity: 10 * 1024 * 1024) { image in
                let resizer = ImageResizer(size:size,
                    scaleMode: ImageResizer.ScaleMode.Fill,
                    allowUpscaling: true,
                    compressionQuality: HanekeGlobals.UIKit.DefaultFormat.CompressionQuality)
                return resizer.resizeImage(image)
            }
            cache.addFormat(format)
        }
    }
    
    private func loadInfoForUsers(userIds: [CRUDObjectId]) {
        func avatarDownloadFuture(url: NSURL) -> Future<UIImage, NSError> {
            let promise = Promise<UIImage, NSError>()
            Shared.imageCache.fetch(URL: url, formatName: ChatController.avatarCacheFormatName, failure: { (e) -> () in
                //TODO: add default error
                let error =  e ??  NSError()
                promise.failure(error)
            }, success: {image in
                promise.success(image)
            })
            return promise.future
        }
        api().getUsers(userIds).onSuccess {[weak self] response in
            Log.debug?.value(response.items)
            if let strongSelf = self {
                strongSelf.participantsInfo = response.items
                strongSelf.loadConversationHistory(strongSelf.conversation)
                strongSelf.delegate?.didUpdateMessages()
                let usersWithAvatars = response.items.filter { $0.avatar != nil }
                let avatarDownloads = usersWithAvatars.map { info in
                    avatarDownloadFuture(info.avatar!).onSuccess { [weak strongSelf] image in
                        strongSelf?.addAvatar(image, user: info.objectId)
                    }
                }
                sequence(avatarDownloads).onComplete { [weak strongSelf] _ in
                    strongSelf?.delegate?.didUpdateMessages()
                }
            }
            
        }
    }
        
    private func addAvatar(image: UIImage, user: CRUDObjectId) {
        let dataSource = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        synced(avatarsCache) {
            self.avatarsCache[user] = dataSource
        }
    }
    
    private func avatarDataSourceForUser(user: CRUDObjectId) -> JSQMessageAvatarImageDataSource? {
        var dataSource: JSQMessageAvatarImageDataSource?
        synced(avatarsCache) {
            dataSource = self.avatarsCache[user]
        }
        return dataSource
    }
    
    private func displayNameForUser(user: CRUDObjectId) -> String {
        if  let info = (participantsInfo.filter { $0.objectId == user }).first,
            let displayName = info.title {
                return displayName
        }
        let defaultName = NSLocalizedString("Unnamed", comment: "Chat: Unknown user name")
        return defaultName
    }
    
    private func loadConversationHistory(conversation: Conversation) {
        //TODO: load history
//        messages = [
//            JSQMessage(senderId: conversation.currentUserId, displayName: displayNameForUser(conversation.currentUserId), text: "Hi!"),
//            JSQMessage(senderId: conversation.participants.first!, displayName: displayNameForUser(conversation.participants.first!), text: "Please give me a call."),
//            JSQMessage(senderId: conversation.participants.first!, displayName: displayNameForUser(conversation.participants.first!), text: "Another."),
//            JSQMessage(senderId: conversation.currentUserId, displayName: displayNameForUser(conversation.currentUserId), text: "Me 1"),
//            JSQMessage(senderId: conversation.currentUserId, displayName: displayNameForUser(conversation.currentUserId), text: "Me 2"),
//        ]
    }
    
    
    var delegate: ChatControllerDelegate?
    
    private var messages: [JSQMessageData] = []
    
    private var avatarsCache: [CRUDObjectId: JSQMessageAvatarImageDataSource] = [:]
    
    private var participantsInfo: [UserInfo] = []
    private unowned var chatClient: XMPPClient
    private let conversation: Conversation
    
    static private var cacheOnceToken = dispatch_once_t()
    static private let avatarCacheFormatName = "ChatAvatars"

}

extension ChatController: XMPPMessageListener {
    @objc func didReceiveTextMessage(text: String, from: String, to: String, date: NSDate) {
        //TODO: fix logic
        if let _  = (participantsInfo.filter { $0.objectId == from }).first {
            let message = JSQMessage(senderId: from, senderDisplayName: displayNameForUser(from), date: date, text: text)
            Queue.main.async { [weak self] in
                if let strongSelf = self {
                    strongSelf.messages = strongSelf.messages + [message]
                    strongSelf.delegate?.didUpdateMessages()
                }
            }
        }
    }
}