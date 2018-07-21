//
//  SettingStyleTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/30/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingStyleTableViewCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var seperateLine: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        seperateLine.backgroundColor = UIColor.init(rgba: "#E5E7ED")

        leftLabel.textColor = UIColor.init(rgba: "#939BB1")
        // leftLabel.font = FontConfigManager.shared.getLabelSCFont(size: 14)
        
        rightLabel.textColor = UIColor.init(rgba: "#2F384C")
        // rightLabel.font = FontConfigManager.shared.getLabelSCFont(size: 14)
    }

    class func getCellIdentifier() -> String {
        return "SettingStyleTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 49
    }

}
