//
//  LTComplaintViewController.swift
//  LiveTex SDK
//
//  Created by Эмиль Абдуселимов on 14.04.16.
//  Copyright © 2016 LiveTex. All rights reserved.
//

import UIKit

class LTComplaintViewController: UITableViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: KMPlaceholderTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func verifyFields() -> Bool {
        var errorMessage: String = ""
        if textField.text!.isEmpty {
            errorMessage = textField.placeholder!
        } else if textView.text!.isEmpty {
            errorMessage = textView.placeholder
        }
        
        if !errorMessage.isEmpty {
            let alert: UIAlertController = UIAlertController(title: "Ошибка", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func sendComplaint(sender: AnyObject) {
        if verifyFields() {
            let view = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
            let abuse:LTSAbuse = LTSAbuse()
            abuse.contact = textField.text
            abuse.message = textView.text
            
            LTApiManager.sharedInstance.sdk?.abuseWithAbuse(abuse, success: { () -> Void in
                view.animateRemove()
                CommonUtils.showToast("Жалоба отправлена")
                self.navigationController?.popViewControllerAnimated(true)
                }, failure: { (error:NSException!) -> Void in
                    view.animateRemove()
            })
        }
    }
}
