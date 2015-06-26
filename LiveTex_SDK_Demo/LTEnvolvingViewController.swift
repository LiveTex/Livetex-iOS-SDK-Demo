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
    @IBOutlet weak var modeField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var subSelectionField: UITextField!
    @IBOutlet weak var showingKeyBoardAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet var subSelectionHidingConstraints: [NSLayoutConstraint]!
    
    var activityView:DejalBezelActivityView?
    
    var currentMode: String!
    
    var subSelectionitems:Array<AnyObject>!
    var selectedSubSelectionItem:AnyObject?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        currentMode = mods.0
        setupSubSelection()
    }
    
    @IBAction func createConversation(sender: AnyObject) {
        
        if(self.isWhiteSpaceString(self.messageField.text)) {
            let alert: UIAlertView = UIAlertView(title: "", message: "Введите первое сообщение", delegate: nil, cancelButtonTitle: "ОК")
            alert.show()
        } else {
            createConversation()
        }
    }
    
    @IBAction func subSelection(sender: AnyObject) {
        
        loadAndShowSubSelectionItems()
    }
    
    @IBAction func dismissKeyBoard(sender: AnyObject) {
        nameField.resignFirstResponder()
        ageField.resignFirstResponder()
        messageField.resignFirstResponder()
    }
}

extension LTEnvolvingViewController {
    
    func createConversation() {
        
        self.showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk!.setVisitorName(nameField.text, success: { () -> Void in
            
            var attr = LTSDialogAttributes()
            attr.visible = LTSOptions(dictionary: ["livetex_id":self.ageField.text])
            attr.hidden = LTSOptions(dictionary: ["platform": "ios"])
            self.creatConversationForCurrentModeWithAtributes(attr)
            
            }) { (error:NSException!) -> Void in
                
                self.loadingErrorProcess(error)
        }
    }
    
    func creatConversationForCurrentModeWithAtributes(attributes:LTSDialogAttributes) {
        
        createDepartmentConversationWithAttributes(attributes)
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
            
            }, failure: { (error:NSException!) -> Void in
                
                self.loadingErrorProcess(error)
        })
    }
}

extension LTEnvolvingViewController {
    
    func loadAndShowSubSelectionItems() {
        
        showActivityIndicator()
        
        LTApiManager.sharedInstance.sdk!.getDepartments(statusType.online, success: { (items:[AnyObject]!) -> Void in
            
            if (items.count == 0) {
                let alert: UIAlertView = UIAlertView(title: "", message:"Нет департаментов онлайн", delegate: nil, cancelButtonTitle: "ОК")
                alert.show()
            } else {
                
                self.showSubSelectionItemsSheet(items)
            }
            self.removeActivityIndicator()
            
            }) { (error:NSException!) -> Void in
                
                self.loadingErrorProcess(error)
        }
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

extension LTEnvolvingViewController {
    
}

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

extension LTEnvolvingViewController {
    
    func setupSubSelection() {
        
        subSelectionField.text = nil
        subSelectionField.placeholder = "Выберите отдел"
    }
    
    func setupSubSelectionFieldText () {
        
        let department = selectedSubSelectionItem as! LTSDepartment
        subSelectionField.text = department.name
    }
    
    func isWhiteSpaceString(str:String) -> Bool {
        
        (str as NSString).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if str == "" {
            return true
        }
        else {
            return false
        }
    }
    
    func showActivityIndicator() {
        
        activityView = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
    }
    
    func removeActivityIndicator() {
        
        activityView?.animateRemove()
    }
    
    func loadingErrorProcess(error:NSException) {
        
        self.removeActivityIndicator()
        let alert: UIAlertView = UIAlertView(title: "ошибка", message: error.description, delegate: nil, cancelButtonTitle: "ОК")
        alert.show()
    }
}

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
