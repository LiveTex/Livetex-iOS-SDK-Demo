//
//  LTOfflineConversationTableViewCell.swift
//  LiveTex_SDK_Demo
//
//  Created by Сергей Девяткин on 6/6/15.
//  Copyright (c) 2015 LiveTex. All rights reserved.
//

import UIKit

class LTOfflineConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var conversationLabel: UILabel!
    
    var employeeId:String? {
        
        set {
            
            LTApiManager.sharedInstance.sdk?.getEmployees(statusType.all, success: { (items:[AnyObject]!) -> Void in
                
                let employees = items as! [LTSEmployee]
                
                for Employee in employees {
                    
                    if (Employee.employeeId == newValue) {
                        
                            let url = NSURL(string: Employee.avatar)
                            var err: NSError?
                            var imageData :NSData = NSData(contentsOfURL:url!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)!
            
                            var bgImage = UIImage(data:imageData)
                            self.photo.image = bgImage
                    }
                }
                
            }, failure: { (exeption) -> Void in
              //
            })
        }
        
        get {
            
            return nil
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        photo.layer.borderWidth = 2.0
        photo.layer.borderColor = UIColor.whiteColor().CGColor
        photo.clipsToBounds = true
        photo.layer.cornerRadius = 20.0
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
