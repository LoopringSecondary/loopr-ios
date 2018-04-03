//
//  AddTokenTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AddTokenTableViewCell: UITableViewCell {
    
    var token: Token?

    // TODO: We may deprecate IBOutlet
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: IconView!

    @IBOutlet weak var symbolLabel: UILabel!

    @IBOutlet weak var seperateLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        symbolLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 17)

        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let token = token {
            let icon = UIImage(named: token.symbol) ?? nil
            if icon != nil {
                iconImageView.image = icon
                iconImageView.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = token.symbol
                iconView.symbolLabel.text = token.symbol
                iconImageView.isHidden = true
            }
            symbolLabel.text = "\(token.symbol) (\(token.source.capitalized))"
        }
    }

    class func getCellIdentifier() -> String {
        return "AddTokenTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 62
    }
}
