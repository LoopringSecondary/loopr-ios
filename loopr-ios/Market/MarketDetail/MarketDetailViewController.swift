//
//  MarketDetailSwipeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/28/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailViewController: UIViewController {

    var market: Market!
    var marketDetailSwipeViewController = MarketDetailSwipeViewController()
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    let buttonInNavigationBar =  UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        setBackButton()
        setup()
        updateHistoryButton()

        // Buy button
        buyButton.setTitle(LocalizedString("Buy", comment: "") + " " + market.tradingPair.tradingA, for: .normal)
        buyButton.setupPrimary(height: 44)
        
        // Sell button
        sellButton.setTitle(LocalizedString("Sell", comment: "") + " " + market.tradingPair.tradingA, for: .normal)
        sellButton.setupSecondary(height: 44)
        
        marketDetailSwipeViewController.market = market
        addChildViewController(marketDetailSwipeViewController)
        view.addSubview(marketDetailSwipeViewController.view)
        marketDetailSwipeViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: marketDetailSwipeViewController.view, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: marketDetailSwipeViewController.view, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: marketDetailSwipeViewController.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: marketDetailSwipeViewController.view, attribute: .bottom, relatedBy: .equal, toItem: buyButton, attribute: .top, multiplier: 1.0, constant: -5.0).isActive = true
        
        buttonInNavigationBar.frame = CGRect(x: 0, y: 0, width: 400, height: 40)
        buttonInNavigationBar.titleLabel?.font = FontConfigManager.shared.getDigitalFont(size: 18)
        buttonInNavigationBar.theme_setTitleColor(GlobalPicker.barTextColor, forState: .normal)
        buttonInNavigationBar.setTitleColor(UIColor.init(white: 0.8, alpha: 1), for: .highlighted)
        buttonInNavigationBar.addTarget(self, action: #selector(self.clickNavigationTitleButton(_:)), for: .touchUpInside)
        self.navigationItem.titleView = buttonInNavigationBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonInNavigationBar.setRightImage(imageName: "Caret-down-dark", imagePaddingTop: 0, imagePaddingLeft: 0, titlePaddingRight: 0)
        // TODO: needs to update the icon. It's too big here.
        buttonInNavigationBar.title = "         " + market!.description
    }
    
    func setup() {
        if let market = market {
            PlaceOrderDataManager.shared.new(tokenA: market.tradingPair.tradingA, tokenB: market.tradingPair.tradingB, market: market)
        }
    }

    func updateHistoryButton() {
        var icon: UIImage?
        if Themes.isDark() {
            icon = UIImage(named: "Order-history-white")?.withRenderingMode(.alwaysOriginal)
        } else {
            icon = UIImage(named: "Order-history-white")?.withRenderingMode(.alwaysOriginal)
        }
        let starButton = UIBarButtonItem(image: icon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.pressHistoryButton(_:)))
        self.navigationItem.rightBarButtonItem = starButton
    }
    
    @objc func pressHistoryButton(_ button: UIBarButtonItem) {
        print("pressStarButton")
        let viewController = OrderHistorySwipeViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func clickNavigationTitleButton(_ button: UIButton) {
        print("select another wallet.")
        let viewController = MarketChangeTokenSwipeViewController()
        // self.navigationController?.pushViewController(viewController, animated: true)

        let navController = UINavigationController(rootViewController: viewController)
        self.present(navController, animated: true) {
            
        }

    }

    @IBAction func pressedSellButton(_ sender: Any) {
        print("pressedSellButton")
        let viewController = BuyAndSellSwipeViewController()
        viewController.market = market
        viewController.initialType = .sell
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func pressedBuyButton(_ sender: Any) {
        print("pressedBuyButton")
        let viewController = BuyAndSellSwipeViewController()
        viewController.market = market
        viewController.initialType = .buy
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
