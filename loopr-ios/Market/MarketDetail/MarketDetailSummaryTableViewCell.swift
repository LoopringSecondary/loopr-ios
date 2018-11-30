//
//  MarketDetailSummaryTableViewCell.swift
//  loopr-ios
//
//  Created by Ruby on 11/27/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var priceInCryptoLabel: UILabel!
    @IBOutlet weak var priceInFiatCurrencyLabel: UILabel!
    @IBOutlet weak var priceChangeIn24HoursLabel: UILabel!
    
    @IBOutlet weak var hoursChangeInfoLabelWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var hoursChangeInfoLabel: UILabel!
    @IBOutlet weak var hoursChangeLabel: UILabel!
    
    @IBOutlet weak var hoursVolumeInfoLabel: UILabel!
    @IBOutlet weak var hoursVolumeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        theme_backgroundColor = ColorPicker.backgroundColor
        
        baseView.cornerRadius = 6
        baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor

        priceInCryptoLabel.font = FontConfigManager.shared.getRegularFont(size: 16)
        priceInCryptoLabel.theme_textColor = GlobalPicker.textColor
        
        priceInFiatCurrencyLabel.font = FontConfigManager.shared.getRegularFont(size: 18)
        priceInFiatCurrencyLabel.theme_textColor = GlobalPicker.textColor
        priceInFiatCurrencyLabel.isHidden = true
        
        priceChangeIn24HoursLabel.font = FontConfigManager.shared.getRegularFont(size: 18)
        priceChangeIn24HoursLabel.theme_textColor = GlobalPicker.textColor
        priceChangeIn24HoursLabel.isHidden = true
        
        hoursChangeInfoLabel.text = LocalizedString("24H Change", comment: "") + ": "
        hoursChangeInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursChangeInfoLabel.theme_textColor = GlobalPicker.textColor
        
        hoursChangeLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursChangeLabel.theme_textColor = GlobalPicker.textColor
        
        hoursVolumeInfoLabel.text = LocalizedString("24H Volume", comment: "") + ": "
        hoursVolumeInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursVolumeInfoLabel.theme_textColor = GlobalPicker.textColor
        
        hoursVolumeLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursVolumeLabel.theme_textColor = GlobalPicker.textColor
    }
    
    func setup(market: Market) {
        priceInFiatCurrencyLabel.text = market.display.description
        priceChangeIn24HoursLabel.text = market.changeInPat24
        
        let hoursChangeWidth = hoursChangeInfoLabel.text!.widthOfString(usingFont: hoursChangeInfoLabel.font)
        let volumeChangeWidth = hoursChangeInfoLabel.text!.widthOfString(usingFont: hoursVolumeLabel.font)
        hoursChangeInfoLabelWidthLayoutConstraint.constant = max(hoursChangeWidth, volumeChangeWidth) + 10
        
        priceInCryptoLabel.text = "\(market.balanceWithDecimals) \(market.tradingPair.tradingB) ≈ \(market.display.description)"
        priceInCryptoLabel.textColor = UIStyleConfig.getChangeColor(change: market.changeInPat24)
        
        hoursChangeLabel.text = market.changeInPat24
        if market.volumeInPast24 > 1 {
            let vol = Darwin.round(market.volumeInPast24)
            hoursVolumeLabel.text = "\(vol.withCommas(0)) \(market.tradingPair.tradingB)"
        } else {
            hoursVolumeLabel.text = "\(market.volumeInPast24.withCommas()) \(market.tradingPair.tradingB)"
        }
    }
    
    class func getCellIdentifier() -> String {
        return "MarketDetailSummaryTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 120
    }
}
