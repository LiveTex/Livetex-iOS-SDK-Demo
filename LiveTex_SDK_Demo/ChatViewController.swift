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
    var messages = [JSQMessage]()
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = ""
        self.senderDisplayName = ""
        self.navigationController?.navigationBarHidden = false
        LivetexCoreManager.defaultManager.coreService.delegate = self
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        collectionView?.collectionViewLayout.springinessEnabled = false
        automaticallyScrollsToMostRecentMessage = true

        receiveData()
    }
    
    func receiveData() {
        LivetexCoreManager.defaultManager.coreService.stateWithCompletionHandler { (state: LCDialogState?, error: NSError?) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                self.updateDialogState(state!)
            }
        }
        
        LivetexCoreManager.defaultManager.coreService.messageHistory(20, offset: 0) { (messages: [LCMessage]?, error: NSError?) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                for message in messages!.reverse() {
                    if !message.confirm {
                        if message.attributes.text.senderIsSet || message.attributes.file.senderIsSet {
                            LivetexCoreManager.defaultManager.coreService.confirmMessageWithID(message.messageId) { (success: Bool, error: NSError?) in
                                if error != nil {
                                    print(error?.localizedDescription)
                                } else {
                                    message.confirm = true
                                }
                            }
                        }
                    }

                    self.messages.append(self.convertMessage(message))
                }
                self.finishReceivingMessage()
            }
        }
    }
    
    func reloadDestinationIfNeeded(response: LCSendMessageResponse) {
        if !response.destinationIsSet {
            LivetexCoreManager.defaultManager.coreService.destinationsWithCompletionHandler({ (destinations: [LCDestination]?, error: NSError?) in
                if error == nil {
                    LivetexCoreManager.defaultManager.coreService.setDestination(destinations!.first!, attributes: LCDialogAttributes(visible: [:], hidden: [:]), completionHandler: { (success: Bool, error: NSError?) in
                        if let err = error {
                            print(err.localizedDescription)
                        }
                    })
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    func convertMessage(message: LCMessage) -> JSQMessage {
        var timeInterval: NSTimeInterval = 0.0
        if message.attributes.textIsSet {
            timeInterval = (message.attributes.text.created as NSString).doubleValue
            return JSQMessage(senderId: message.attributes.text.senderIsSet ? message.attributes.text.sender : self.senderId, senderDisplayName: "", date: NSDate(timeIntervalSince1970:timeInterval / 1000), text: message.attributes.text.text)
        } else {
            timeInterval = (message.attributes.file.created as NSString).doubleValue
            let fileURL: String = message.attributes.file.url.stringByRemovingPercentEncoding!
            let pathExtention = (fileURL as NSString).pathExtension
            let paths: Array<String> = ["png", "jpg", "jpeg", "gif"]
            if paths.contains(pathExtention) {
                let media = JSQPhotoMediaItem(maskAsOutgoing: !message.attributes.file.senderIsSet)
                let mediaData = NSData(contentsOfURL: NSURL(string: message.attributes.file.url)!)
                media.image = UIImage(data: mediaData!)
                return JSQMessage(senderId: message.attributes.file.senderIsSet ? message.attributes.file.sender : self.senderId, senderDisplayName: "", date: NSDate(timeIntervalSince1970:timeInterval / 1000), media: media)
            } else {
                return JSQMessage(senderId: message.attributes.file.senderIsSet ? message.attributes.file.sender : self.senderId, senderDisplayName: "", date: NSDate(timeIntervalSince1970:timeInterval / 1000), text: message.attributes.file.url)
            }
        }
    }
    
    // MARK: - UIImagePickerController
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImagePNGRepresentation(image)
        LivetexCoreManager.defaultManager.coreService.sendFileMessage(imageData!) { (response: LCSendMessageResponse?, error: NSError?) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                self.reloadDestinationIfNeeded(response!)
                let message = LCMessage(messageId: response!.messageId, attributes: response!.attributes, confirm: true)
                self.messages.append(self.convertMessage(message))
                self.finishSendingMessage()
            }
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - LCCoreServiceDelegate
    
    func updateDialogState(dialogState: LCDialogState) {
        if dialogState.employee != nil {
            self.navigationItem.title = "\(dialogState.employee!.firstname) \(dialogState.employee!.lastname)"
        } else {
            self.navigationItem.title = "Оператор"
        }
    }
    
    func confirmMessage(messageId: String) {
        print(#function)
    }
    
    func receiveTextMessage(message: LCMessage) {
        LivetexCoreManager.defaultManager.coreService.confirmMessageWithID(message.messageId) { (success: Bool, error: NSError?) in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
        self.messages.append(self.convertMessage(message))
        finishReceivingMessageAnimated(true)
    }
    
    func receiveFileMessage(message: LCMessage) {
        self.messages.append(self.convertMessage(message))
        finishReceivingMessageAnimated(true)
    }
    
    func selectDestination(destinations: [LCDestination]) {
        LivetexCoreManager.defaultManager.coreService.setDestination(destinations.first!, attributes: LCDialogAttributes(visible: [:], hidden: [:]), completionHandler: { (success: Bool, error: NSError?) in
            if let err = error {
                print(err.localizedDescription)
            }
        })
    }
    
    // MARK: - JSQMessagesViewController method overrides
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        LivetexCoreManager.defaultManager.coreService.sendTextMessage(text) { (response: LCSendMessageResponse?, error: NSError?) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                self.reloadDestinationIfNeeded(response!)
                let message = LCMessage(messageId: response!.messageId, attributes: response!.attributes, confirm: false)
                self.messages.append(self.convertMessage(message))
                self.finishSendingMessageAnimated(true)
            }
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: - JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource {
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = self.messages[indexPath.item]
        
        if !message.isMediaMessage {
            var tintColor: UIColor = UIColor()
            if message.senderId == self.senderId {
                tintColor = UIColor.whiteColor()
            } else {
                tintColor = UIColor.blackColor()
            }
            
            cell.textView.textColor = tintColor
            cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: tintColor]
        }
    
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let currentMessage = self.messages[indexPath.item]
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
}
