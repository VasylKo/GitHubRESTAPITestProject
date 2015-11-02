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

protocol ChatControllerDelegate: class  {
    func didUpdateMessages()
}

final class ChatController: NSObject {
    
    init(conversation: Conversation) {
        chatClient = chat()
        self.conversation = conversation
        super.init()
        prepareCache()
        ConversationManager.sharedInstance().didEnterConversation(conversation)
        fetchMetadata()
    }
    
    func closeSession() {
        chatClient.removeMessageListener(self)
        ConversationManager.sharedInstance().didLeaveConversation(conversation)
    }
    
    deinit {
        queryTimer?.invalidate()
        closeSession()
    }
    
    func sendMessage(msg: JSQMessageData) {
        messages.append(msg)
        if msg.isMediaMessage() {
            //TODO: send media
        } else {
            ConversationManager.sharedInstance().sendText(msg.text!(), conversation: conversation)
        }
    }
    
    func messagesCount() -> Int {
        return (messages).count
    }
    
    func messageAtIndex(index: Int) -> JSQMessageData {
        return messages[index] ?? JSQMessage()
    }
    
    func avatarForSender(senderId: CRUDObjectId) -> JSQMessageAvatarImageDataSource {
        if let dataSource = avatarDataSourceForUser(senderId) {
            return dataSource
        } else {
            loadUserInfo(senderId)
            return defaultAvatar
        }
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
    
    private func fetchMetadata() {
        loadUserInfo(ConversationManager.sharedInstance().getSenderId(conversation))
        if conversation.isGroupChat == false {
            loadUserInfo(conversation.roomId)
        }
        loadConversationHistory(conversation)
        chatClient.addMessageListener(self)
    }
    
    private func loadUserInfo(userId: CRUDObjectId) {
        synced(self) {
            self.queryTimer?.invalidate()
            self.queryTimer = NSTimer.scheduledTimerWithTimeInterval(self.queryDelay, target: self, selector: "executePendingQuery", userInfo: nil, repeats: false)
            self.query.insert(userId)
        }
    }
    
    func executePendingQuery() {
        var userIds: [CRUDObjectId] = []
        synced(self) {
            userIds = self.query.filter { self.occupants.contains($0) == false }
            self.occupants.unionInPlace(self.query)
            self.query =  Set()
        }
        if userIds.isEmpty {
            return
        }
        let fetchAvatar: (NSURL) -> Future<UIImage, NSError>  = { url in
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
        Log.info?.message("Fetching info for users \(userIds)")
        api().getUsers(userIds).onSuccess { [weak self] response in
            if let strongSelf = self {
                let usersWithAvatars = response.items.filter { $0.avatar != nil }
                let avatarDownloads = usersWithAvatars.map { info in
                    fetchAvatar(info.avatar!).onSuccess { [weak strongSelf] image in
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
        messages = ConversationManager.sharedInstance().getHistory(conversation).map { m in
                return JSQMessage(senderId: m.from, senderDisplayName: self.displayNameForUser(m.from), date: m.date, text: m.text)
        }
    }
    
    private func appendMessage(message: JSQMessage) {
        conversation.resetUnreadCount()
        Queue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.messages = strongSelf.messages + [message]
                strongSelf.delegate?.didUpdateMessages()
            }
        }
    }
    
    weak var delegate: ChatControllerDelegate?
    
    private var messages: [JSQMessageData] = []
    
    private var avatarsCache: [CRUDObjectId: JSQMessageAvatarImageDataSource] = [:]
    
    private var participantsInfo: [UserInfo] = []
    private unowned var chatClient: XMPPClient
    private let conversation: Conversation
    
    private var queryTimer: NSTimer?
    private let queryDelay: NSTimeInterval = 0.3
    private var query: Set<CRUDObjectId> = Set()
    private var occupants: Set<CRUDObjectId> = Set()
    
    static private var cacheOnceToken = dispatch_once_t()
    static private let avatarCacheFormatName = "ChatAvatars"

}

extension ChatController: XMPPMessageListener {
    @objc func didReceiveTextMessage(text: String, from: String, to: String, date: NSDate) {
        if conversation.roomId == from {
            let message = JSQMessage(senderId: from, senderDisplayName: displayNameForUser(from), date: date, text: text)
            appendMessage(message)
        }
    }
    
    @objc func didReceiveGroupTextMessage(roomId: String, text: String, from: String, to: String, date: NSDate) {
        if conversation.roomId == roomId && from != ConversationManager.sharedInstance().getSenderId(conversation) {
            let message = JSQMessage(senderId: from, senderDisplayName: displayNameForUser(from), date: date, text: text)
            appendMessage(message)
        }
    }
}