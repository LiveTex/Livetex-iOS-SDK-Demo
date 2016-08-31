//
//  LTConversationViewController.swift
//  LiveTex SDK
//
//  Created by Эмиль Абдуселимов on 13.04.16.
//  Copyright © 2016 LiveTex. All rights reserved.
//

import UIKit
import LivetexCore

let kLivetexVisitorName = "kLivetexVisitorName"

class ConversationViewController: UIViewController, UITextFieldDelegate {
    var destination: LCDestination?
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let paddleView:UIView = UIView(frame: CGRect(x:0, y:0, width:16, height:20))
        self.nameField.leftView = paddleView
        self.nameField.leftViewMode = UITextFieldViewMode.Always
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        LivetexCoreManager.defaultManager.coreService.destinationsWithCompletionHandler { (destinations: [LCDestination]?, error: NSError?) in
            if error == nil {
                LivetexCoreManager.defaultManager.coreService.setDestination(destinations!.first!, attributes: LCDialogAttributes(visible: [:], hidden: [:]), completionHandler: { (success: Bool, error: NSError?) in
                    if let err = error {
                        print(err.localizedDescription)
                    }
                })
            } else {
                print(error?.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func verifyFields() -> Bool {
        var errorMessage: String = ""
        if nameField.text!.isEmpty {
            errorMessage = nameField.placeholder!
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
    
    @IBAction func createConversation(sender: AnyObject) {
        if verifyFields() {
            LivetexCoreManager.defaultManager.coreService.setVisitor(self.nameField.text!, completionHandler: { (success: Bool, error: NSError?) in
                if error == nil {
                    NSUserDefaults.standardUserDefaults().setObject(self.nameField.text!, forKey: kLivetexVisitorName)
                }
            })
            
            self.navigationController?.showViewController(ChatViewController(), sender: nil)
        }
    }
}
