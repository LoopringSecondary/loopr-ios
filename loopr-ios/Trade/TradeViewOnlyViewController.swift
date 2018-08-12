//
//  TradeViewOnlyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeViewOnlyViewController: UIViewController {

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
        titleLabel.setTitleCharFont()
        
        amountLabel.textAlignment = .center
        amountLabel.setTitleDigitFont()
        
        totalPriceInFiatCurrency.textAlignment = .center
        totalPriceInFiatCurrency.setSubTitleDigitFont()
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
            let title = LocalizedString("Buying", comment: "")
            titleLabel.textColor = .success
            titleLabel.text = title + " " + symbol
        } else {
            let title = LocalizedString("Selling", comment: "")
            titleLabel.textColor = .fail
            titleLabel.text = title + " " + symbol
        }
        let length = Asset.getLength(of: symbol) ?? 4
        amountLabel.text = "\(amount.withCommas(length))"
        if let price = PriceDataManager.shared.getPrice(of: symbol) {
            let value: Double = price * amount
            totalPriceInFiatCurrency.text = value.currency
        } else {
            totalPriceInFiatCurrency.text = 0.0.currency
        }
        updateIcon(symbol: symbol)
    }

}
