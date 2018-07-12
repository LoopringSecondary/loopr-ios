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
    @IBOutlet weak var addSwitch: UISwitch!
    @IBOutlet weak var seperateLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        symbolLabel.setTitleFont()
        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        addSwitch.transform = CGAffineTransform(scaleX: 0.81, y: 0.81)
        addSwitch.setOn(AuthenticationDataManager.shared.getPasscodeSetting(), animated: false)
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
            symbolLabel.text = "\(token.symbol)"

            if TokenDataManager.shared.getTokenList().contains(token.symbol) {
                addSwitch.setOn(true, animated: false)
            } else {
                addSwitch.setOn(false, animated: false)
            }
        }
    }
    
    @IBAction func toggledAddSwitch(_ sender: Any) {
        if addSwitch.isOn {
            print("toggledAddSwitch ON")
            TokenDataManager.shared.updateTokenList(tokenSymbol: token!.symbol, add: true)
        } else {
            print ("toggledAddSwitch OFF")
            TokenDataManager.shared.updateTokenList(tokenSymbol: token!.symbol, add: false)
        }
    }

    class func getCellIdentifier() -> String {
        return "AddTokenTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 72*UIStyleConfig.scale
    }
}
