//
//  SwitchTradeTokenTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SwitchTradeTokenTableViewCell: UITableViewCell {

    var token: Token?

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var enabledIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        accessoryType = .none
        theme_backgroundColor = ColorPicker.backgroundColor
        baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        iconView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        symbolLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        symbolLabel.theme_textColor = GlobalPicker.textColor
        balanceLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        balanceLabel.theme_textColor = GlobalPicker.textLightColor
        enabledIcon.image = UIImage(named: "enabled-dark")
        enabledIcon.contentMode = .center
        baseView.applyShadow()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            baseView.theme_backgroundColor = ColorPicker.cardHighLightColor
        } else {
            baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            baseView.theme_backgroundColor = ColorPicker.cardHighLightColor
        } else {
            // baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        }
    }

    func update() {
        if let token = token {
            let icon = UIImage(named: "Token-\(token.symbol)-\(Themes.getTheme())")
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
            let balance = CurrentAppWalletDataManager.shared.getBalance(of: token.symbol) ?? 0.0
            symbolLabel.text = "\(token.symbol)"
            balanceLabel.text = "\(balance)"
        }
    }

    class func getCellIdentifier() -> String {
        return "SwitchTradeTokenTableViewCell"
    }

    class func getHeight() -> CGFloat {
        return 68+8
    }

}
