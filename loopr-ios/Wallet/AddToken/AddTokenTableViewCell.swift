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

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addSwitch: UISwitchCustom!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        baseView.cornerRadius = 6
        baseView.clipsToBounds = true
        baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        
        theme_backgroundColor = ColorPicker.backgroundColor
        
        iconView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        symbolLabel.setTitleDigitFont()
        nameLabel.setSubTitleDigitFont()

        addSwitch.transform = CGAffineTransform(scaleX: 0.77, y: 0.77)
        addSwitch.onTintColor = UIColor.themeYellow
        addSwitch.OffTint = UIColor.dark4
    }

    func update() {
        if let token = token {
            if token.icon != nil {
                iconImageView.image = token.icon!
                iconImageView.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconImageView.isHidden = true
            }
            iconView.symbol = token.symbol
            iconView.symbolLabel.text = token.symbol
            symbolLabel.text = "\(token.symbol)"
            nameLabel.text = token.source

            if CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.getTokenList().contains(token.symbol) {
                addSwitch.setOn(true, animated: false)
            } else {
                addSwitch.setOn(false, animated: false)
            }
        }
    }
    
    @IBAction func toggledAddSwitch(_ sender: Any) {
        if addSwitch.isOn {
            print("toggledAddSwitch ON")
            CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.updateTokenList([token!.symbol], add: true)
        } else {
            print ("toggledAddSwitch OFF")
            CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.updateTokenList([token!.symbol], add: false)
        }
    }

    class func getCellIdentifier() -> String {
        return "AddTokenTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 68+8
    }
}
