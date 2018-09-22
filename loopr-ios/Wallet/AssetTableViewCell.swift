//
//  UpdatedAssetTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetTableViewCell: UITableViewCell {
    
    var asset: Asset?
    
    var baseView: UIView = UIView()
    var iconImageView: UIImageView = UIImageView()
    var iconView: IconView = IconView()
    
    var symbolLabel: UILabel = UILabel()
    var nameLabel: UILabel = UILabel()
    var balanceLabel: UILabel = UILabel()
    var amountLabel: UILabel = UILabel()
    
    var disclosureIndicator: UIImageView = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width

        theme_backgroundColor = ColorPicker.backgroundColor
        
        baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        baseView.frame = CGRect.init(x: 15, y: 4, width: screenWidth - 15*2, height: 68)
        baseView.cornerRadius = 6
        addSubview(baseView)
        baseView.applyShadow(withColor: UIColor.black)
        
        iconImageView.frame = CGRect.init(x: 20, y: 16, width: 36, height: 36)
        iconImageView.contentMode = .scaleAspectFit
        baseView.addSubview(iconImageView)
        
        iconView = IconView(frame: CGRect.init(x: 20, y: 16, width: 36, height: 36))
        iconView.backgroundColor = UIColor.clear
        baseView.addSubview(iconView)
        
        symbolLabel.frame = CGRect.init(x: 72, y: 16, width: 200, height: 17)
        symbolLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        symbolLabel.theme_textColor = GlobalPicker.textColor
        symbolLabel.text = "ETHETHETHETHETHETHETH"  // Prototype the label size. Will be updated very soon.
        symbolLabel.sizeToFit()
        symbolLabel.text = ""
        baseView.addSubview(symbolLabel)
        
        nameLabel.frame = CGRect.init(x: symbolLabel.frame.minX, y: 37, width: 200, height: 27)
        nameLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        nameLabel.theme_textColor = GlobalPicker.textLightColor
        nameLabel.text = "ETHETHETHETHETHETHETH"
        nameLabel.sizeToFit()
        nameLabel.text = ""
        baseView.addSubview(nameLabel)
        
        balanceLabel.frame = CGRect.init(x: baseView.frame.width - 49 - 200, y: symbolLabel.frame.minY, width: 200, height: symbolLabel.frame.size.height)
        balanceLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        balanceLabel.theme_textColor = GlobalPicker.textColor
        balanceLabel.textAlignment = .right
        baseView.addSubview(balanceLabel)
        
        amountLabel.frame = CGRect.init(x: balanceLabel.frame.minX, y: nameLabel.frame.minY, width: 200, height: nameLabel.frame.size.height)
        amountLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        amountLabel.theme_textColor = GlobalPicker.textLightColor
        amountLabel.textAlignment = .right
        baseView.addSubview(amountLabel)
        
        disclosureIndicator.frame = CGRect.init(x: baseView.frame.width - 24 - 15, y: (baseView.frame.height-24)/2, width: 24, height: 24)
        disclosureIndicator.theme_image = GlobalPicker.indicator
        disclosureIndicator.contentMode = .center
        baseView.addSubview(disclosureIndicator)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            baseView.theme_backgroundColor = ColorPicker.cardHighLightColor
        } else {
            baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        }
    }
    
    func update() {
        if let asset = asset {
            if asset.icon != nil {
                iconImageView.image = asset.icon
                iconImageView.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = asset.symbol
                iconView.symbolLabel.text = asset.symbol
                iconImageView.isHidden = true
            }
            symbolLabel.text = asset.symbol
            nameLabel.text = asset.name
            balanceLabel.text = asset.display
            amountLabel.text = asset.currency
        }
    }
    
    class func getCellIdentifier() -> String {
        return "UpdatedAssetTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 76
    }
}
