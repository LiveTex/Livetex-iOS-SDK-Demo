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
        self.nameField.leftViewMode = UITextField.ViewMode.always
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /* Получаем список назначений */
        LivetexCoreManager.defaultManager.coreService.destinations { (destinations: [LCDestination]?, error: Error?) in
            if let error = error as NSError? {
                print(error)
                return
            }
            
            /* Из списка выбираем необходимый нам */
            var result = destinations!.filter({$0.department.departmentId == "42"})
            if result.count <= 0 {
                result = destinations!
            }
            
            /* Указываем пользовательские атрибуты обращения, которые отобразятся оператору */
            let attributes = LCDialogAttributes()
            attributes.visible = ["Field": "Test"]
            
            /* Указываем адресата обращения и дополнительно к пользовательским атрибутам укажем, чтобы передавались тип устройства и тип соединения */
            LivetexCoreManager.defaultManager.coreService.setDestination(result.first!, attributes: attributes, options: [.deviceModel, .connectionType], completionHandler: { (success: Bool, error: Error?) in
                if let error = error as NSError? {
                    print(error)
                }
            })
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
            let alert: UIAlertController = UIAlertController(title: "Ошибка", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func createConversation(_ sender: AnyObject) {
        if verifyFields() {
            /* Указываем имя собеседника */
            LivetexCoreManager.defaultManager.coreService.setVisitor(self.nameField.text!, completionHandler: { (success: Bool, error: Error?) in
                if error == nil {
                    UserDefaults.standard.set(self.nameField.text!, forKey: kLivetexVisitorName)
                }
            })
            
            self.navigationController?.show(ChatViewController(), sender: nil)
        }
    }
}
