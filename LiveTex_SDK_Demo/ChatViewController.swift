//
//  ChatViewController.swift
//  LiveTex SDK
//
//  Created by Эмиль Абдуселимов on 12.08.16.
//  Copyright © 2016 LiveTex. All rights reserved.
//

import UIKit
import LivetexCore
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController,
                          LCCoreServiceDelegate,
                          UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate {

    private var messages: [JSQMessage] = []

    private let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: .jsq_messageBubbleLightGray())
    private let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: .jsq_messageBubbleBlue())

    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = ""
        senderDisplayName = ""
        navigationController?.isNavigationBarHidden = false
        LivetexCoreManager.defaultManager.coreService.delegate = self

        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        collectionView?.collectionViewLayout.springinessEnabled = false
        automaticallyScrollsToMostRecentMessage = true

        receiveData()
    }
    
    func receiveData() {
        /* Запрашиваем текущее состояние диалога */
        LivetexCoreManager.defaultManager.coreService.state { state, error in
            guard let state = state else {
                print(error)
                return
            }

            self.update(state)
        }
        
        /* Запрашиваем историю переписки */
        LivetexCoreManager.defaultManager.coreService.messageHistory(20, offset: 0) { messageList, error in
            if let err = error {
                print(err)
                return
            }
            
            let toConfirmList = messageList?.filter { $0.confirm == false && ($0.attributes.text.senderIsSet || $0.attributes.file.senderIsSet) }

            toConfirmList?.forEach { message in
                /* Отправляем подтверждение о получении сообщения */
                LivetexCoreManager.defaultManager.coreService.confirmMessage(withID: message.messageId) { success, error in
                    if let err = error {
                        print(err)
                    } else {
                        message.confirm = true
                    }
                }
             }

            let convertedMessages = messageList?.reversed().map { self.convertMessage($0) } ?? []
            self.messages.append(contentsOf: convertedMessages)
            self.finishReceivingMessage()
        }
    }
    
    func reloadDestinationIfNeeded(_ response: LCSendMessageResponse) {
        if !response.destinationIsSet {
            /* Получаем список назначений */
            LivetexCoreManager.defaultManager.coreService.destinations { destinations, error in
                if let err = error {
                    print(err)
                    return
                }
                
                /* Указываем адресат обращения */
                LivetexCoreManager.defaultManager.coreService.setDestination(destinations!.first!, attributes: LCDialogAttributes(visible: [:], hidden: [:]), options: []) { success, error in
                    if let err = error {
                        print(err)
                    }
                }
            }
        }
    }
    
    func convertMessage(_ message: LCMessage) -> JSQMessage {
        var timeInterval: TimeInterval = 0
        if message.attributes.textIsSet {
            timeInterval = (message.attributes.text.created as NSString).doubleValue
            return JSQMessage(senderId: message.attributes.text.senderIsSet ? message.attributes.text.sender : self.senderId, senderDisplayName: "", date: Date(timeIntervalSince1970:timeInterval / 1000), text: message.attributes.text.text)
        } else {
            timeInterval = (message.attributes.file.created as NSString).doubleValue
            let fileURL: String = message.attributes.file.url.removingPercentEncoding!
            let pathExtention = (fileURL as NSString).pathExtension
            let paths: [String] = ["png", "jpg", "jpeg", "gif"]
            if paths.contains(pathExtention) {
                let media = JSQPhotoMediaItem(maskAsOutgoing: !message.attributes.file.senderIsSet)
                let url = URL(string: message.attributes.file.url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
                URLSession.shared.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                    if let err = error {
                        print(err)
                    } else {
                        DispatchQueue.main.async {
                            media?.image = UIImage(data: data!)
                            self.collectionView.collectionViewLayout.invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext())
                            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                        }
                    }
                }).resume()
                
                return JSQMessage(senderId: message.attributes.file.senderIsSet ? message.attributes.file.sender : self.senderId, senderDisplayName: "", date: Date(timeIntervalSince1970:timeInterval / 1000), media: media)
            } else {
                return JSQMessage(senderId: message.attributes.file.senderIsSet ? message.attributes.file.sender : self.senderId, senderDisplayName: "", date: Date(timeIntervalSince1970:timeInterval / 1000), text: message.attributes.file.url)
            }
        }
    }
    
    // MARK: - UIImagePickerController
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = info[.editedImage] as? UIImage, let imageData = image.pngData() else {
            return
        }

        /* Отправляем файловое сообщение */
        LivetexCoreManager.defaultManager.coreService.sendFileMessage(imageData) { response, error in
            if let err = error {
                print(err)
            } else {
                /* Переназначаем адресат обращения в случае необходимости */
                self.reloadDestinationIfNeeded(response!)
                let message = LCMessage(messageId: response!.messageId, attributes: response!.attributes, confirm: true)
                self.messages.append(self.convertMessage(message))
                self.finishSendingMessage()
            }
        }
        
        picker.dismiss(animated: true)
    }
    
    // MARK: - LCCoreServiceDelegate
    
    func update(_ dialogState: LCDialogState) {
        if dialogState.employee != nil {
            navigationItem.title = "\(dialogState.employee!.firstname) \(dialogState.employee!.lastname)"
        } else {
            navigationItem.title = "Оператор"
        }
    }
    
    func confirmMessage(_ messageId: String) {
        print(#function)
    }
    
    func receiveTextMessage(_ message: LCMessage) {
        /* Отправляем подтверждение о получении сообщения */
        LivetexCoreManager.defaultManager.coreService.confirmMessage(withID: message.messageId) { (success: Bool, error: Error?) in
            if let err = error {
                print(err)
            }
        }
        
        messages.append(convertMessage(message))
        finishReceivingMessage(animated: true)
    }
    
    func receiveFileMessage(_ message: LCMessage) {
        messages.append(convertMessage(message))
        finishReceivingMessage(animated: true)
    }
    
    func selectDestination(_ destinations: [LCDestination]) {
        /* Указываем адресат обращения */
        LivetexCoreManager.defaultManager.coreService.setDestination(destinations.first!,
                                                                     attributes: LCDialogAttributes(visible: [:],
                                                                                                    hidden: [:]),
                                                                     options: []) { success, error in
            if let err = error {
                print(err)
            }
        }
    }
    
    // MARK: - JSQMessagesViewController method overrides
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        /* Отправляем текстовое сообщение */
        LivetexCoreManager.defaultManager.coreService.sendTextMessage(text) { response, error in
            if let err = error {
                print(err)
            } else {
                /* Переназначаем адресат обращения в случае необходимости */
                self.reloadDestinationIfNeeded(response!)
                let message = LCMessage(messageId: response!.messageId, attributes: response!.attributes, confirm: false)
                self.messages.append(self.convertMessage(message))
                self.finishSendingMessage(animated: true)
            }
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        inputToolbar.contentView?.textView?.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    // MARK: - JSQMessages CollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let image = messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
        return image ?? JSQMessagesBubbleImage(messageBubble: UIImage(), highlightedImage: UIImage())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if (indexPath.item % 3 == 0) {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if !message.isMediaMessage {
            let tintColor: UIColor = message.senderId == senderId ? .white : .black
            cell.textView.textColor = tintColor
            cell.textView.linkTextAttributes = [.foregroundColor: tintColor]
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        let currentMessage = messages[indexPath.item]
        if currentMessage.senderId == senderId {
            return 0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
}
