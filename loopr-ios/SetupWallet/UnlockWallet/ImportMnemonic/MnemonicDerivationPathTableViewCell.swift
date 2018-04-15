//
//  MnemonicDerivationPathTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MnemonicDerivationPathTableViewCell: UITableViewCell {

    @IBOutlet weak var pathValueLabel: UILabel!
    @IBOutlet weak var pathDescriptionLabel: UILabel!
    
    @IBOutlet weak var seperateLine: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        pathValueLabel.font = FontConfigManager.shared.getLabelFont(size: 17)
        pathDescriptionLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14)
        pathDescriptionLabel.textColor = UIColor.black.withAlphaComponent(0.6)

        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getCellIdentifier() -> String {
        return "MnemonicDerivationPathTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 64
    }
}
