//
//  LTSystemMessageTableViewCell.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 08/12/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit

class LTSystemMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
