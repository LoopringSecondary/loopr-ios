//
//  AssetBalanceTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetBalanceTableViewCell: UITableViewCell {

    var balanceLabel: TickerLabel = TickerLabel()
    var displayLabel: UILabel = UILabel()
    
    var asset: Asset?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        setupLabels()
        self.theme_backgroundColor = ["#fff", "#000"]
    }
    
    func setupLabels() {
        let padding: CGFloat = 10
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        balanceLabel = TickerLabel(frame: CGRect.init(x: padding, y: 26, width: screenWidth - padding*2, height: 23))
        balanceLabel.animationDuration = 0.25
        balanceLabel.textAlignment = NSTextAlignment.center
        balanceLabel.initializeLabel()
        balanceLabel.theme_backgroundColor = GlobalPicker.backgroundColor
        balanceLabel.textColor = Themes.isDark() ? UIColor.white : UIStyleConfig.defaultTintColor
        balanceLabel.setFont(FontConfigManager.shared.getRegularFont(size: 23))
        addSubview(balanceLabel)
        
        displayLabel = UILabel(frame: CGRect.init(x: padding, y: 58, width: screenWidth - padding*2, height: 16))
        displayLabel.textAlignment = .center
        displayLabel.font = FontConfigManager.shared.getRegularFont(size: 16)
        displayLabel.textColor = UIColor.init(white: 0, alpha: 0.6)
        addSubview(displayLabel)
    }

    func update() {
        if let asset = self.asset {
            balanceLabel.setText(asset.display, animated: false)
            displayLabel.text = asset.currency
        }
    }

    class func getCellIdentifier() -> String {
        return "AssetBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 93
    }
}
