//
//  LTOfflineConversationTableViewController.swift
//  LiveTex_SDK_Demo
//
//  Created by Сергей Девяткин on 6/6/15.
//  Copyright (c) 2015 LiveTex. All rights reserved.
//

import UIKit

class LTOfflineConversationTableViewController: UITableViewController {
    
    var activityView:DejalBezelActivityView?
    var convList:[LTSOfflineConversation] = []
   
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(animated: Bool) {
        presentData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(convList.count > 0) {
            self.emptyLabel.hidden = true
        }
        return convList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        
        self.configure(cell: cell, atIndexPath: indexPath);
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        LTApiManager.sharedInstance.offlineConversationId = convList[indexPath.row].conversationId
        self.performSegueWithIdentifier("offlineChatStart2", sender: nil)
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func configure(cell cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        LTApiManager.sharedInstance.sdk?.getEmployees(statusType.all, success: { (items:[AnyObject]!) -> Void in
            
            let employees = items as! [LTSEmployee]
            
            for Employee in employees {
                
                if (Employee.employeeId == self.convList[indexPath.row].currentOperatorId) {
                    
                    let url = NSURL(string: Employee.avatar)
                    // var err: NSError?
                    
                    let imageData :NSData = NSData(contentsOfURL:url!)!
                    
                    let bgImage = UIImage(data:imageData)
                    cell.imageView?.image = bgImage
                    cell.setNeedsLayout()
                }
            }
            
            }, failure: { (exeption) -> Void in
                //
        })
        
        let newDate = (self.convList[indexPath.row].creationTime as String).componentsSeparatedByString(" ")[0]
        let parts = newDate.componentsSeparatedByString("-")
        var date1 = ""
        for index in (1...3).reverse() {
            date1 += parts[index-1]
            if(index != 1) {
                date1 += ".";
            }
        }
        cell.textLabel!.text = date1
        
        //cell.date.text = cell.date.text?.stringByDeletingPathExtension
        
        if self.convList[indexPath.row].lastMessage != "" {
            cell.detailTextLabel!.text = self.convList[indexPath.row].lastMessage
        } else {
            cell.detailTextLabel!.text = "Нет текста сообщения"
        }

    }
    
    @IBAction func listOffline(segue:UIStoryboardSegue) {
        
    }
}


//MARK: business Flow

extension LTOfflineConversationTableViewController {
    
    func presentData() {
        
        LTApiManager.sharedInstance.sdk?.offlineConversationsListWithSuccess({ (array:[AnyObject]!) -> Void in
            
            self.convList = (array as? [LTSOfflineConversation])!
            self.tableView.reloadData()
            
            }, failure: { (exeption) -> Void in
                
                self.loadingErrorProcess(exeption)
        })
    }
}

//MARK: helpers

extension LTOfflineConversationTableViewController {
    
    func showActivityIndicator() {
        
        activityView = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
    }
    
    func removeActivityIndicator() {
        
        activityView?.animateRemove()
    }
    
    func loadingErrorProcess(error:NSException) {
        
        var asd = error.userInfo
        let error:NSError? = asd?["error"] as? NSError
        
        self.removeActivityIndicator()
        UIAlertView(title: "Ошибка", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "ОК").show()
    }
}
