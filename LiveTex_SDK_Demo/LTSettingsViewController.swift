//
//  LTSettingsVeiwController.swift
//  LiveTex SDK
//
//  For Debugging
//  Created by Эмиль Абдуселимов on 04.03.16.
//  Copyright © 2016 LiveTex. All rights reserved.
//

import UIKit

class LTSettingsViewController: UITableViewController {

    @IBOutlet weak var siteField: UITextField!
    @IBOutlet weak var keyField: UITextField!
    @IBOutlet weak var urlField: UITextField!
    var indexPathForSelectedRow: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {
            return
        } else {
            if indexPathForSelectedRow != nil {
                let selectedCell = tableView.cellForRowAtIndexPath(indexPathForSelectedRow!)
                selectedCell?.accessoryType = UITableViewCellAccessoryType.None
            }
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            urlField.text = cell?.detailTextLabel?.text
            keyField.text = "demo"
            if indexPath.section == 0 {
                switch indexPath.row {
                case 0,
                     1:
                    siteField.text = "114744"
                case 2,
                     3:
                    siteField.text = "10019719"
                    
                default:
                    break
                }
            }
            
            indexPathForSelectedRow = indexPath
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        URL = urlField.text
        key = keyField.text
        siteID = siteField.text
    }
}
