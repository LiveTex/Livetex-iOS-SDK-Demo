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
    @IBOutlet weak var siteField: UITextField!
    @IBOutlet weak var keyField: UITextField!
    @IBOutlet weak var urlField: UITextField!
    
    var indexPathForSelectedRow: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            if cell?.accessoryType == UITableViewCellAccessoryType.checkmark {
                return
            } else {
                if indexPathForSelectedRow != nil {
                    let selectedCell = tableView.cellForRow(at: indexPathForSelectedRow!)
                    selectedCell?.accessoryType = UITableViewCellAccessoryType.none
                }
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                urlField.text = cell?.detailTextLabel?.text
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        URL = urlField.text
        key = keyField.text
        siteID = siteField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func resetCache(_ sender: UIBarButtonItem) {
        LCCoreService.resetService()
        UserDefaults.standard.removeObject(forKey: kLivetexVisitorName)
    }
}
