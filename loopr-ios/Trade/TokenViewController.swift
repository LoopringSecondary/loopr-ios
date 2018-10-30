//
//  TradeViewOnlyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TokenViewController: UIViewController {

    var iconImageWidth: CGFloat = 40

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var totalPriceInFiatCurrency: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        
        iconImageView.contentMode = .scaleAspectFit
        
        iconView.isHidden = true
        iconView.backgroundColor = UIColor.clear
        
        titleLabel.textAlignment = .center
        titleLabel.font = FontConfigManager.shared.getCharactorFont(size: 13)
        titleLabel.theme_textColor = GlobalPicker.textColor

        amountLabel.textAlignment = .center
        amountLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        amountLabel.theme_textColor = GlobalPicker.textLightColor
        
        totalPriceInFiatCurrency.textAlignment = .center
        totalPriceInFiatCurrency.font = FontConfigManager.shared.getRegularFont(size: 13)
        totalPriceInFiatCurrency.theme_textColor = GlobalPicker.textLightColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let title = LocalizedString("Buy", comment: "")
            titleLabel.textColor = .success
            titleLabel.text = title + " " + symbol
        } else {
            let title = LocalizedString("Sell", comment: "")
            titleLabel.textColor = .fail
            titleLabel.text = title + " " + symbol
        }

        let length = MarketDataManager.shared.getDecimals(tokenSymbol: symbol)
        amountLabel.text = "\(amount.withCommas(length).trailingZero())"
        if let price = PriceDataManager.shared.getPrice(of: symbol) {
            let value: Double = price * amount
            totalPriceInFiatCurrency.text = value.currency
        } else {
            totalPriceInFiatCurrency.text = 0.0.currency
        }
        updateIcon(symbol: symbol)
    }

}
