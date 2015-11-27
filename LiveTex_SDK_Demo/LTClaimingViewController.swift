//
//  LTClaimingViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 14/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit

class LTClaimingViewController: UIViewController {

    @IBOutlet weak var contact: UITextField!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var messagePlaceHolder: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messageField.layer.borderColor = UIColor.lightGrayColor().CGColor
        messageField.layer.borderWidth = 0.4
        messageField.layer.cornerRadius = 6.0
    }
}

//MARK: target - Actions

extension LTClaimingViewController {
    
    
    @IBAction func closeAction(sender: AnyObject) {
        self.performSegueWithIdentifier("closeClaim", sender: nil)
    }
    
    @IBAction func sendClaim(sender: AnyObject) {
        if(CommonUtils.isWhiteSpaceString(contact.text!) || CommonUtils.isWhiteSpaceString(messageField.text!)) {
            CommonUtils.showAlert("Заполните обязательные поля")
        } else if(!CommonUtils.isValidPhone(contact.text!)) {
            CommonUtils.showAlert("Неверно введен номер телефона")
        } else {
            sendClaimConversation()
        }
    }
}

//MARK: business Flow

extension LTClaimingViewController {
    
    func sendClaimConversation() {
        
        let view = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
        
        let abuse:LTSAbuse = LTSAbuse()
        abuse.contact = self.contact.text
        abuse.message = messageField.text
        
        LTApiManager.sharedInstance.sdk?.abuseWithAbuse(abuse, success: { () -> Void in
            view.animateRemove()
            CommonUtils.showToast("Жалоба отправлена")
            self.navigationController?.popViewControllerAnimated(true)
        }, failure: { (error:NSException!) -> Void in
                
            view.animateRemove()
          //  UIAlertView(title: "Ошибка", message: error.description, delegate: nil, cancelButtonTitle: "ОК").show()
        })
    }
}

//MARK: UITextViewDelegate

extension LTClaimingViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        messagePlaceHolder.hidden = true;
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            messagePlaceHolder.hidden = false;
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text.hasSuffix("\n") {
            textView.resignFirstResponder()
        }
        
        return true;
    }
}
