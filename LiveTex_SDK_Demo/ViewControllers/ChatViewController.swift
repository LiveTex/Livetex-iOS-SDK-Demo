//
//  ChatViewController.swift
//  LiveTex SDK
//
//  Created by Эмиль Абдуселимов on 12.08.16.
//  Copyright © 2016 LiveTex. All rights reserved.
//

import UIKit
import LivetexCore
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController,
                          InputBarAccessoryViewDelegate,
                          UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate {

    private var messages: [MessageType] = []
    private let sender = Sender(senderId: "", displayName: "")
    private var employee = Sender(senderId: "1", displayName: "Operator")
    private lazy var reachability = Reachability.forInternetConnection()

    private lazy var attachmentButtonItem: InputBarButtonItem = {
        return InputBarButtonItem()
            .configure {
                $0.image = UIImage(named: "clip")?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 36), animated: false)
                $0.title = nil
            }.onTouchUpInside { _ in
                self.showImagePickerController()
            }
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = false
        Livetex.shared.coreService.delegate = self

        configureInputBar()
        configureCollectionView()

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)),
                                               name: .reachabilityChanged,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationwillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)

        reachability?.startNotifier()
        receiveData()
    }

    // MARK: - Notifications

    @objc private func applicationwillEnterForeground() {
        receiveMessages()
    }

    // MARK: - Configuration

    private func configureCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.zero)

        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }

    private func configureInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .blue
        messageInputBar.inputTextView.placeholder = "Message..."
        messageInputBar.setLeftStackViewWidthConstant(to: 30, animated: false)
        messageInputBar.setStackViewItems([attachmentButtonItem], forStack: .left, animated: false)
    }

    // MARK: - Receive Data
    
    func receiveData() {
        receiveState()
        receiveMessages()
    }

    private func receiveState() {
        /* Запрашиваем текущее состояние диалога */
        Livetex.shared.coreService.state { state, error in
            guard let state = state else {
                return
            }

            self.update(state)
        }
    }

    private func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }

    private func receiveMessages() {
        /* Запрашиваем историю переписки */
        Livetex.shared.coreService.messageHistory(20, offset: 0) { messageList, error in
            if let err = error {
                print(err)
                return
            }

            let toConfirmList = messageList?.filter { $0.confirm == false && ($0.attributes.text.senderIsSet || $0.attributes.file.senderIsSet) }

            toConfirmList?.forEach { message in
                /* Отправляем подтверждение о получении сообщения */
                Livetex.shared.coreService.confirmMessage(withID: message.messageId) { success, error in
                    if let err = error {
                        print(err)
                    } else {
                        message.confirm = true
                    }
                }
             }

            let convertedMessages = messageList?.reversed().map { self.convertMessage($0) } ?? []
            convertedMessages.forEach { self.insertMessage($0) }
        }
    }
    
    func reloadDestinationIfNeeded(_ response: LCSendMessageResponse) {
        if !response.destinationIsSet {
            /* Получаем список назначений */
            Livetex.shared.coreService.destinations { destinations, error in
                guard let destination = destinations?.first else {
                    return
                }

                /* Указываем адресат обращения */
                Livetex.shared.coreService.setDestination(destination,
                                                          attributes: LCDialogAttributes(visible: [:], hidden: [:]),
                                                          options: []) { success, error in
                    if let err = error {
                        print(err)
                    }
                }
            }
        }
    }
    
    func convertMessage(_ message: LCMessage) -> MessageType {
        let numberFormatter = NumberFormatter()
        if message.attributes.textIsSet {
            let timeInterval: TimeInterval = numberFormatter.number(from: message.attributes.text.created)?.doubleValue ?? 0
            let newMessage = Message(sender: message.attributes.text.senderIsSet ? employee : sender,
                                     messageId: message.messageId,
                                     sentDate: Date(timeIntervalSince1970: timeInterval / 1000),
                                     kind: .text(message.attributes.text.text))
            return newMessage
        } else {
            let timeInterval: TimeInterval = numberFormatter.number(from: message.attributes.file.created)?.doubleValue ?? 0
            let mediaItem = MediaMessage(url: nil)
            let newMessage = Message(sender: message.attributes.file.senderIsSet ? employee : sender,
                                  messageId: message.messageId,
                                  sentDate: Date(timeIntervalSince1970: timeInterval / 1000),
                                  kind: .photo(mediaItem))
            return newMessage
        }
    }

    // MARK: - Reachability

    @objc private func reachabilityChanged(_ reachability: Reachability) {
        let status: NetworkStatus = reachability.currentReachabilityStatus()
        if status == .NotReachable {
            let alertController = UIAlertController(title: nil,
                                                    message: "Интернет соединение потеряно, дождитесь когда система восстановит соединение",
                                                    preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(cancel)
            present(alertController, animated: true)
        } else {
            
        }
    }
    
    // MARK: - UIImagePickerController
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = info[.originalImage] as? UIImage, let imageData = image.pngData() else {
            return
        }

        /* Отправляем файловое сообщение */
        Livetex.shared.coreService.sendFileMessage(imageData) { response, error in
            guard let result = response else {
                return
            }

            /* Переназначаем адресат обращения в случае необходимости */
            self.reloadDestinationIfNeeded(result)
            let message = LCMessage(messageId: result.messageId, attributes: result.attributes, confirm: true)
            let timeInterval: TimeInterval = NumberFormatter().number(from: message.attributes.file.created)?.doubleValue ?? 0
            let mediaItem = MediaMessage(image: image)
            let newMessage = Message(sender: self.sender,
                                     messageId: message.messageId,
                                     sentDate: Date(timeIntervalSince1970: timeInterval / 1000),
                                     kind: .photo(mediaItem))
            self.insertMessage(newMessage)
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
        
        picker.dismiss(animated: true)
    }

    // MARK: - Helpers

    func insertMessage(_ message: MessageType) {
        messages.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            self?.messagesCollectionView.scrollToBottom(animated: true)
        })
    }

    // MARK: - InputBarAccessoryViewDelegate

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        /* Отправляем текстовое сообщение */

        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        Livetex.shared.coreService.sendTextMessage(text) { response, error in
            if let err = error {
                print(err)
            } else {
                /* Переназначаем адресат обращения в случае необходимости */
                self.reloadDestinationIfNeeded(response!)
                let message = LCMessage(messageId: response!.messageId, attributes: response!.attributes, confirm: false)
                let newMessage = self.convertMessage(message)
                self.insertMessage(newMessage)
            }

            self.messageInputBar.inputTextView.placeholder = "Message..."
            self.messageInputBar.sendButton.stopAnimating()
        }
    }
}

extension ChatViewController: LCCoreServiceDelegate {

    // MARK: - LCCoreServiceDelegate

    func update(_ dialogState: LCDialogState) {
        if let employee = dialogState.employee {
            navigationItem.title = "\(employee.firstname) \(employee.lastname)"
        } else {
            navigationItem.title = "Оператор"
        }
    }

    func confirmMessage(_ messageId: String) {
        print(#function)
    }

    func receiveTextMessage(_ message: LCMessage) {
        /* Отправляем подтверждение о получении сообщения */
        Livetex.shared.coreService.confirmMessage(withID: message.messageId) { success, error in
            if let err = error {
                print(err)
            }
        }

        let newMessage = convertMessage(message)
        insertMessage(newMessage)
    }

    func receiveFileMessage(_ message: LCMessage) {
        messages.append(convertMessage(message))
    }

    func selectDestination(_ destinations: [LCDestination]) {
        /* Указываем адресат обращения */
        let attributes = LCDialogAttributes(visible: [:], hidden: [:])
        Livetex.shared.coreService.setDestination(destinations.first!,
                                                                     attributes: attributes,
                                                                     options: []) { success, error in
            if let err = error {
                print(err)
            }
        }
    }

}

extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        return sender
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                                  attributes: [.font: UIFont.boldSystemFont(ofSize: 10),
                                               .foregroundColor: UIColor.darkGray])
    }

}

extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {

}
