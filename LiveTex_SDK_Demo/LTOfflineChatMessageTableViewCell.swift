//
//  LTChatInMessageTableViewCell.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 12/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit
import Darwin

class LTOfflineChatMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var backgoundImage2: UIImageView!
    @IBOutlet weak var timeText: UILabel!
    @IBOutlet weak var messgaeConfirmedIco: UIImageView?
    
    var message:AnyObject!
    
    struct handy {
        
       static  var timeFormatter:NSDateFormatter! = NSDateFormatter()
    }
    
    var messageSet:AnyObject! {
        
        set (messageNew) {
            
            self.message = messageNew
            handy.timeFormatter.dateFormat = "hh:mm"
            
            if let massage = messageNew as? LTSOfflineMessage {
                
                if massage.url != nil {
                    self.messageText.text = "Отправлен файл: " + massage.url
                } else {
                    self.messageText.text = massage.message
                }
                
                let time:NSString = message.creationTime
                self.timeText.text = time.substringWithRange(NSRange(location: 10, length: 6))
                self.messgaeConfirmedIco?.hidden = true
            }
            
            layoutSubviews()
            
        } get {
            
            return self.message
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgoundImage2.image = self.backgoundImage2.image?.resizableImageWithCapInsets(UIEdgeInsetsMake(15, 20, 15, 20))
    }
    
    
    class func getSizeForText(text:String) -> Double {
        
        var spec:Double = 24.0
        var rect:CGRect = (text as NSString).boundingRectWithSize(CGSize(width: 250, height: DBL_MAX), options: (NSStringDrawingOptions.UsesLineFragmentOrigin), attributes:[NSFontAttributeName : UIFont.systemFontOfSize(17.0)], context:nil)

        return Double(rect.size.height) + spec
    }
}
