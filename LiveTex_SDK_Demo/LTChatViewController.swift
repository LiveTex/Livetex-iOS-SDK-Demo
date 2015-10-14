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
    @IBOutlet weak var operatorIco: UIImageView!
    @IBOutlet weak var operatorName: UILabel!
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var messageInputeView: UIView!
    @IBOutlet weak var tableViewBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var waitngPlaceHolder: UILabel!
    @IBOutlet weak var operatorView: UIView!
    @IBOutlet weak var typingLabel: UILabel!
    
   
    @IBOutlet weak var abuseBtn: UIButton!
    @IBOutlet weak var voteDownBtn: UIButton!
    @IBOutlet weak var voteUpBtn: UIButton!
    
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
        tableViewBottomMargin.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func commonPreparation() {
        
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        
        waitngPlaceHolder.hidden = false
        operatorView.hidden = true
        typingLabel.hidden = true
        
        operatorIco.layer.borderWidth = 2.0
        operatorIco.layer.borderColor = UIColor.whiteColor().CGColor
        operatorIco.clipsToBounds = true
        operatorIco.layer.cornerRadius = 20.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setInputViewY:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setInputViewY:"), name:UIKeyboardWillHideNotification, object: nil)
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
        LTApiManager.sharedInstance.sdk?.uploadFileData(file, recipientId: currentOperatorId, success: { () -> Void in
            
            let systemMessage = LTSHoldMessage(text: "Отправлен файл: " + "file" + ".png", timestamp: "")
            self.messages.append(systemMessage)
            
            self.tableView.reloadData()
            
            if (self.messages.count != 0) {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            }
            
            }, failure: { (exp:NSException!) -> Void in
                
                self.loadingErrorProcess(exp)
        })
        
        
//        LTApiManager.sharedInstance.sdk?.uploadFileData(imgData,
//            fileName: "file",
//            fileExtention: "png",
//            mimeType: "image/png",
//            recipientID: currentOperatorId,
//            success: { () -> Void in
//                
//                var systemMessage = LTSHoldMessage(text: "Отправлен файл: " + "file" + ".png", timestamp: "")
//                self.messages.append(systemMessage)
//                
//                self.tableView.reloadData()
//                
//                if (self.messages.count != 0) {
//                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
//                }
//                
//            }, failure: { (exp:NSException!) -> Void in
//                
//                self.loadingErrorProcess(exp)
//        })
    }
    
    func closeConversation() {
        
        self.showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk?.getStateWithSuccess({ (state:LTSDialogState!) -> Void in
            
            LTApiManager.sharedInstance.isSessionOnlineOpen = false
            
            if (state.conversation != nil) {
                
                LTApiManager.sharedInstance.sdk?.closeWithSuccess({ (state:LTSDialogState!) -> Void in
                    
                    LTApiManager.sharedInstance.onlineEmployeeId = nil
                    
                    let newstate:LTSDialogState = state
                    self.removeActivityIndicator()
                    self.performSegueWithIdentifier("authorizathon", sender: nil)
                    
                    }, failure: { (error:NSException!) -> Void in
                        
                        self.loadingErrorProcess(error)
                })
                
            } else {
                
                self.removeActivityIndicator()
                self.performSegueWithIdentifier("authorizathon", sender: nil)
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
    
    func ban(message: String!) {
        //
    }
    
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
//        if(message.url.containsString("%")) {
//            message.url = "123.png"
//        }
        
        self.messages.append(message)
        self.tableView.reloadData()
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
        
    }
    
    func confirmTextMessage(messageId: String!) {
        for msg:AnyObject in messages {
            if var message = msg as? LTSWTextMessage {
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
    
    func receiveTypingMessage(message: LTSTypingMessage!) {
        
        typingLabel.hidden = false
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.typingLabel.hidden = true
        })
    }
    
    func receiveHoldMessage(message: LTSHoldMessage!) {
        
        self.messages.append(message)
        self.tableView.reloadData()
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
    
    func receiveOfflineMessage(conversationId: String!, message: LTSOfflineMessage!) {
        //
    }
    
    func notificationListenerErrorOccured(error: NSException!) {
       //
    }
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
        
        var asd = error.userInfo
        var error:NSError? = asd?["error"] as? NSError
        
        self.removeActivityIndicator()
        let alert: UIAlertView = UIAlertView(title: "Превышен лимит на отправку файлов", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "ОК")
        alert.show()
    }
    
    func setInputViewY(notification: NSNotification) {
        //NSThread.sleepForTimeInterval(NSTimeInterval(0.6))
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
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                }
        })
    }
}

//MARK: processDialogState

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
        
        waitngPlaceHolder.hidden = true
        operatorView.hidden = false
        operatorName.text = state.employee.firstname
        
        messageInputField?.enabled = true
        
        voteDownBtn.enabled = true
        voteUpBtn.enabled = true
        abuseBtn.enabled = true
        
        var systemMessage = LTSHoldMessage(text: "Оператор онлайн", timestamp: "")
        self.messages.append(systemMessage)
        
        let url = NSURL(string: state.employee.avatar)
        
        if (url != nil) {
            
            NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: url!),
                queue: NSOperationQueue.mainQueue(),
                completionHandler: { (response, data, error) -> Void in
                    
                let httpResponse = response as? NSHTTPURLResponse
                if httpResponse?.statusCode == 200 && error == nil {
                    self.operatorIco.image = UIImage(data: data!)
                }
            })
        }
    }
    
    func setupQueuedDialogState(state:LTSDialogState) {
        
        waitngPlaceHolder.hidden = false
        operatorView.hidden = true
        
        voteDownBtn.enabled = false
        voteUpBtn.enabled = false
        abuseBtn.enabled = false
        
        var systemMessage = LTSHoldMessage(text: "Оператор не в сети. Диалог в очереди", timestamp: "")
        self.messages.append(systemMessage)
    }
    
    func setupOfflineDialogState(state:LTSDialogState) {
        
        LTApiManager.sharedInstance.onlineEmployeeId = nil
        
        waitngPlaceHolder.hidden = true
        operatorView.hidden = true
        
        voteDownBtn.enabled = false
        voteUpBtn.enabled = false
        abuseBtn.enabled = false
        
        messageInputField?.enabled = false
        
        var systemMessage = LTSHoldMessage(text: "Оператор не в сети. Диалог закрыт", timestamp: "")
        self.messages.append(systemMessage)
    }
}

//MARK: UITextFieldDelegate

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

//MARK: UITableViewDelegate, UITableViewDataSource

extension LTChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let currentMessage = messages[indexPath.row] as? LTSWTextMessage {
            
            return CGFloat(LTChatMessageTableViewCell.getSizeForText(currentMessage.text))
        }
        
        if let currentMessage = messages[indexPath.row] as? LTSFileMessage {
            return CGFloat(LTChatMessageTableViewCell.getSizeForText(currentMessage.url))
        }
        
        if let currentMessage = messages[indexPath.row] as? LTSHoldMessage {
            
            return 56
        }
        
        return 0
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
            currentMessage.url = currentMessage.url.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
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
            let url = message.url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            UIApplication.sharedApplication().openURL(NSURL(string: url!)!)
        }
    }
}