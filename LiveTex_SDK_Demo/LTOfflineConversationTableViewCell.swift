//
//  LTOfflineConversationTableViewCell.swift
//  LiveTex_SDK_Demo
//
//  Created by Сергей Девяткин on 6/6/15.
//  Copyright (c) 2015 LiveTex. All rights reserved.
//

import UIKit

class LTOfflineConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var conversationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
