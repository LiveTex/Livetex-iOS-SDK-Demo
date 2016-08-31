//
//  LTChatViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation
import LivetexCore

class MessagesViewController: UIViewController,
                              UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate,
                              UITableViewDelegate,
                              UITableViewDataSource, LCCoreServiceDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var messageInputeView: UIToolbar!
    @IBOutlet weak var tableViewBottomMargin: NSLayoutConstraint!
    
    var imagePickerController = UIImagePickerController()
    var currentOperatorId: String?
    var messages: Array<LCMessage>! = []
    var images: [String: AnyObject]! = [:]
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        LivetexCoreManager.defaultManager.coreService.delegate = self;
    }
    
    override func viewDidLoad() {
        commonPreparation()
        receiveData()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableViewBottomMargin.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func commonPreparation() {
        self.navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.keyboardNotification(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.keyboardNotification(_:)), name:UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.networkNotification(_:)), name: kApplicationDidReceiveNetworkStatus, object: nil)
        
        self.messageInputField.autoresizingMask = UIViewAutoresizing.FlexibleWidth;
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func receiveData() {
        self.showActivityIndicator()
        LivetexCoreManager.defaultManager.coreService.stateWithCompletionHandler { (state: LCDialogState?, error: NSError?) in
            self.removeActivityIndicator()
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
                self.messages = messages!.reverse()
                self.tableView.reloadData()
                if (self.messages.count > 0) {
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, appendRowAtIndexPaths indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        self.tableView.endUpdates()
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
    
    func sendMessage(message:String) {
        if message == "" {
            return
        }
        
        self.showActivityIndicator()
        LivetexCoreManager.defaultManager.coreService.sendTextMessage(message) { (response: LCSendMessageResponse?, error: NSError?) in
            self.removeActivityIndicator()
            if let err = error {
                print(err.localizedDescription)
            } else {
                self.reloadDestinationIfNeeded(response!)
                let message = LCMessage(messageId: response!.messageId, attributes: response!.attributes, confirm: false)
                self.messageInputField.text = ""
                self.messages.append(message)
                self.tableView(self.tableView, appendRowAtIndexPaths: [NSIndexPath(forRow: self.messages.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
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
    
    func closeConversation() {
        self.showActivityIndicator()
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImagePNGRepresentation(image)
        LivetexCoreManager.defaultManager.coreService.sendFileMessage(imageData!) { (response: LCSendMessageResponse?, error: NSError?) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let message = LCMessage(messageId: response!.messageId, attributes: response!.attributes, confirm: true)
                dispatch_async(dispatch_get_main_queue(), {
                    self.messages.append(message)
                    self.tableView.reloadData()
                    if (self.messages.count != 0) {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                    }
                })
            }
        }
        
        imagePickerController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return  true
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: MessageTableViewCell!
        let message = messages[indexPath.row]
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

        if message.attributes.textIsSet {
            let textMessage = message.attributes.text
            cell = tableView.dequeueReusableCellWithIdentifier(textMessage.senderIsSet == true ? "cellIn" : "cellOut", forIndexPath: indexPath) as! MessageTableViewCell
            cell.message = message
            var image: UIImage = UIImage(named: message.attributes.text.senderIsSet ? "baloon_gray" : "baloon_blue")!
            image = image.imageMaskedWithColor(message.attributes.text.senderIsSet ? UIColor.messageBubbleLightGrayColor() : UIColor.messageBubbleBlueColor())
            cell.messageImageView.image = image.resizableImageWithCapInsets(UIEdgeInsetsMake(15.0, 20.0, 15.0, 20.0))
        } else if message.attributes.fileIsSet {
            let fileMessage = message.attributes.file
            let fileURL: String = fileMessage.url.stringByRemovingPercentEncoding!
            let pathExtention = (fileURL as NSString).pathExtension
            let paths: Array<String> = ["png", "jpg", "jpeg", "gif"]
            
            cell = tableView.dequeueReusableCellWithIdentifier(fileMessage.senderIsSet == true ? "FileIn" : "FileOut", forIndexPath: indexPath) as! MessageTableViewCell
            cell.message = message

            let imageViewMask = UIImageView(image: UIImage(named: fileMessage.senderIsSet == true ? "baloon_gray" : "baloon_blue"))
            imageViewMask.image = imageViewMask.image!.resizableImageWithCapInsets(UIEdgeInsetsMake(15, 20, 15, 20))
            imageViewMask.frame = CGRectInset(CGRectMake(0, 0, 210.0, 160.0), 2.0, 2.0)
            cell.messageImageView.layer.mask = imageViewMask.layer
            cell.messageImageView.layer.masksToBounds = true

            if paths.contains(pathExtention) {
                if self.images[fileURL] != nil {
                    cell.messageImageView.image = images[fileURL] as! UIImage!
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        let imageData = NSData(contentsOfURL: NSURL(string: fileURL)!)
                        if imageData != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                cell.messageImageView.image = UIImage(data: imageData!)
                                self.images[fileURL] = cell.messageImageView.image
                                cell.setNeedsLayout()
                            })
                        }
                    })
                }
            } else {
                cell.messageImageView.image = UIImage(named: "clip")
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let message = messages[indexPath.row]
        if message.attributes.fileIsSet {
            UIApplication.sharedApplication().openURL(NSURL(string: message.attributes.file.url)!)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var heightForRow: CGFloat = 0.0
        let message = messages[indexPath.row]
        if message.attributes.textIsSet {
            heightForRow = MessageTableViewCell.heightOfText(message.attributes.text.text)
        } else if message.attributes.fileIsSet {
            heightForRow = 170.0
        }
        
        return heightForRow
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
        self.messages.append(message)
        self.tableView(self.tableView, appendRowAtIndexPaths: [NSIndexPath(forRow: self.messages.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func receiveFileMessage(message: LCMessage) {
        self.messages.append(message)
        self.tableView(self.tableView, appendRowAtIndexPaths: [NSIndexPath(forRow: self.messages.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func selectDestination(destinations: [LCDestination]) {
        print(#function)
    }
    
    // MARK: - Actions
    
    @IBAction func fileSend(sender: AnyObject) {
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func sendMessageAction(sender: AnyObject) {
        sendMessage(messageInputField.text!)
    }
}

//MARK: helpers

extension UIImage {
    func imageMaskedWithColor(color: UIColor) -> UIImage {
        let imageRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height)
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextTranslateCTM(context, 0.0, -(imageRect.size.height))
        CGContextClipToMask(context, imageRect, self.CGImage)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, imageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage
    }
}

extension UIColor {
    class func messageBubbleBlueColor() -> UIColor {
        return UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
    }
    
    class func messageBubbleLightGrayColor() -> UIColor {
        return UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
    }
}

extension MessagesViewController {
    
    func showActivityIndicator() {
        activityView = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
    }
    
    func removeActivityIndicator() {
        activityView?.animateRemove()
    }
    
    func keyboardNotification(notification: NSNotification) {
        if tableViewBottomMargin.constant > 100 && notification.name == UIKeyboardWillShowNotification {
            return
        }
        self.view.layoutIfNeeded()
        let frame: CGRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey]as! NSValue).CGRectValue()
        let keyboardHeight: CGFloat = self.view.convertRect(frame, fromView: nil).size.height
        if notification.name == UIKeyboardWillShowNotification {
            tableViewBottomMargin.constant += keyboardHeight
        } else {
            tableViewBottomMargin.constant = 0
        }
        
        UIView.animateWithDuration((notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double), delay: 0, options: UIViewAnimationOptions(rawValue: UInt((notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16)), animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion:{(complete:Bool) -> Void in
                if (self.messages.count != 0) {
                    //self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                    self.tableView.setContentOffset(CGPointMake(0, max(self.tableView.contentSize.height - self.tableView.bounds.size.height, 0) ), animated: true)
                }
        })
    }
    
    func networkNotification(notification: NSNotification) {
        print(#function)
    }
}