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
    
    private var indexPathForSelectedRow: IndexPath?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - UITableViewController

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            guard let cell = tableView.cellForRow(at: indexPath),
                  cell.accessoryType == .none else {
                return
            }

            cell.accessoryType = .checkmark
            if let indexPath = indexPathForSelectedRow {
                let selectedCell = tableView.cellForRow(at: indexPath)
                selectedCell?.accessoryType = .none
            }

            cell.accessoryType = .checkmark
            urlField.text = cell.detailTextLabel?.text
            keyField.text = "demo"
            if indexPath.section == 0 {
                switch indexPath.row {
                case 0,
                     1:
                    siteField.text = "123280"
                case 2,
                     3:
                    siteField.text = "10023868"
                default:
                    break
                }
            }

            indexPathForSelectedRow = indexPath
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        url = urlField.text
        key = keyField.text
        siteID = siteField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction private func resetCache(_ sender: UIBarButtonItem) {
        LCCoreService.resetService()
        UserDefaults.standard.removeObject(forKey: kLivetexVisitorName)
    }
}
