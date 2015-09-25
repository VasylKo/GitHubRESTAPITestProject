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

final class ChatController {
    
    init(conversation: Conversation) {
        chatClient = chat()
        self.conversation = conversation
        prepareCache()
        loadInfoForUsers(conversation.participants)
        messages = [
            JSQMessage(senderId: conversation.currentUserId, displayName: "John Doe", text: "Hi!"),
            JSQMessage(senderId: "123", displayName: "John Doe", text: "Please give me a call."),            
        ]
    }
    
    func sendMessage(msg: JSQMessageData) {
        messages.append(msg)
        chatClient.sendTestMessage()
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
                self?.participantsInfo = response.items
                let usersWithAvatars = response.items.filter { $0.avatar != nil }
                usersWithAvatars.map { info in
                    avatarDownloadFuture(info.avatar!).onSuccess { [weak strongSelf] image in
                        strongSelf?.addAvatar(image, user: info.objectId)
                    }
                }
            }
            
        }
    }
        
    func addAvatar(image: UIImage, user: CRUDObjectId) {
        let dataSource = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        synced(avatarsCache) {
            self.avatarsCache[user] = dataSource
        }
    }
    
    func avatarDataSourceForUser(user: CRUDObjectId) -> JSQMessageAvatarImageDataSource? {
        var dataSource: JSQMessageAvatarImageDataSource?
        synced(avatarsCache) {
            dataSource = self.avatarsCache[user]
        }
        return dataSource
    }
    
    private var messages: [JSQMessageData] = []
    
    private var avatarsCache: [CRUDObjectId: JSQMessageAvatarImageDataSource] = [:]
    
    private var participantsInfo: [UserInfo] = []
    private unowned var chatClient: XMPPClient
    private let conversation: Conversation
    
    static private var cacheOnceToken = dispatch_once_t()
    static private let avatarCacheFormatName = "ChatAvatars"

}

