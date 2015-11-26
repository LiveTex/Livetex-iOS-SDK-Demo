//
//  LTOfflineConversationCreatioViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Сергей Девяткин on 6/6/15.
//  Copyright (c) 2015 LiveTex. All rights reserved.
//

import UIKit

class LTOfflineConversationCreationViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var message: UITextView!
    
    var activityView:DejalBezelActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.delegate = self
        self.message.delegate = self
        self.email.delegate = self
        
        self.message.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.message.layer.borderWidth = 0.4
        self.message.layer.cornerRadius = 6.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text.hasSuffix("\n") {
            textView.resignFirstResponder()
        }
        
        return true;
    }
}

//MARK: business flow

extension LTOfflineConversationCreationViewController {
    
    func creatOfflineConversation() {
        
        if(CommonUtils.isWhiteSpaceString(message.text!)) {
            CommonUtils.showAlert("Заполните текст обращения")
            return
        }
        
        if (CommonUtils.isWhiteSpaceString(email.text!) || !CommonUtils.isValidEmail(email.text!)) {
            UIAlertView(title: "Ошибка", message: "Неверный формат эл. почты", delegate: nil, cancelButtonTitle: "ОК").show()
            return
        }
        
        if(!CommonUtils.isWhiteSpaceString(phone.text!) && !CommonUtils.isValidPhone(phone.text!)) {
            CommonUtils.showAlert("Неверно введен номер телефона")
            return
        }
        
        let  contacts = LTSOfllineVisitorContacts()
        contacts.name = name.text
        contacts.phone = phone.text
        contacts.email = email.text
        
        self.showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk?.createOfflineConversationForVisitor(contacts, forDepartmentId:offlineDeparmentId, success: { (convId:String!) -> Void in
            
            LTApiManager.sharedInstance.offlineConversationId = convId
            
            LTApiManager.sharedInstance.sdk?.sendOfflineMessageWithText(self.message.text, conversationId: convId, success: { () -> Void in
                
                self.removeActivityIndicator()
                self.performSegueWithIdentifier("offlineChatStart", sender: nil)
                
                }, failure: { (exp:NSException!) -> Void in
                    
                    self.loadingErrorProcess(exp)
            })
            
            }, failure: { (exp:NSException!) -> Void in
                
                self.loadingErrorProcess(exp)
        })
    }
}

//MARK: actions

extension LTOfflineConversationCreationViewController {
    
    @IBAction func send(sender: AnyObject) {
        creatOfflineConversation()
    }
}

//MARK: helpers

extension LTOfflineConversationCreationViewController {
    
        
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
        let alert: UIAlertView = UIAlertView(title: "Ошибка", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "ОК")
        alert.show()
    }
}