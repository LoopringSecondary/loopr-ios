//
//  AddMenuTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AddMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seperateLabel: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        backgroundColor = UIColor.black
        // iconImageView.contentMode = .
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14)
        seperateLabel.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1)
        selectedBackgroundView = bgColorView
    }

    class func getCellIdentifier() -> String {
        return "AddMenuTableViewCell"
    }
}
