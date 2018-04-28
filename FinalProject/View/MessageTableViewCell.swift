//
//  MessageTableViewCell.swift
//  FinalProject
//
//  Created by Junhao Huang on 4/18/18.
//  Copyright © 2018 Junhao Huang. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var messageBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
