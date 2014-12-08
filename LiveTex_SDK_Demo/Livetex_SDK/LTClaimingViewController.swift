//
//  LTClaimingViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 14/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit

class LTClaimingViewController: UIViewController {

    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var messagePlaceHolder: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendClaim(sender: AnyObject) {
        
        let abuse:LTSAbuse = LTSAbuse()
        abuse.contact = ""
        abuse.message = messageField.text
        
        var view = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
        
        LTApiManager.sharedInstance.sdk?.abuseWithAbuse(abuse, success: { () -> Void in
            
            view.animateRemove()
            self.performSegueWithIdentifier("unwind", sender: nil)
            
        }, failure: { (error:NSException!) -> Void in
            
            view.animateRemove()
            let alert: UIAlertView = UIAlertView(title: "ошибка", message: error.description, delegate: nil, cancelButtonTitle: "ОК")
            alert.show()
        })
    }
}


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
