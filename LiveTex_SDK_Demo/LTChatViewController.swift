//
//  LTChatViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation


class LTChatViewController: UIViewController {
    
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
    
    var activityView:DejalBezelActivityView?

    var messages:Array<AnyObject>! = []
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        LTApiManager.sharedInstance.sdk?.delegate = self
    }
    
    override func viewDidLoad() {
        
        loadMessagesAndShow()
        commonPreparation()
    }
    
    func loadMessagesAndShow() {
        
        self.showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk!.getStateWithSuccess({ (state:LTSDialogState!) -> Void in
            
            if state.employeeIsSet() {
                
                let url = NSURL(string: state.employee.avatar)
                var err: NSError?
                var imageData :NSData = NSData(contentsOfURL:url!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)!
                var bgImage = UIImage(data:imageData)
                self.operatorIco.image = bgImage
            }
            
            LTApiManager.sharedInstance.sdk!.messageHistory(0, offset: 99, success: { (messages:[AnyObject]!) -> Void in
                
                self.removeActivityIndicator()
                
                var wrappedMessages:[AnyObject] = []
                
                for msg:LTSTextMessage in messages as [LTSTextMessage] {
                    
                    wrappedMessages.append(LTSWTextMessage(sourceMessage:msg))
                    (wrappedMessages.last as LTSWTextMessage).isConfirmed = true
                }
                
                self.messages = wrappedMessages
                
                if self.messages.count > 1 {
                    
                    self.messages.sort({ (s1:AnyObject, s2:AnyObject) -> Bool in
                        
                        var timestamp1:String = ""
                        var timestamp2:String = ""
                        
                        if let c1 = s1 as? LTSWTextMessage {
                            timestamp1 = c1.timestamp
                        }
                        
                        if let c2 = s2 as? LTSWTextMessage {
                            timestamp2 = c2.timestamp
                        }
                        
                        if let c1 = s1 as? LTSHoldMessage {
                            timestamp1 = c1.timestamp
                        }
                        
                        if let c2 = s2 as? LTSHoldMessage {
                            timestamp2 = c2.timestamp
                        }
                        
                        return (timestamp1 as NSString).doubleValue < (timestamp2 as NSString).doubleValue
                    })
                }

                self.processDialogState(state)
                
                }) { (error:NSException!) -> Void in
                    
                    self.messages = []
                    self.tableView.reloadData()
                    
                    self.loadingErrorProcess(error)
            }
            
        }, failure: { (error:NSException!) -> Void in
            
            self.loadingErrorProcess(error)
        })
    }

    func sendVote(vote:LTSVoteType!) {
        
        showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk?.voteWithVote(vote, success: { () -> Void in
            
            self.removeActivityIndicator()
            
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
    
    @IBAction func close(sender: AnyObject) {
        
        self.showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk?.getStateWithSuccess({ (state:LTSDialogState!) -> Void in
            
            LTApiManager.sharedInstance.isSessionOpen = false
            
            if (state.conversationIsSet()) {
                
                 LTApiManager.sharedInstance.sdk?.closeWithSuccess({ (state:LTSDialogState!) -> Void in
                    
                    LTApiManager.sharedInstance.employeeId = nil
                    
                    let newstate:LTSDialogState = state
                    LTApiManager.sharedInstance.sdk?.stop()
                    self.removeActivityIndicator()
                    LTApiManager.sharedInstance.sdk = nil
                    self.performSegueWithIdentifier("authorizathon", sender: nil)

                 }, failure: { (error:NSException!) -> Void in
                
                    self.loadingErrorProcess(error)
                 })
                
            } else {
                
                LTApiManager.sharedInstance.sdk?.stop()
                self.removeActivityIndicator()
                LTApiManager.sharedInstance.sdk = nil
                self.performSegueWithIdentifier("authorizathon", sender: nil)
            }
            
        }, failure: { (error:NSException!) -> Void in
            
            self.loadingErrorProcess(error)
        })
    }
    
    @IBAction func voteDown(sender: AnyObject) {
        
        sendVote(LTSVoteTypes.BAD())
    }
    
    @IBAction func voteUp(sender: AnyObject) {
        
        sendVote(LTSVoteTypes.GOOD())
    }
    @IBAction func sendMessageAction(sender: AnyObject) {
        
        sendMessage(messageInputField.text)
    }
}

extension LTChatViewController: LTMobileSDKNotificationHandlerProtocol {
    
    func ban(message: String!) {
        
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
    
    func notificationListenerErrorOccured(error: NSException!) {
        
        self.loadingErrorProcess(error)
    }
}


extension LTChatViewController {
    
    func processDialogState(state:LTSDialogState) {
        
        if state.employeeIsSet() {
            
            LTApiManager.sharedInstance.employeeId = state.employee.employeeId
            
            waitngPlaceHolder.hidden = true
            operatorView.hidden = false
            operatorName.text = state.employee.firstname
            
            messageInputField?.enabled = true
            
            voteDownBtn.enabled = true
            voteUpBtn.enabled = true
            abuseBtn.enabled = true
            
            var systemMessage = LTSHoldMessage(text: "Оператор онлайн", timestamp: "")
            self.messages.append(systemMessage)
            
        } else if state.conversationIsSet() {
            
            waitngPlaceHolder.hidden = false
            operatorView.hidden = true
            
            voteDownBtn.enabled = false
            voteUpBtn.enabled = false
            abuseBtn.enabled = false
            
            var systemMessage = LTSHoldMessage(text: "Оператор не в сети. Диалог в очереди", timestamp: "")
            self.messages.append(systemMessage)
            
        } else {
            
            LTApiManager.sharedInstance.employeeId = nil
            
            waitngPlaceHolder.hidden = true
            operatorView.hidden = true
            
            voteDownBtn.enabled = false
            voteUpBtn.enabled = false
            abuseBtn.enabled = false
            
            messageInputField?.enabled = false
            
            var systemMessage = LTSHoldMessage(text: "Оператор не в сети. Диалог закрыт", timestamp: "")
            self.messages.append(systemMessage)
        }
        
        self.tableView.reloadData()
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
    
    func showActivityIndicator() {
        
        activityView = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
    }
    
    func removeActivityIndicator() {
        
        activityView?.animateRemove()
    }
    
    func loadingErrorProcess(error:NSException) {
        
        var asd = error.userInfo!
        var error:NSError = asd["error"] as NSError
        
        self.removeActivityIndicator()
        let alert: UIAlertView = UIAlertView(title: "Ошибка", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "ОК")
        alert.show()
    }
    
    func setInputViewY(notification: NSNotification) {
        
        if tableViewBottomMargin.constant > 100 && notification.name == UIKeyboardWillShowNotification {
            return
        }
        
        self.view.layoutIfNeeded()
        
        let frame: CGRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        let keyboardHeight: CGFloat = self.view.convertRect(frame, fromView: nil).size.height
        
        if notification.name == UIKeyboardWillShowNotification {
            tableViewBottomMargin.constant += keyboardHeight
        } else {
            tableViewBottomMargin.constant -= keyboardHeight
        }
        
        UIView.animateWithDuration((notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as Double), delay: 0, options: UIViewAnimationOptions(UInt((notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as NSNumber).integerValue << 16)), animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            
        }, completion:{(complete:Bool) -> Void in
            
            if (self.messages.count != 0) {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            }
        })
    }
    
    @IBAction func done(segue:UIStoryboardSegue) {
        
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

extension LTChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let typingMessage:LTSTypingMessage = LTSTypingMessage()
        typingMessage.text = textField.text + string
        
        LTApiManager.sharedInstance.sdk!.typingWithTypingMessage(typingMessage, success: nil) { (error:NSException!) -> Void in
        
            //self.loadingErrorProcess(error)
        }
        return  true
    }
}

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
                
                cell = self.tableView.dequeueReusableCellWithIdentifier("cellIn") as LTChatMessageTableViewCell
                
            } else {
                
                cell = self.tableView.dequeueReusableCellWithIdentifier("cellOut") as LTChatMessageTableViewCell
            }
            
            cell.messageSet = self.messages[indexPath.row]
            return cell
        }
        
        if let currentMessage = messages[indexPath.row] as? LTSFileMessage {
            
            var cell:LTChatMessageTableViewCell!
            
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellIn") as LTChatMessageTableViewCell
            cell.messageSet = self.messages[indexPath.row]
            return cell
        }
        
        if let currentMessage = messages[indexPath.row] as? LTSHoldMessage {
            
            var cell:LTSystemMessageTableViewCell!
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellSystem") as LTSystemMessageTableViewCell
            cell.messageTextLabel.text = currentMessage.text
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let message = messages[indexPath.row] as? LTSFileMessage {
            UIApplication.sharedApplication().openURL(NSURL(string: ("http:" + message.url))!)
        }
    }
}