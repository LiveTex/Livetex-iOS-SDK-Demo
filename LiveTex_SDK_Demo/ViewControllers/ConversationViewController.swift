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

    @IBOutlet private weak var nameField: UITextField!

    private let settings = Settings()

    private let departmentID = "42"

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = false

        receiveDestinations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Receive Destinations

    private func receiveDestinations() {
        /* Получаем список назначений */
        Livetex.shared.coreService.destinations { destinations, error in
            let destination = destinations?.first(where: { $0.department.departmentId == self.departmentID })
            guard let result = destination ?? destinations?.first else {
                return
            }

            /* Указываем пользовательские атрибуты обращения, которые отобразятся оператору */
            let attributes = LCDialogAttributes(visible: ["Field": "Test"], hidden: nil)

            /* Указываем адресата обращения и дополнительно к пользовательским атрибутам укажем, чтобы передавались тип устройства и тип соединения */
            Livetex.shared.coreService.setDestination(result,
                                                      attributes: attributes,
                                                      options: [.deviceModel, .connectionType]) { success, error in
                if let err = error {
                    print(err)
                }
            }
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

    // MARK: - Action
    
    @IBAction func createConversation() {
        guard let name = nameField.text, !name.isEmpty else {
            return
        }

        /* Указываем имя собеседника */
        Livetex.shared.coreService.setVisitor(name) { success, error in
            if error == nil {
                self.settings.visitor = name
            }
        }

        navigationController?.show(ChatViewController(), sender: nil)
    }
}
