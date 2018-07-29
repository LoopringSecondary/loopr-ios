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

    var options = SwipeViewOptions()

    @IBOutlet weak var baseView: UIView!

    @IBOutlet weak var priceInCryptoLabel: UILabel!
    @IBOutlet weak var priceInFiatCurrencyLabel: UILabel!
    @IBOutlet weak var priceChangeIn24HoursLabel: UILabel!
    @IBOutlet weak var hoursChangeInfoLabel: UILabel!
    @IBOutlet weak var hoursChangeLabel: UILabel!
    @IBOutlet weak var hoursHighInfoLabel: UILabel!
    @IBOutlet weak var hoursHighLabel: UILabel!
    @IBOutlet weak var hoursVolumeInfoLabel: UILabel!
    @IBOutlet weak var hoursVolumeLabel: UILabel!
    @IBOutlet weak var hoursLowInfoLabel: UILabel!
    @IBOutlet weak var hoursLowLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor

        self.topConstraint = 180
        setupChildViewControllers()

        baseView.cornerRadius = 6
        baseView.applyGradient(withColors: UIColor.secondary, gradientOrientation: .horizontal)
        
        priceInCryptoLabel.font = FontConfigManager.shared.getDigitalFont()
        priceInCryptoLabel.textColor = UIColor.init(white: 1, alpha: 1)
        priceInCryptoLabel.text = market.balance.withCommas(6)
        
        priceInFiatCurrencyLabel.font = FontConfigManager.shared.getDigitalFont()
        priceInFiatCurrencyLabel.textColor = UIColor.init(white: 1, alpha: 1)
        priceInFiatCurrencyLabel.text = market.display.description

        priceChangeIn24HoursLabel.font = FontConfigManager.shared.getDigitalFont()
        priceChangeIn24HoursLabel.textColor = UIColor.init(white: 1, alpha: 1)
        priceChangeIn24HoursLabel.text = market.changeInPat24
        
        hoursChangeInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursChangeInfoLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        hoursChangeInfoLabel.text = LocalizedString("24H Change", comment: "")
        
        hoursChangeLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        hoursChangeLabel.textColor = UIColor.init(white: 1, alpha: 0.8)
        hoursChangeLabel.text = LocalizedString("0.000092350", comment: "")
        
        hoursHighInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursHighInfoLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        hoursHighInfoLabel.text = LocalizedString("24H High", comment: "")
        
        hoursHighLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        hoursHighLabel.textColor = UIColor.init(white: 1, alpha: 0.8)
        hoursHighLabel.text = LocalizedString("0.000092350", comment: "")
        
        hoursVolumeInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursVolumeInfoLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        hoursVolumeInfoLabel.text = LocalizedString("24H Volume", comment: "")
        
        hoursVolumeLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        hoursVolumeLabel.textColor = UIColor.init(white: 1, alpha: 0.8)
        hoursVolumeLabel.text = "\(market.volumeInPast24) WETH"
        
        hoursLowInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hoursLowInfoLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        hoursLowInfoLabel.text = LocalizedString("24H Low", comment: "")
        
        hoursLowLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        hoursLowLabel.textColor = UIColor.init(white: 1, alpha: 0.8)
        hoursLowLabel.text = LocalizedString("0.000085800", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupChildViewControllers() {
        types = ["Depth", "Trade"]
        
        let vc1 = MarketDetailDepthViewController()
        let vc2 = MarketDetailTradeHistoryViewController()
        viewControllers = [vc1, vc2]
        
        options.swipeTabView.underlineView.height = 2
        options.swipeTabView.underlineView.margin = 20
        options.swipeContentScrollView.isScrollEnabled = false
        options.swipeTabView.style = .segmented
        
        options.swipeTabView.height = 50
        options.swipeTabView.underlineView.height = 2
        // options.swipeTabView.underlineView.margin = 30
        
        options.swipeTabView.style = .segmented
        options.swipeTabView.itemView.font = FontConfigManager.shared.getMediumFont(size: 16)
        
        if Themes.isDark() {
            options.swipeTabView.itemView.textColor = UIColor.init(white: 0.5, alpha: 1)
            options.swipeTabView.itemView.selectedTextColor = UIColor.white
        } else {
            options.swipeTabView.itemView.textColor = UIColor.init(white: 0.5, alpha: 1)
            options.swipeTabView.itemView.selectedTextColor = UIColor.black
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
