//
//  LTChatViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation


class LTChatViewControllerOffliner: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var messageInputeView: UIView!
    @IBOutlet weak var tableViewBottomMargin: NSLayoutConstraint!
    
    var imagePickerController = UIImagePickerController()
    var activityView:DejalBezelActivityView?
    
    var messages:[LTSOfflineMessage] = []
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        LTApiManager.sharedInstance.sdk?.delegate = self
    }
    
    override func viewDidLoad() {
        self.messageInputField.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        commonPreparation()
        presentData()
        loadOperatoeInfo()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableViewBottomMargin.constant = 0
        self.view.layoutIfNeeded()
        self.scrollToBottom()
    }
}

//MARK: business Flow

extension LTChatViewControllerOffliner {
    
    func presentData() {
        
        self.showActivityIndicator()
        
        let currentConversationId = LTApiManager.sharedInstance.offlineConversationId
        
        LTApiManager.sharedInstance.sdk?.messageListForConversationId(currentConversationId, success: { (items:[AnyObject]!) -> Void in
            
            self.removeActivityIndicator()
            
            self.messages = (items as! [LTSOfflineMessage]).sort({$0.creationTime < $1.creationTime})
            self.tableView.reloadData()
            self.scrollToBottom()
            
            }, failure: { (exp:NSException!) -> Void in
                
                self.loadingErrorProcess(exp)
        })
    }
    
    func sendMessage(message:String) {
        
        if message == "" {
            return
        }
        
        self.showActivityIndicator()
        
        let currentConversationId = LTApiManager.sharedInstance.offlineConversationId
        
        LTApiManager.sharedInstance.sdk?.sendOfflineMessageWithText(self.messageInputField.text,
            conversationId: currentConversationId,
            success: { () -> Void in
            
            self.removeActivityIndicator()
            self.messageInputField.text = ""
            self.presentData()
            
        }, failure: { (exp:NSException!) -> Void in
                
            self.loadingErrorProcess(exp)
        })
    }
    
    func uploadFile(imgData:NSData) {
        
        let file = LTSFile(data: imgData, fileName: "file", fileExtension: "png", mimeType: "image/png");
        LTApiManager.sharedInstance.sdk?.uploadOfflineFileData(file, conversationId: LTApiManager.sharedInstance.offlineConversationId, success: { () -> Void in
            
            self.presentData()
            
            }, failure: { (exp:NSException!) -> Void in
                self.loadingErrorProcess(exp)
                
        })
    }
    
    func loadOperatoeInfo() {
        
        let currentConversationId = LTApiManager.sharedInstance.offlineConversationId
        var currentEmpoyeeId:String?
        
        LTApiManager.sharedInstance.sdk?.offlineConversationsListWithSuccess({ (array:[AnyObject]!) -> Void in
            
            let conversations = array as! [LTSOfflineConversation]
            
            for currentConversation in conversations {
                
                if (currentConversation.conversationId == currentConversationId!) {
                    
                    currentEmpoyeeId = currentConversation.currentOperatorId
                    
                    LTApiManager.sharedInstance.sdk?.getEmployees(statusType.all, success: { (items:[AnyObject]!) -> Void in
                        let employees = items as! [LTSEmployee]
                        for currentEmployee in employees {
                            if (currentEmployee.employeeId == currentEmpoyeeId) {
                                self.navigationItem.title = currentEmployee.firstname
                            }
                        }
                        
                    }, failure: { (exeption) -> Void in
                            
                        self.loadingErrorProcess(exeption)
                    })
                }
            }
            
        }, failure: { (exeption) -> Void in
                
            self.loadingErrorProcess(exeption)
        })
    }
}

//MARK: UIImagePickerControllerDelegates

extension LTChatViewControllerOffliner {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        let imgData = UIImageJPEGRepresentation(image, 0.0)
        
        uploadFile(imgData!)
        
        self.presentedViewController?.dismissViewControllerAnimated(true, completion:nil)
    }
}

//MARK: target-Actions

extension LTChatViewControllerOffliner {
    
    @IBAction func sendMessageAction(sender: AnyObject) {
        
        sendMessage(messageInputField.text!)
    }
    
    @IBAction func fileSend(sender: AnyObject) {
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: { imageP in
            
        })
    }
}

//MARK: LTMobileSDKNotificationHandlerProtocol

extension LTChatViewControllerOffliner: LTMobileSDKNotificationHandlerProtocol {
    
    func ban(message: String!) {
        //
    }
    
    func updateDialogState(state: LTSDialogState!) {
        //
    }
    
    func receiveTextMessage(message: LTSTextMessage!) {
        //
    }
    
    func receiveFileMessage(message: LTSFileMessage!) {
        //
    }
    
    func confirmTextMessage(messageId: String!) {
        //
    }
    
    func receiveTypingMessage(message: LTSTypingMessage!) {
        //
    }
    
    func receiveHoldMessage(message: LTSHoldMessage!) {
        //
    }
    
    func receiveOfflineMessage(conversationId: String!, message: LTSOfflineMessage!) {
        
        messages.append(message)
        self.tableView.reloadData()
    }
    
    func notificationListenerErrorOccured(error: NSException!) {
        
        self.loadingErrorProcess(error)
    }
}

//MARK: helpers

extension LTChatViewControllerOffliner {
    
    func commonPreparation() {
        
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LTChatViewControllerOffliner.setInputViewY(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LTChatViewControllerOffliner.setInputViewY(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func showActivityIndicator() {
        
        activityView = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
    }
    
    func removeActivityIndicator() {
        
        activityView?.animateRemove()
    }
    
    func loadingErrorProcess(error:NSException) {
        
        var asd = error.userInfo
        let error:NSError? = asd?["error"] as? NSError
        
        self.removeActivityIndicator()
        let alert: UIAlertView = UIAlertView(title: "Превышен лимит на отправку файлов", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "ОК")
        alert.show()
    }
    
    func setInputViewY(notification: NSNotification) {
        
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
                self.scrollToBottom()
                
        })
    }
    
    func scrollToBottom() {
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
}

//MARK: UITextFieldDelegate

extension LTChatViewControllerOffliner: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

//MARK: UITableViewDelegate

extension LTChatViewControllerOffliner: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let currentMessage = messages[indexPath.row]
        return CGFloat(LTChatMessageTableViewCell.getSizeForText(currentMessage.message))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let currentMessage = messages[indexPath.row]
        
        var cell:LTOfflineChatMessageTableViewCell!
        
        if currentMessage.sender != "0" {
            
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellIn") as! LTOfflineChatMessageTableViewCell
            
        } else {
            
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellOut") as! LTOfflineChatMessageTableViewCell
        }
        
        cell.messageSet = self.messages[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}