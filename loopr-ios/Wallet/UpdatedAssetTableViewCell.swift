//
//  UpdatedAssetTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class UpdatedAssetTableViewCell: UITableViewCell {
    
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

        theme_backgroundColor = GlobalPicker.tableViewBackgroundColor // UIStyleConfig.tableViewBackgroundColor
        baseView.theme_backgroundColor = GlobalPicker.backgroundColor
        baseView.frame = CGRect.init(x: 10, y: 10, width: screenWidth - 10*2, height: UpdatedAssetTableViewCell.getHeight() - 10)
        addSubview(baseView)
        
        iconImageView.frame = CGRect.init(x: 15, y: 22, width: 36, height: 36)
        iconImageView.contentMode = .scaleAspectFit
        baseView.addSubview(iconImageView)
        
        iconView = IconView(frame: CGRect.init(x: 15, y: 22, width: 36, height: 36))
        iconView.backgroundColor = UIColor.clear
        baseView.addSubview(iconView)
        
        symbolLabel.frame = CGRect.init(x: 60, y: 22-3, width: 200, height: 35)
        symbolLabel.setTitleFont()
        symbolLabel.text = "ETHETHETHETHETHETHETH"  // Prototype the label size. Will be updated very soon.
        symbolLabel.sizeToFit()
        symbolLabel.text = ""
        baseView.addSubview(symbolLabel)
        
        nameLabel.frame = CGRect.init(x: symbolLabel.frame.minX, y: 44-3, width: 200, height: 27)
        nameLabel.setSubTitleFont()
        nameLabel.text = "ETHETHETHETHETHETHETH"
        nameLabel.sizeToFit()
        nameLabel.text = ""
        baseView.addSubview(nameLabel)
        
        balanceLabel.frame = CGRect.init(x: baseView.frame.width - 36 - 200, y: symbolLabel.frame.minY, width: 200, height: symbolLabel.frame.size.height)
        balanceLabel.setTitleFont()
        balanceLabel.textAlignment = .right
        baseView.addSubview(balanceLabel)
        
        amountLabel.frame = CGRect.init(x: balanceLabel.frame.minX, y: nameLabel.frame.minY, width: 200, height: nameLabel.frame.size.height)
        amountLabel.setSubTitleFont()
        amountLabel.textAlignment = .right
        baseView.addSubview(amountLabel)
        
        disclosureIndicator.frame = CGRect.init(x: baseView.frame.width - 36/2 - 16/2, y: (baseView.frame.height-16)/2, width: 16, height: 16)
        disclosureIndicator.image = UIImage.init(named: "Default_disclosureIndicator")
        disclosureIndicator.contentMode = .center
        baseView.addSubview(disclosureIndicator)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            baseView.backgroundColor = UIStyleConfig.tableCellSelectedBackgroundColor
        } else {
            baseView.theme_backgroundColor = GlobalPicker.backgroundColor
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
        return 90
    }
}
