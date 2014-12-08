//
//  LTChatInMessageTableViewCell.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit

class LTChatMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var backgoundImage2: UIImageView!
    @IBOutlet weak var timeText: UILabel!
    
    var message:AnyObject!
    
    struct handy {
        
       static  var timeFormatter:NSDateFormatter! = NSDateFormatter()
    }
    
    var messageSet:AnyObject! {
        
        set (messageNew) {
            
            self.message = messageNew
            handy.timeFormatter.dateFormat = "hh:mm"
            
            if let massage = messageNew as? LTSTextMessage {
                
                self.messageText.text = massage.text
                
                let timestamp = (self.message.timestamp as NSString).doubleValue
                self.timeText.text = handy.timeFormatter.stringFromDate(NSDate(timeIntervalSince1970: NSTimeInterval(timestamp)))
            }
            
            if let massage = messageNew as? LTSFileMessage {
                
                self.messageText.text = massage.url

                let timestamp = (self.message.timestamp as NSString).doubleValue
                self.timeText.text = handy.timeFormatter.stringFromDate(NSDate(timeIntervalSince1970: NSTimeInterval(timestamp)))
            }

            layoutSubviews()
        }
        
        get {
            
            return self.message
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       self.backgoundImage2.image = self.backgoundImage2.image?.resizableImageWithCapInsets(UIEdgeInsetsMake(20, 20, 20, 20))
    }
    
    class func getSizeForText(text:String) -> Int {
        
        var spec = 24
        var rect:CGRect = (text as NSString).boundingRectWithSize(CGSize(width: 280, height: Int.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:[NSFontAttributeName : UIFont.systemFontOfSize(17.0)], context:nil)

        return Int(rect.size.height) + spec
    }
}
