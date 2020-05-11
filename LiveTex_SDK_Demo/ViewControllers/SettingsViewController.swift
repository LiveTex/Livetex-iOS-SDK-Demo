//
//  LTSettingsVeiwController.swift
//  LiveTex SDK
//
//  For Debugging
//  Created by Эмиль Абдуселимов on 04.03.16.
//  Copyright © 2016 LiveTex. All rights reserved.
//

import UIKit
import LivetexCore

class SettingsViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet private weak var siteField: UITextField!
    @IBOutlet private weak var keyField: UITextField!
    @IBOutlet private weak var urlField: UITextField!

    private let settings = Settings()

    // MARK: - UITableViewController

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            urlField.text = cell?.detailTextLabel?.text
            keyField.text = settings.key
            if indexPath.section == 0 {
                switch indexPath.row {
                case 0, 1:
                    siteField.text = "123280"
                case 2, 3:
                    siteField.text = "10023868"
                default:
                    break
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        settings.key = keyField.text ?? ""
        settings.path = urlField.text ?? ""
        settings.siteID = siteField.text ?? ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction private func resetCache(_ sender: UIBarButtonItem) {
        LCCoreService.resetService()
        settings.visitor = ""
    }
}
