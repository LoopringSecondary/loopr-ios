//
//  MarketDetailSummaryTableViewCell.swift
//  loopr-ios
//
//  Created by Ruby on 11/27/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailSummaryTableViewCell: UITableViewCell {

    var market: Market?
    
    // Base View
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var priceInCryptoLabel: UILabel!
    @IBOutlet weak var priceInFiatCurrencyLabel: UILabel!
    @IBOutlet weak var priceChangeIn24HoursLabel: UILabel!
    
    @IBOutlet weak var hoursChangeInfoLabelWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var hoursChangeInfoLabel: UILabel!
    @IBOutlet weak var hoursChangeLabel: UILabel!
    
    @IBOutlet weak var hoursVolumeInfoLabel: UILabel!
    @IBOutlet weak var hoursVolumeLabel: UILabel!
    
    // Highlight View
    @IBOutlet weak var highlightView: UIView!
    
    @IBOutlet weak var openInfoLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var emptyLabel1: UILabel!
    @IBOutlet weak var closeInfoLabel: UILabel!
    @IBOutlet weak var closeLabel: UILabel!
    
    @IBOutlet weak var highInfoLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowInfoLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    
    @IBOutlet weak var volInfoLabel: UILabel!
    @IBOutlet weak var volLabel: UILabel!
    @IBOutlet weak var changeInfoLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        theme_backgroundColor = ColorPicker.backgroundColor
        
        setupBaseView()
        setupHighlightView()
    }
    
    func setupBaseView() {
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
    
    func setupHighlightView() {
        highlightView.cornerRadius = 6
        highlightView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        
        openInfoLabel.text = LocalizedString("Open_in_chart_view", comment: "")
        openInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        openInfoLabel.theme_textColor = GlobalPicker.textLightColor
        
        openLabel.text = LocalizedString("", comment: "")
        openLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        openLabel.theme_textColor = GlobalPicker.textColor
        openLabel.textAlignment = .right
        
        closeInfoLabel.text = LocalizedString("Close_in_chart_view", comment: "")
        closeInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        closeInfoLabel.theme_textColor = GlobalPicker.textLightColor
        
        closeLabel.text = LocalizedString("", comment: "")
        closeLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        closeLabel.theme_textColor = GlobalPicker.textColor
        closeLabel.textAlignment = .right
        
        highInfoLabel.text = LocalizedString("High_in_chart_view", comment: "")
        highInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        highInfoLabel.theme_textColor = GlobalPicker.textLightColor
        
        highLabel.text = LocalizedString("", comment: "")
        highLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        highLabel.theme_textColor = GlobalPicker.textColor
        highLabel.textAlignment = .right
        
        lowInfoLabel.text = LocalizedString("Low_in_chart_view", comment: "")
        lowInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        lowInfoLabel.theme_textColor = GlobalPicker.textLightColor
        
        lowLabel.text = LocalizedString("", comment: "")
        lowLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        lowLabel.theme_textColor = GlobalPicker.textColor
        lowLabel.textAlignment = .right
        
        volInfoLabel.text = LocalizedString("Volume", comment: "")
        volInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        volInfoLabel.theme_textColor = GlobalPicker.textLightColor
        
        volLabel.text = LocalizedString("", comment: "")
        volLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        volLabel.theme_textColor = GlobalPicker.textColor
        volLabel.textAlignment = .right
        
        changeInfoLabel.text = LocalizedString("Change", comment: "")
        changeInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        changeInfoLabel.theme_textColor = GlobalPicker.textLightColor
        
        changeLabel.text = LocalizedString("", comment: "")
        changeLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        changeLabel.theme_textColor = GlobalPicker.textColor
        changeLabel.textAlignment = .right
    }
    
    func setup(market: Market) {
        self.baseView.isHidden = false
        self.highlightView.isHidden = true
        
        self.market = market

        priceInFiatCurrencyLabel.text = market.display.description
        priceChangeIn24HoursLabel.text = market.changeInPat24
        
        let hoursChangeWidth = hoursChangeInfoLabel.text!.widthOfString(usingFont: hoursChangeInfoLabel.font)
        let volumeChangeWidth = hoursChangeInfoLabel.text!.widthOfString(usingFont: hoursVolumeLabel.font)
        hoursChangeInfoLabelWidthLayoutConstraint.constant = max(hoursChangeWidth, volumeChangeWidth) + 10
        
        priceInCryptoLabel.text = "\(market.balanceWithDecimals) \(market.tradingPair.tradingB) ≈ \(market.display.description)"
        priceInCryptoLabel.textColor = UIStyleConfig.getChangeColor(change: market.changeInPat24)
        
        hoursChangeLabel.text = market.changeInPat24
        
        var tradeSymbol = market.tradingPair.tradingB
        if tradeSymbol == "WETH" {
            tradeSymbol = "ETH"
        }

        if market.volumeInPast24 > 1 {
            let vol = Darwin.round(market.volumeInPast24)
            hoursVolumeLabel.text = "\(vol.withCommas(0)) \(tradeSymbol)"
        } else {
            hoursVolumeLabel.text = "\(market.volumeInPast24.withCommas()) \(tradeSymbol)"
        }
    }
    
    func setHighlighted(trend: Trend) {
        self.baseView.isHidden = true
        self.highlightView.isHidden = false

        openLabel.text = trend.open.withCommas(8)
        closeLabel.text = trend.close.withCommas(8)
        
        highLabel.text = trend.high.withCommas(8)
        lowLabel.text = trend.low.withCommas(8)
        
        if trend.vol > 1 {
            let vol = Darwin.round(trend.vol)
            volLabel.text = "\(vol.withCommas(2))"
        } else {
            // TODO: the commas here looks like wired. Always get three digitals.
            volLabel.text = "\(trend.vol.withCommas(4))"
        }
        
        if market != nil {
            var tradeSymbol = market!.tradingPair.tradingB
            if tradeSymbol == "WETH" {
                tradeSymbol = "ETH"
            }
            volLabel.text = "\(volLabel.text!) \(tradeSymbol)"
        }
        
        changeLabel.text = trend.changeInString
        changeLabel.textColor = UIStyleConfig.getChangeColor(change: trend.changeInString)
    }
    
    class func getCellIdentifier() -> String {
        return "MarketDetailSummaryTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 120
    }
}
