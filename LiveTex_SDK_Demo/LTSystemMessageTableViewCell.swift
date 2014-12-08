//
//  LTSystemMessageTableViewCell.swift
//  LiveTex_SDK_Demo
//
//  Created by Sergey on 08/12/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

import UIKit

class LTSystemMessageTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var messageTextLabel: UILabel!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
