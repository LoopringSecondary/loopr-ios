//
//  TradeTokenView.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

@IBDesignable class TradeTokenView: UIView {
    
    var iconImageWidth: CGFloat = 40
    var titleLabel: UILabel
    var iconImageView: UIImageView
    var iconView: IconView
    var amountLabel: UILabel
    var totalPriceInFiatCurrency: UILabel
    
    override init(frame: CGRect) {

        iconImageView = UIImageView(frame: CGRect(x: 0, y: 10, width: frame.width, height: iconImageWidth*UIStyleConfig.scale))
        iconImageView.contentMode = .scaleAspectFit

        iconView = IconView(frame: CGRect(x: 0, y: 10, width: frame.width, height: iconImageWidth*UIStyleConfig.scale))
        iconView.isHidden = true
        iconView.backgroundColor = UIColor.clear
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: iconImageView.frame.maxY + 16, width: frame.width, height: 40*UIStyleConfig.scale))
        titleLabel.textAlignment = .center
        titleLabel.setTitleCharFont()

        amountLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.maxY, width: frame.width, height: 40*UIStyleConfig.scale))
        amountLabel.textAlignment = .center
        amountLabel.setTitleDigitFont()
        
        totalPriceInFiatCurrency = UILabel(frame: CGRect(x: 0, y: amountLabel.frame.maxY - 16, width: frame.width, height: 40*UIStyleConfig.scale))
        totalPriceInFiatCurrency.textAlignment = .center
        totalPriceInFiatCurrency.setSubTitleDigitFont()

        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(iconImageView)
        addSubview(iconView)
        addSubview(amountLabel)
        addSubview(totalPriceInFiatCurrency)
    }
    
    func updateIcon(symbol: String) {
        let icon = UIImage(named: "Token-\(symbol)-\(Themes.getTheme())") ?? nil
        if icon != nil {
            iconImageView.image = icon
            iconImageView.isHidden = false
            iconView.isHidden = true
        } else {
            iconView.isHidden = false
            iconView.symbol = symbol
            iconView.symbolLabel.text = symbol
            iconImageView.isHidden = true
        }
    }

    // Used in ConvertETHViewController
    func update(symbol: String) {
        amountLabel.text = symbol
        updateIcon(symbol: symbol)
        totalPriceInFiatCurrency.isHidden = true
    }

    // Used in Trade
    func update(type: TradeType, symbol: String, amount: Double) {
        if type == .buy {
            titleLabel.textColor = .success
            titleLabel.text = LocalizedString("You are buying", comment: "")
        } else {
            titleLabel.textColor = .fail
            titleLabel.text = LocalizedString("You are selling", comment: "")
        }
        let length = Asset.getLength(of: symbol) ?? 4
        amountLabel.text = "\(amount.withCommas(length)) \(symbol)"
        if let price = PriceDataManager.shared.getPrice(of: symbol) {
            let value: Double = price * amount
            totalPriceInFiatCurrency.text = value.currency
        } else {
            totalPriceInFiatCurrency.text = 0.0.currency
        }
        updateIcon(symbol: symbol)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
