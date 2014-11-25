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
        
         var view = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
        
        LTApiManager.sharedInstance.sdk!.messageHistory(0, offset: 99, success: { (messages:[AnyObject]!) -> Void in
            
            view.animateRemove()
            self.messages = messages as [LTSTextMessage]
            self.tableView.reloadData()
            
        }) { (error:NSException!) -> Void in
            
            self.messages = []
            self.tableView.reloadData()
            
            view.animateRemove()
            let alert: UIAlertView = UIAlertView(title: "ошибка", message: error.description, delegate: nil, cancelButtonTitle: "ОК")
            alert.show()
        }
    }

    func sendVote(vote:LTSVoteType!) {
        
        var view = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
        
        LTApiManager.sharedInstance.sdk?.voteWithVote(vote, success: { () -> Void in
            
            view.animateRemove()
            
            }, failure: { (error:NSException!) -> Void in
                
                view.animateRemove()
                let alert: UIAlertView = UIAlertView(title: "ошибка", message: error.description, delegate: nil, cancelButtonTitle: "ОК")
                alert.show()
        })
    }
    
    func sendMessage(message:String) {
        
        if message == "" {
            return
        }
        
        var view = DejalBezelActivityView(forView: self.view, withLabel: "Отправка", width:100)
        
        LTApiManager.sharedInstance.sdk?.sendMessage(message, success: { (msg:LTSTextMessage!) -> Void in
            
            view.animateRemove()
            self.messages.append(msg)
            self.messageInputField.text = ""
            self.tableView.reloadData()
            if (self.messages.count != 0) {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            }
            
            }, failure: { (error:NSException!) -> Void in
                
                view.animateRemove()
                let alert: UIAlertView = UIAlertView(title: "ошибка", message: error.description, delegate: nil, cancelButtonTitle: "ОК")
                alert.show()
        })
    }
    

}

extension LTChatViewController: LTMobileSDKNotificationHandlerProtocol {
    
    func ban(message: String!) {
        
    }
    
    func updateDialogState(state: LTSDialogState!) {
        
        if state.employeeIsSet() {
            
            waitngPlaceHolder.hidden = true
            operatorView.hidden = false
            operatorName.text = state.employee.firstname
        }
    }
    
    func receiveTextMessage(message: LTSTextMessage!) {
        
        self.messages.append(message)
        self.tableView.reloadData()
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
        
    }
    
    func receiveFileMessage(message: LTSFileMessage!) {
        
        self.messages.append(message)
        self.tableView.reloadData()
        if (self.messages.count != 0) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
        
    }
    
    func confirmTextMessage(message: String!) {
        
        
    }
    
    func receiveTypingMessage(message: LTSTypingMessage!) {
        
    }
    
    func receiveHoldMessage(message: LTSHoldMessage!) {
        
    }
    
    func notificationListenerErrorOccured(error: NSException!) {
        
    }
}


extension LTChatViewController {
    
    @IBAction func voteDown(sender: AnyObject) {
        
        sendVote(LTSVoteTypes.BAD())
    }
    
    @IBAction func voteUp(sender: AnyObject) {
        
        sendVote(LTSVoteTypes.GOOD())
    }
    @IBAction func sendMessageAction(sender: AnyObject) {
        
        sendMessage(messageInputField.text)
    }
    
    @IBAction func done(segue: UIStoryboardSegue) {
        
    }
    
    func setInputViewY(notification: NSNotification) {
        
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
    
    func commonPreparation() {
        
        waitngPlaceHolder.hidden = false
        operatorView.hidden = true
        
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
}

extension LTChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let currentMessage = messages[indexPath.row] as? LTSTextMessage {
            
            return CGFloat(LTChatMessageTableViewCell.getSizeForText(currentMessage.text))
        }
        
        if let currentMessage = messages[indexPath.row] as? LTSFileMessage {
            
            return CGFloat(LTChatMessageTableViewCell.getSizeForText(currentMessage.url))
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:LTChatMessageTableViewCell
        
        var senderIsSet:Bool!
        
        if let currentMessage = messages[indexPath.row] as? LTSTextMessage {
            senderIsSet = currentMessage.senderIsSet()
        }
        
        if let currentMessage = messages[indexPath.row] as? LTSFileMessage {
            senderIsSet = currentMessage.senderIsSet()
        }
        
        if senderIsSet == true {
            
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellIn") as LTChatMessageTableViewCell
            
        } else {
            
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellOut") as LTChatMessageTableViewCell
        }
        
        cell.messageSet = self.messages[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let message = messages[indexPath.row] as? LTSFileMessage {
            UIApplication.sharedApplication().openURL(NSURL(string: message.url)!)
        }
    }
}