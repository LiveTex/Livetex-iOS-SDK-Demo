//
//  LTOfflineConversationCreationViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Сергей Девяткин on 6/6/15.
//  Copyright (c) 2015 LiveTex. All rights reserved.
//

import UIKit

class LTOfflineConversationCreationViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var message: UITextView!
    
    var activityView:DejalBezelActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func send(sender: AnyObject) {
        
        let  contacts = LTSOfllineVisitorContacts()
        contacts.name = name.text
        contacts.phone = phone.text
        contacts.email = email.text
        
        self.showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk?.createOfflineConversationForVisitor(contacts, success: { (convId:String!) -> Void in
            
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


extension LTOfflineConversationCreationViewController {
    
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
}