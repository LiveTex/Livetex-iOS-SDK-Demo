//
//  LTChatViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation


class LTChatViewControllerOffline: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var operatorIco: UIImageView!
    @IBOutlet weak var operatorName: UILabel!
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var messageInputeView: UIView!
    @IBOutlet weak var tableViewBottomMargin: NSLayoutConstraint!

    @IBOutlet weak var operatorView: UIView!
    
    var activityView:DejalBezelActivityView?

    var messages:[LTSOfflineMessage] = []
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        LTApiManager.sharedInstance.sdk?.delegate = self
    }
    
    override func viewDidLoad() {
        
        loadMessagesAndShow()
        loadOperatoeInfo()
        commonPreparation()
    }
    
    func loadMessagesAndShow() {
        
        self.showActivityIndicator()
        
        let currentConversationId = LTApiManager.sharedInstance.offlineConversationId
        
        LTApiManager.sharedInstance.sdk?.messageListForConversationId(currentConversationId, success: { (items:[AnyObject]!) -> Void in
            
            self.removeActivityIndicator()
            self.messages = items as! [LTSOfflineMessage]
            self.tableView.reloadData()
            
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
        
        LTApiManager.sharedInstance.sdk?.sendOfflineMessageWithText(self.messageInputField.text, conversationId: currentConversationId, success: { () -> Void in
            
            self.removeActivityIndicator()
            self.messageInputField.text = ""
            self.loadMessagesAndShow()
            
        }, failure: { (exp:NSException!) -> Void in
                
            self.loadingErrorProcess(exp)
        })
    }
    
    @IBAction func close(sender: AnyObject) {
        
        self.performSegueWithIdentifier("authorizathon2", sender: nil)

    }
    
    @IBAction func sendMessageAction(sender: AnyObject) {
        
        sendMessage(messageInputField.text)
    }
    
    func loadOperatoeInfo() {
        
        let currentConversationId = LTApiManager.sharedInstance.offlineConversationId
        var currentEmpoyeeId:String?
        
        LTApiManager.sharedInstance.sdk?.offlineConversationsListWithSuccess({ (array:[AnyObject]!) -> Void in
            
            let convs = array as! [LTSOfflineConversation]
            
            for conv in convs {
                
                if conv.conversationId == currentConversationId! {
                    
                    currentEmpoyeeId = conv.currentOperatorId
                    
                    LTApiManager.sharedInstance.sdk?.getEmployees(statusType.all, success: { (items:[AnyObject]!) -> Void in
                        
                        let employees = items as! [LTSEmployee]
                        
                        for item in employees {
                            
                            let Employee = item as LTSEmployee
                            
                            if (Employee.employeeId == currentEmpoyeeId) {
                                
                                let url = NSURL(string: Employee.avatar)
                                var err: NSError?
                                var imageData :NSData = NSData(contentsOfURL:url!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)!
                                
                                var bgImage = UIImage(data:imageData)
                                self.operatorIco.image = bgImage
                                //self.operatorName = Employee.firstname + "" + Employee.lastname
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

extension LTChatViewControllerOffline: LTMobileSDKNotificationHandlerProtocol {
    
    func ban(message: String!) {
        
    }
    
    func updateDialogState(state: LTSDialogState!) {
        
    }
    
    func receiveTextMessage(message: LTSTextMessage!) {

    }
    
    func receiveFileMessage(message: LTSFileMessage!) {
        
    }
    
    func confirmTextMessage(messageId: String!) {

    }
    
    func receiveTypingMessage(message: LTSTypingMessage!) {
        
    }
    
    func receiveHoldMessage(message: LTSHoldMessage!) {
    }
    
    func receiveOfflineMessage(conversationId: String!, message: LTSOfflineMessage!) {
        
        messages.append(message)
        self.tableView.reloadData()
    }
    
    func notificationListenerErrorOccured(error: NSException!) {
        
        //self.loadingErrorProcess(error)
    }
}


extension LTChatViewControllerOffline {
    
    func showActivityIndicator() {
        
        activityView = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
    }
    
    func removeActivityIndicator() {
        
        activityView?.animateRemove()
    }
    
    func loadingErrorProcess(error:NSException) {
        
        var asd = error.userInfo!
        var error:NSError = (asd["error"] as? NSError)!
        
        self.removeActivityIndicator()
        let alert: UIAlertView = UIAlertView(title: "Ошибка", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "ОК")
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
            tableViewBottomMargin.constant -= keyboardHeight
        }
        
        UIView.animateWithDuration((notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double), delay: 0, options: UIViewAnimationOptions(UInt((notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16)), animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            
        }, completion:{(complete:Bool) -> Void in
            
            if (self.messages.count != 0) {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            }
        })
    }
    
    func commonPreparation() {
        
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        
        operatorIco.layer.borderWidth = 2.0
        operatorIco.layer.borderColor = UIColor.whiteColor().CGColor
        operatorIco.clipsToBounds = true
        operatorIco.layer.cornerRadius = 20.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setInputViewY:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setInputViewY:"), name:UIKeyboardWillHideNotification, object: nil)
    }
}

extension LTChatViewControllerOffline: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

extension LTChatViewControllerOffline: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let currentMessage = messages[indexPath.row]
        return CGFloat(LTChatMessageTableViewCell.getSizeForText(currentMessage.message))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let currentMessage = messages[indexPath.row]

        var cell:LTChatMessageTableViewCell!
        
        if currentMessage.sender != "0" {
            
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellIn") as! LTChatMessageTableViewCell
            
        } else {
            
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellOut") as! LTChatMessageTableViewCell
        }
        
        cell.offlineMessageSet = self.messages[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}