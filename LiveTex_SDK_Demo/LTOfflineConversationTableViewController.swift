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
    var convList:[LTSOfflineConversation]?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(animated: Bool) {
        convList = []
        loadConversationList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convList!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LTOfflineConversationTableViewCell", forIndexPath: indexPath) as! LTOfflineConversationTableViewCell
        
        cell.employeeId = self.convList?[indexPath.row].currentOperatorId
        cell.date.text = self.convList?[indexPath.row].creationTime
        
        cell.date.text = cell.date.text?.stringByDeletingPathExtension
        
        if self.convList?[indexPath.row].lastMessage != "" {
            cell.conversationLabel.text = self.convList?[indexPath.row].lastMessage
        } else {
            cell.conversationLabel.text = "Нет текста сообщения"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        LTApiManager.sharedInstance.offlineConversationId = convList?[indexPath.row].conversationId
        self.performSegueWithIdentifier("offlineChatStart2", sender: nil)
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    @IBAction func listOffline(segue:UIStoryboardSegue) {
        
    }
}

extension LTOfflineConversationTableViewController {
    
    func loadConversationList() {
        
        LTApiManager.sharedInstance.sdk?.offlineConversationsListWithSuccess({ (array:[AnyObject]!) -> Void in
            
            self.convList = array as? [LTSOfflineConversation]
            
            for item in self.convList! {
                
                println("  convId = " + item.conversationId + "  operId = " + item.currentOperatorId + "\n")
            }
            
            self.tableView.reloadData()
            
            }, failure: { (exeption) -> Void in
                
                self.loadingErrorProcess(exeption)
        })
    }
}

extension LTOfflineConversationTableViewController {
    
    func showActivityIndicator() {
        
        activityView = DejalBezelActivityView(forView: self.view, withLabel: "Загрузка", width:100)
    }
    
    func removeActivityIndicator() {
        
        activityView?.animateRemove()
    }
    
    func loadingErrorProcess(error:NSException) {
        
        var asd = error.userInfo
        var error:NSError? = asd?["error"] as? NSError
        
        self.removeActivityIndicator()
        let alert: UIAlertView = UIAlertView(title: "Ошибка", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "ОК")
        alert.show()
    }
}
