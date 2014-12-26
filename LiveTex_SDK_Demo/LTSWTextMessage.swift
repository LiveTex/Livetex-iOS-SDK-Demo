//
//  LTSWTextMessage.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 23/12/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit

class LTSWTextMessage: NSObject {
    
    var sourcemessage:LTSTextMessage!
    var isConfirmed:Bool = false
    
    var messageId:String {
        
        get {
            
            return self.sourcemessage.messageId
        }
    }
    
    var text:String {
        get {
            return self.sourcemessage.text
        }
    }
    
    var timestamp:LTSTimestamp {
        
        get {
            return self.sourcemessage.timestamp
        }
    }
    
    var LTSEmployeeId:String {
        get {
            return self.sourcemessage.senderId
        }
    }
    
    func senderIsSet() -> Bool {
        return sourcemessage.senderIsSet()
    }
    
    init(sourceMessage:LTSTextMessage) {
        sourcemessage = sourceMessage
    }
}
