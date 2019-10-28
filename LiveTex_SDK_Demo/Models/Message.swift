//
//  Message.swift
//  LiveTex SDK
//
//  Created by Emil Abduselimov on 26.10.2019.
//  Copyright © 2019 LiveTex. All rights reserved.
//

import UIKit
import MessageKit

struct Message: MessageType {

    let sender: SenderType
    let messageId: String
    let sentDate: Date
    let kind: MessageKind

}
