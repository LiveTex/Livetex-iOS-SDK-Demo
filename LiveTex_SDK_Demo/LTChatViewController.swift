//
//  LTChatViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation

class LTChatViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var operatorName: UILabel!
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var messageInputeView: UIToolbar!
    @IBOutlet weak var tableViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var typingLabel: UILabel!
    @IBOutlet weak var abuseBtn: UIBarButtonItem!
    @IBOutlet weak var voteDownBtn: UIBarButtonItem!
    @IBOutlet weak var voteUpBtn: UIBarButtonItem!
    
    var imagePickerController = UIImagePickerController()
    var activityView:DejalBezelActivityView?
    var currentOperatorId:String?
    var messages:Array<AnyObject>! = []
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        LTApiManager.sharedInstance.sdk?.delegate = self
    }
    
    override func viewDidLoad() {
        commonPreparation()
        presentData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        tableViewBottomMargin.constant = 0
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.navigationController?.topViewController == self.navigationController?.viewControllers.first {
            closeConversation()
        }
    }
    
    func commonPreparation() {
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setInputViewY:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setInputViewY:"), name:UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkNotification:"), name: "LTNetworkNotification", object: nil)
        
        self.messageInputField.autoresizingMask = UIViewAutoresizing.FlexibleWidth;
    }
}

//MARK: businessFlow

extension LTChatViewController {

    func presentData() {
        self.showActivityIndicator()
        LTApiManager.sharedInstance.sdk!.getStateWithSuccess({ (state:LTSDialogState!) -> Void in
            LTApiManager.sharedInstance.sdk!.messageHistory(20, offset: 0, success: { (messages:[AnyObject]!) -> Void in
                self.removeActivityIndicator()
                self.wrapSDKMessages(messages)
                if self.messages.count > 1 {
                    self.messages.sortInPlace({ (message:AnyObject, messageTo:AnyObject) -> Bool in
                        return self.compareMessages(message, messageTo)
                    })
                }
                self.processDialogState(state)
            }, failure: { (error:NSException!) -> Void in
                self.messages = []
                self.tableView.reloadData()
                self.loadingErrorProcess(error)
            })
            
        }, failure: { (error:NSException!) -> Void in
            self.loadingErrorProcess(error)
        })
    }

    func sendVote(vote:LTSVoteType!) {
        showActivityIndicator()
        LTApiManager.sharedInstance.sdk?.voteWithVote(vote, success: { () -> Void in
            self.removeActivityIndicator()
            CommonUtils.showToast("Спасибо за оценку")
            }, failure: { (error:NSException!) -> Void in
                self.loadingErrorProcess(error)
        })
    }
    
    func sendMessage(message:String) {
        if message == "" {
            return
        }
        
        self.showActivityIndicator()
        LTApiManager.sharedInstance.sdk?.sendMessage(message, success: { (msg:LTSTextMessage!) -> Void in
            self.removeActivityIndicator()
            self.messages.append(LTSWTextMessage(sourceMessage:msg))
            self.messageInputField.text = ""
            self.tableView.reloadData()
            if (self.messages.count != 0) {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            }
            
            }, failure: { (error:NSException!) -> Void in
                self.loadingErrorProcess(error)
        })
    }

    func uploadFile(imgData:NSData) {
        
        let file = LTSFile(data: imgData, fileName: "file", fileExtension: "png", mimeType: "image/png")
        LTApiManager.sharedInstance.sdk?.uploadFileData(file, success: { () -> Void in
            let systemMessage = LTSHoldMessage(text: "Отправлен файл: " + "file" + ".png", timestamp: "")
            self.messages.append(systemMessage)
            self.tableView.reloadData()
            if (self.messages.count != 0) {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            }
        }, failure: { (exp:NSException!) -> Void in
                self.loadingErrorProcess(exp)
        })
    }
    
    func closeConversation() {
        self.showActivityIndicator()
        LTApiManager.sharedInstance.sdk?.getStateWithSuccess({ (state:LTSDialogState!) -> Void in
            LTApiManager.sharedInstance.isSessionOnlineOpen = false
            if (state.conversation != nil) {
                LTApiManager.sharedInstance.sdk?.closeWithSuccess({ (state:LTSDialogState!) -> Void in
                    LTApiManager.sharedInstance.onlineEmployeeId = nil
                    self.removeActivityIndicator()
                    }, failure: { (error:NSException!) -> Void in
                        self.loadingErrorProcess(error)
                })
            } else {
                self.removeActivityIndicator()
            }
            CommonUtils.showToast("Диалог закрыт")
        }, failure: { (error:NSException!) -> Void in
            self.loadingErrorProcess(error)
        })
    }
}

//MARK: imagePickerDelegate

extension LTChatViewController {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let imgData = UIImageJPEGRepresentation(image, 0.0)
        uploadFile(imgData!)
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: target-Actions

extension LTChatViewController {
    @IBAction func fileSend(sender: AnyObject) {
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: { imageP in
        })
    }
    
    @IBAction func voteDown(sender: AnyObject) {
        sendVote(LTSVoteTypes.BAD())
    }
    
    @IBAction func voteUp(sender: AnyObject) {
        sendVote(LTSVoteTypes.GOOD())
    }
    @IBAction func sendMessageAction(sender: AnyObject) {
        sendMessage(messageInputField.text!)
    }
    
    @IBAction func close(sender: AnyObject) {
        closeConversation()
    }
    
    @IBAction func done(segue:UIStoryboardSegue) {
        
    }
}

//MARK: LTMobileSDKNotificationHandlerProtocol

extension LTChatViewController: LTMobileSDKNotificationHandlerProtocol {
    func ban(message: String!) {}
    
    func updateDialogState(state: LTSDialogState!) {
        processDialogState(state)
    }
    
    func receiveTextMessage(message: LTSTextMessage!) {
        messages.append(LTSWTextMessage(sourceMessage:message))
        self.tableView.reloadData()
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
        LTApiManager.sharedInstance.sdk?.confirmTextMessageWithId(message.messageId, success: nil, failure: { (error:NSException!) -> Void in
            self.loadingErrorProcess(error)
        })
    }
    
    func receiveFileMessage(message: LTSFileMessage!) {
        self.messages.append(message)
        self.tableView.reloadData()
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
    
    func confirmTextMessage(messageId: String!) {
        for msg:AnyObject in messages {
            if let message = msg as? LTSWTextMessage {
                if message.messageId == messageId {
                    message.isConfirmed = true
                    self.tableView.reloadData()
                    if (self.messages.count != 0) {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                    }
                    break
                }
            }
        }
    }
    
    func receiveTypingMessage(message: LTSTypingMessage!) {}
    
    func receiveHoldMessage(message: LTSHoldMessage!) {
        self.messages.append(message)
        self.tableView.reloadData()
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
    
    func receiveOfflineMessage(conversationId: String!, message: LTSOfflineMessage!) {}
    func notificationListenerErrorOccured(error: NSException!) {}
}

//MARK: helpers

extension LTChatViewController {
    
    func wrapSDKMessages(messages:[AnyObject]!) {
        var wrappedMessages:[AnyObject] = []
        for msg:LTSTextMessage in messages as! [LTSTextMessage] {
            wrappedMessages.append(LTSWTextMessage(sourceMessage:msg))
            (wrappedMessages.last as! LTSWTextMessage).isConfirmed = true
        }
        
        self.messages = wrappedMessages
    }
    
    func compareMessages(message:AnyObject, _ messageTo:AnyObject) -> Bool {
        var timestamp:String = ""
        var timestampTo:String = ""
        if let c1 = message as? LTSWTextMessage {
            timestamp = c1.timestamp as String
        }
        if let c2 = messageTo as? LTSWTextMessage {
            timestampTo = c2.timestamp as String
        }
        if let c1 = message as? LTSHoldMessage {
            timestamp = c1.timestamp
        }
        if let c2 = messageTo as? LTSHoldMessage {
            timestampTo = c2.timestamp
        }
        
        return (timestamp as NSString).doubleValue < (timestampTo as NSString).doubleValue
    }
    
    func showActivityIndicator() {
        activityView = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
    }
    
    func removeActivityIndicator() {
        activityView?.animateRemove()
    }
    
    func loadingErrorProcess(error:NSException) {
        self.removeActivityIndicator()
        let alert: UIAlertController = UIAlertController(title: "Превышен лимит на отправку файлов", message: (error.userInfo!["error"] as! NSError).localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
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
                if (self.messages.count != 0) {
                    //self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                    self.tableView.setContentOffset(CGPointMake(0, max(self.tableView.contentSize.height - self.tableView.bounds.size.height, 0) ), animated: true)
                }
        })
    }
    
    func networkNotification(notification: NSNotification) {
        if ((notification.object as! NSNumber).unsignedIntegerValue <= 0) {
            self.setupOfflineDialogState(LTSDialogState(conversation: nil, employee: nil))
        } else {
            LTApiManager.sharedInstance.sdk?.getStateWithSuccess({ (state:LTSDialogState!) -> Void in
                    self.updateDialogState(state)
                }, failure: { (error:NSException!) -> Void in
                    self.loadingErrorProcess(error)
            })
        }
    }
}

extension LTChatViewController {
    func processDialogState(state:LTSDialogState) {
        if state.employeeIsSet() {
            setupActiveDialogState(state)
        } else if state.conversationIsSet() {
            setupQueuedDialogState(state)
        } else {
            setupOfflineDialogState(state)
        }
        
        self.tableView.reloadData()
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
    
    func setupActiveDialogState(state:LTSDialogState) {
        currentOperatorId = state.employee.employeeId
        LTApiManager.sharedInstance.onlineEmployeeId = state.employee.employeeId
        operatorName.text = state.employee.firstname
        self.typingLabel.text = "онлайн"
        messageInputField?.enabled = true
        voteDownBtn.enabled = true
        voteUpBtn.enabled = true
        abuseBtn.enabled = true
        
        let systemMessage = LTSHoldMessage(text: "Оператор онлайн", timestamp: "")
        self.messages.append(systemMessage)
    }
    
    func setupQueuedDialogState(state:LTSDialogState) {
        self.operatorName.text = "Оператор"
        self.typingLabel.text = "оффлайн"
        voteDownBtn.enabled = false
        voteUpBtn.enabled = false
        abuseBtn.enabled = false
        
        let systemMessage = LTSHoldMessage(text: "Оператор не в сети. Диалог в очереди", timestamp: "")
        self.messages.append(systemMessage)
    }
    
    func setupOfflineDialogState(state:LTSDialogState) {
        LTApiManager.sharedInstance.onlineEmployeeId = nil
        
        self.operatorName.text = "Оператор"
        self.typingLabel.text = "оффлайн"
        voteDownBtn.enabled = false
        voteUpBtn.enabled = false
        abuseBtn.enabled = false
        
        messageInputField?.enabled = false
        
        let systemMessage = LTSHoldMessage(text: "Оператор не в сети. Диалог закрыт", timestamp: "")
        self.messages.append(systemMessage)
    }
}

extension LTChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let typingMessage:LTSTypingMessage = LTSTypingMessage()
        typingMessage.text = textField.text! + string
        
        LTApiManager.sharedInstance.sdk!.typingWithTypingMessage(typingMessage, success: nil) { (error:NSException!) -> Void in
            
            self.loadingErrorProcess(error)
        }
        return  true
    }
}

extension LTChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var heightForRow:CGFloat = 0.0;
        if let currentMessage = messages[indexPath.row] as? LTSWTextMessage {
            heightForRow = CGFloat(LTChatMessageTableViewCell.getSizeForText(currentMessage.text))
        } else if let currentMessage = messages[indexPath.row] as? LTSFileMessage {
            heightForRow = CGFloat(LTChatMessageTableViewCell.getSizeForText(currentMessage.url))
        } else {
            heightForRow = 56.0
        }
        
        return heightForRow
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let currentMessage = messages[indexPath.row] as? LTSWTextMessage {
            var cell:LTChatMessageTableViewCell!
            if currentMessage.senderIsSet() == true {
                cell = self.tableView.dequeueReusableCellWithIdentifier("cellIn") as! LTChatMessageTableViewCell
            } else {
                cell = self.tableView.dequeueReusableCellWithIdentifier("cellOut") as! LTChatMessageTableViewCell
            }
            
            cell.messageSet = self.messages[indexPath.row]
            return cell
        }
        
        if let currentMessage = messages[indexPath.row] as? LTSFileMessage {
            var cell:LTChatMessageTableViewCell!
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellIn") as! LTChatMessageTableViewCell
            currentMessage.url = currentMessage.url.stringByRemovingPercentEncoding
            cell.messageSet = currentMessage
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
            return cell
        }
        
        if let currentMessage = messages[indexPath.row] as? LTSHoldMessage {
            var cell:LTSystemMessageTableViewCell!
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellSystem") as! LTSystemMessageTableViewCell
            cell.messageTextLabel.text = currentMessage.text
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let message = messages[indexPath.row] as? LTSFileMessage {
            let url = message.url.stringByRemovingPercentEncoding
            UIApplication.sharedApplication().openURL(NSURL(string: url!)!)
        }
    }
}