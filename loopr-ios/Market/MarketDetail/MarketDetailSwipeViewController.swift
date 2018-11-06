//
//  MarketDetailSwipeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/28/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailSwipeViewController: SwipeViewController {
    
    var market: Market!

    private var types: [String] = []
    private var viewControllers: [UIViewController] = []

    let vc1 = MarketDetailDepthViewController()
    let vc2 = MarketDetailTradeHistoryViewController()
    var options = SwipeViewOptions.getDefault()

    @IBOutlet weak var baseView: UIView!

    @IBOutlet weak var priceInCryptoLabel: UILabel!
    @IBOutlet weak var priceInFiatCurrencyLabel: UILabel!
    @IBOutlet weak var priceChangeIn24HoursLabel: UILabel!
    
    @IBOutlet weak var hoursChangeInfoLabelWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var hoursChangeInfoLabel: UILabel!
    @IBOutlet weak var hoursChangeLabel: UILabel!
    
    @IBOutlet weak var hoursVolumeInfoLabel: UILabel!
    @IBOutlet weak var hoursVolumeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor

        self.topConstraint = 120
        types = [LocalizedString("Depth_in_Market_Detail", comment: ""), LocalizedString("Trades_in_Market_Detail", comment: "")]
        vc1.delegate = self
        viewControllers = [vc1, vc2]
        setupChildViewControllers()

        baseView.cornerRadius = 6
        baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        
        priceInCryptoLabel.font = FontConfigManager.shared.getRegularFont(size: 16)
        priceInCryptoLabel.theme_textColor = GlobalPicker.textColor

        priceInFiatCurrencyLabel.font = FontConfigManager.shared.getRegularFont(size: 18)
        priceInFiatCurrencyLabel.theme_textColor = GlobalPicker.textColor
        priceInFiatCurrencyLabel.text = market.display.description
        priceInFiatCurrencyLabel.isHidden = true

        priceChangeIn24HoursLabel.font = FontConfigManager.shared.getRegularFont(size: 18)
        priceChangeIn24HoursLabel.theme_textColor = GlobalPicker.textColor
        priceChangeIn24HoursLabel.text = market.changeInPat24
        priceChangeIn24HoursLabel.isHidden = true

        hoursChangeInfoLabel.text = LocalizedString("24H Change", comment: "") + ": "
        hoursChangeInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursChangeInfoLabel.theme_textColor = GlobalPicker.textLightColor

        hoursChangeLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursChangeLabel.theme_textColor = GlobalPicker.textLightColor

        hoursVolumeInfoLabel.text = LocalizedString("24H Volume", comment: "") + ": "
        hoursVolumeInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursVolumeInfoLabel.theme_textColor = GlobalPicker.textLightColor
        
        hoursVolumeLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursVolumeLabel.theme_textColor = GlobalPicker.textLightColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        setupChildViewControllers()
    }

    func setupChildViewControllers() {
        vc1.market = market
        vc1.getDataFromRelay()

        vc2.market = market
        vc2.getDataFromRelay()
        
        if Themes.isDark() {
            options.swipeTabView.itemView.textColor = UIColor(rgba: "#ffffff66")
            options.swipeTabView.itemView.selectedTextColor = UIColor(rgba: "#ffffffcc")
        } else {
            options.swipeTabView.itemView.textColor = UIColor(rgba: "#00000099")
            options.swipeTabView.itemView.selectedTextColor = UIColor(rgba: "#000000cc")
        }
        swipeView.reloadData(options: options)
    }
    
    // MARK: - DataSource
    override func numberOfPages(in swipeView: SwipeView) -> Int {
        return viewControllers.count
    }
    
    override func swipeView(_ swipeView: SwipeView, titleForPageAt index: Int) -> String {
        return types[index]
    }
    
    override func swipeView(_ swipeView: SwipeView, viewControllerForPageAt index: Int) -> UIViewController {
        return viewControllers[index]
    }

}

extension MarketDetailSwipeViewController: MarketDetailDepthViewControllerDelegate {
    func pushWithSelectedDepth(amount: String, price: String, tradeType: TradeType) {
        let viewController = BuyAndSellSwipeViewController()
        viewController.market = market
        viewController.initialType = tradeType
        viewController.initialPrice = price
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
