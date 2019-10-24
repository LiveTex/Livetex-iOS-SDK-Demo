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

    @IBOutlet private weak var nameField: UITextField!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        nameField.leftView = leftView
        nameField.leftViewMode = .always
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /* Получаем список назначений */
        LivetexCoreManager.defaultManager.coreService.destinations { destinations, error in
            if let err = error {
                print(err)
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
            LivetexCoreManager.defaultManager.coreService.setDestination(result.first!,
                                                                         attributes: attributes,
                                                                         options: [.deviceModel, .connectionType]) { success, error in
                if let err = error {
                    print(err)
                }
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
            let alert: UIAlertController = UIAlertController(title: "Ошибка", message: errorMessage, preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(cancelAction)
            present(alert, animated: true)
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
            let visitorName = nameField.text ?? ""
            LivetexCoreManager.defaultManager.coreService.setVisitor(visitorName) { success, error in
                if error == nil {
                    UserDefaults.standard.set(visitorName, forKey: kLivetexVisitorName)
                }
            }
            
            navigationController?.show(ChatViewController(), sender: nil)
        }
    }
}
