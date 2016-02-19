//
//  LTEnvolvingViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import Foundation
import UIKit

let mods = (siteMode:"Сайт", departmentsMode:"Департамент", epmloyeesMode:"Оператор")
let actionSheetType = (actionSheetModeSelection:88, actionSheetSubSelection:87)
let statusType = (online:"online", offline:"offline", all:"all")

class LTEnvolvingViewController: UIViewController {
    
    @IBOutlet weak var messagePlaceHolder: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var subSelectionField: UITextField!

    var activityView:DejalBezelActivityView?
    var currentMode:String!
    var subSelectionitems:Array<AnyObject>!
    var selectedSubSelectionItem:AnyObject?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        setupSubSelection()
    }
}

//MARK: targetActionsFlow

extension LTEnvolvingViewController {
    
    @IBAction func createConversation(sender: AnyObject) {
        
        if(CommonUtils.isWhiteSpaceString(self.messageField.text)) {
            UIAlertView(title: "", message: "Введите текст сообщения", delegate: nil, cancelButtonTitle: "ОК").show()
        } else {
            createConversation()
        }
    }
    
    @IBAction func subSelection(sender: AnyObject) {
        dismissKeyBoard(sender)
        loadAndShowSubSelectionItems()
    }
    
    @IBAction func dismissKeyBoard(sender: AnyObject) {
        nameField.resignFirstResponder()
        ageField.resignFirstResponder()
        messageField.resignFirstResponder()
    }
}

//MARK: createConversationFlow

extension LTEnvolvingViewController {
    
    func createConversation() {
        
        self.showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk!.setVisitorName(nameField.text, success: { () -> Void in
            
            let attr = LTSDialogAttributes()
            attr.visible = LTSOptions(dictionary: ["livetex_id":self.ageField.text!])
            attr.hidden = LTSOptions(dictionary: ["platform": "ios"])
            self.createDepartmentConversationWithAttributes(attr)
            
        }, failure: { (error:NSException!) -> Void in
                
            self.loadingErrorProcess(error)
        })
    }
    
    func createDepartmentConversationWithAttributes(attributes:LTSDialogAttributes) {
        
        let department = self.selectedSubSelectionItem as! LTSDepartment?
        
        LTApiManager.sharedInstance.sdk!.requestWithDepartment(department?.departmentId,
            dialodAttributes: attributes,
            success: { (dilogState:LTSDialogState!) -> Void in
                
                self.instantiateFirstMessage()
                
            }, failure: { (error:NSException!) -> Void in
                
                self.loadingErrorProcess(error)
        })
    }
    
    func instantiateFirstMessage() {
        
        LTApiManager.sharedInstance.sdk!.sendMessage(self.messageField.text, success: { (message:LTSTextMessage!) -> Void in
            self.removeActivityIndicator()
            self.performSegueWithIdentifier("showChat", sender: nil)
            self.navigationController?.viewControllers.removeAtIndex(self.navigationController!.viewControllers.count - 2)
        }, failure: { (error:NSException!) -> Void in
            self.loadingErrorProcess(error)
        })
    }
}

//MARK: subSelectionFlow

extension LTEnvolvingViewController {
    
    func setupSubSelection() {
        
        subSelectionField.text = nil
        subSelectionField.placeholder = "Выберите отдел"
        
        messageField.layer.borderWidth = 0.4
        messageField.layer.cornerRadius = 6.0
        messageField.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    func loadAndShowSubSelectionItems() {
        
        showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk!.getDepartments(statusType.online, success: { (items:[AnyObject]!) -> Void in
            
            if (items.count == 0) {
                UIAlertView(title: "", message:"Нет департаментов онлайн", delegate: nil, cancelButtonTitle: "ОК").show()
            } else {
                
                self.showSubSelectionItemsSheet(items)
            }
            self.removeActivityIndicator()
            
        }, failure: { (error:NSException!) -> Void in
                
            self.loadingErrorProcess(error)
        })
    }
    
    func showSubSelectionItemsSheet(items:[AnyObject]!) {
        
        self.subSelectionitems = items
        
        let sheetTable:UIActionSheet = UIActionSheet()
        sheetTable.tag = actionSheetType.actionSheetSubSelection
        sheetTable.delegate = self
        
        for item in self.subSelectionitems {
            
            let department = item as! LTSDepartment
            sheetTable.addButtonWithTitle(department.name)
        }
        
        let index = sheetTable.addButtonWithTitle("Отмена")
        sheetTable.cancelButtonIndex = index;
        sheetTable.showInView(self.view)
    }
}

//MARK: UIActionSheetDelegate

extension LTEnvolvingViewController: UIActionSheetDelegate {
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex != actionSheet.cancelButtonIndex {
            if actionSheet.tag == actionSheetType.actionSheetSubSelection {
                
                self.selectedSubSelectionItem = subSelectionitems[buttonIndex]
                setupSubSelectionFieldText()
            }
        }
    }
}

//MARK: heplers

extension LTEnvolvingViewController {
    
    func setupSubSelectionFieldText () {
        
        let department = selectedSubSelectionItem as! LTSDepartment
        subSelectionField.text = department.name
    }
    
    func showActivityIndicator() {
        
        activityView = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
    }
    
    func removeActivityIndicator() {
        
        activityView?.animateRemove()
    }
    
    func loadingErrorProcess(error:NSException) {
        self.removeActivityIndicator()
        let alert: UIAlertController = UIAlertController(title: "Ошибка", message: (error.userInfo!["error"] as! NSError).localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

//MARK: UITextFieldDelegates

extension LTEnvolvingViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
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
