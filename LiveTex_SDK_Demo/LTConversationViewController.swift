//
//  LTConversationViewController.swift
//  LiveTex SDK
//
//  Created by Эмиль Абдуселимов on 13.04.16.
//  Copyright © 2016 LiveTex. All rights reserved.
//

import UIKit

class LTConversationViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    var department: LTSDepartment?
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var livetexField: UITextField!
    @IBOutlet weak var messageView: KMPlaceholderTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 1 {
            LTApiManager.sharedInstance.sdk!.getDepartments("online", success: { (items:[AnyObject]!) -> Void in
                    if (items.count > 0) {
                        self.departmentsSheet(items)
                    }
                }, failure: { (error:NSException!) -> Void in
            })
        }
    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textAlignment = NSTextAlignment.Center
        headerView.textLabel?.font = UIFont.systemFontOfSize(16)
    }
    
    func verifyFields() -> Bool {
        var errorMessage: String = ""
        if nameField.text!.isEmpty {
            errorMessage = nameField.placeholder!
        } else if messageView.text!.isEmpty {
            errorMessage = messageView.placeholder
        } else if department == nil {
            errorMessage = "Выберите отдел"
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
    
    func departmentsSheet(items: Array<AnyObject>) {
        let actionSheet = UIAlertController(title: "Отделы", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        for item in items {
            let department = item as! LTSDepartment
            let action = UIAlertAction(title: department.name, style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
                cell?.detailTextLabel?.text = action.title
                self.department = department
            })
            actionSheet.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Cancel, handler: nil)
        actionSheet.addAction(cancel)
        self.presentViewController(actionSheet, animated: true, completion: nil)
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
    
    @IBAction func createConversation(sender: AnyObject) {
        if verifyFields() {
            self.createConversation()
        }
    }

    func createConversation() {
        LTApiManager.sharedInstance.sdk!.setVisitorName(self.nameField.text!, success: { () -> Void in
                let attr = LTSDialogAttributes()
                attr.visible = LTSOptions(dictionary: ["livetex_id": self.livetexField.text!])
                attr.hidden = LTSOptions(dictionary: ["platform": "ios"])
                self.createDepartmentConversationWithAttributes(attr)
            }, failure: { (error: NSException?) -> Void in
        })
    }
    

    func createDepartmentConversationWithAttributes(attributes:LTSDialogAttributes) {
        LTApiManager.sharedInstance.sdk!.requestWithDepartment(department?.departmentId, dialodAttributes: attributes,
                                                               success: { (dilogState:LTSDialogState!) -> Void in
                                                                self.instantiateFirstMessage()
            }, failure: { (error: NSException?) -> Void in
        })
    }
    
    func instantiateFirstMessage() {
        LTApiManager.sharedInstance.sdk!.sendMessage(self.messageView.text, success: { (message:LTSTextMessage!) -> Void in
            self.performSegueWithIdentifier("show_chat", sender: nil)
            self.navigationController?.viewControllers.removeAtIndex(self.navigationController!.viewControllers.count - 2)
            }, failure: { (error: NSException?) -> Void in
        })
    }
}
