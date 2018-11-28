//
//  MarketDetailSwipeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/28/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var market: Market!
    var marketDetailSwipeViewController = MarketDetailSwipeViewController()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buyButton: GradientButton!
    @IBOutlet weak var sellButton: GradientButton!
    
    let buttonInNavigationBar =  UIButton(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor
        setBackButton()
        setupMarket()
        updateHistoryButton()

        buyButton.setGreen()
        sellButton.setRed()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.separatorStyle = .none
        /*
        addChildViewController(marketDetailSwipeViewController)
        view.addSubview(marketDetailSwipeViewController.view)
        
        marketDetailSwipeViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: marketDetailSwipeViewController.view, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: marketDetailSwipeViewController.view, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: marketDetailSwipeViewController.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: marketDetailSwipeViewController.view, attribute: .bottom, relatedBy: .equal, toItem: buyButton, attribute: .top, multiplier: 1.0, constant: -5.0).isActive = true
        */
 
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
        
        buttonInNavigationBar.setRightImage(imageName: "Caret-down-dark", imagePaddingTop: 0, imagePaddingLeft: -24, titlePaddingRight: 0)
        // TODO: needs to update the icon. It's too big here.
        var padding = "  "
        for _ in 0..<market!.description.count {
            padding += " "
        }
        buttonInNavigationBar.title = padding + market!.description
    }
    
    func setupMarket() {
        PlaceOrderDataManager.shared.new(tokenA: market.tradingPair.tradingA, tokenB: market.tradingPair.tradingB, market: market)
        
        buyButton.setTitle(LocalizedString("Buy", comment: "") + " " + market.tradingPair.tradingA, for: .normal)
        sellButton.setTitle(LocalizedString("Sell", comment: "") + " " + market.tradingPair.tradingA, for: .normal)
        
        marketDetailSwipeViewController.market = market
    }

    func updateHistoryButton() {
        var icon: UIImage?
        if Themes.isDark() {
            icon = UIImage(named: "Order-history-dark")?.withRenderingMode(.alwaysOriginal)
        } else {
            icon = UIImage(named: "Order-history-light")?.withRenderingMode(.alwaysOriginal)
        }
        let starButton = UIBarButtonItem(image: icon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.pressHistoryButton(_:)))
        self.navigationItem.rightBarButtonItem = starButton
    }
    
    @objc func pressHistoryButton(_ button: UIBarButtonItem) {
        print("pressStarButton")
        let viewController = UpdatedOrderHistoryViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func clickNavigationTitleButton(_ button: UIButton) {
        print("select another wallet.")
        let viewController = MarketChangeTokenSwipeViewController()
        viewController.didSelectRowClosure = { (market) -> Void in
            // Update market
            self.market = market
            self.setupMarket()
        }

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return getMarketDetailSummaryTableViewCell()
        } else {
            return UITableViewCell()
        }
    }
    
    func getMarketDetailSummaryTableViewCell() -> MarketDetailSummaryTableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: MarketDetailSummaryTableViewCell.getCellIdentifier()) as? MarketDetailSummaryTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("MarketDetailSummaryTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MarketDetailSummaryTableViewCell
        }
        cell?.setup(market: market)
        return cell!
    }

}
