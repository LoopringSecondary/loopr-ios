//
//  MarketDetailViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/28/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

enum MarketDetailSection: Int {
    case swipe = 2
    case depthAndTradeHistory = 3
}

class MarketDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MarketDetailDepthTableViewCellDelegate {

    var market: Market!
    var marketDetailSwipeViewController = MarketDetailSwipeViewController()
    
    var swipeViewIndex: Int = 0
    
    // Chart
    var trends: [Trend] = []
    
    // Depth
    var preivousMarketName: String = ""
    var minSellPrice: Double = 0
    var buys: [Depth] = []
    var sells: [Depth] = []
    var maxAmountInDepthView: Double = 0
    var isDepthLaunching: Bool = true
    
    // Trade History
    var orderFills: [OrderFill] = []
    var isTradeHistoryLaunching: Bool = true
    
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
 
        buttonInNavigationBar.frame = CGRect(x: 0, y: 0, width: 400, height: 40)
        buttonInNavigationBar.titleLabel?.font = FontConfigManager.shared.getDigitalFont(size: 18)
        buttonInNavigationBar.theme_setTitleColor(GlobalPicker.barTextColor, forState: .normal)
        buttonInNavigationBar.setTitleColor(UIColor.init(white: 0.8, alpha: 1), for: .highlighted)
        buttonInNavigationBar.addTarget(self, action: #selector(self.clickNavigationTitleButton(_:)), for: .touchUpInside)
        self.navigationItem.titleView = buttonInNavigationBar
        
        getDepthFromRelay()
        self.buys = MarketDepthDataManager.shared.getBuys()
        self.sells = MarketDepthDataManager.shared.getSells()
        
        if buys.count > 0 && sells.count > 0 {
            self.maxAmountInDepthView = max(buys[buys.count / 2].amountAInDouble, sells[sells.count / 2].amountAInDouble) * 1.5
        } else if buys.count > 0 {
            self.maxAmountInDepthView = buys[buys.count / 2].amountAInDouble * 1.5
        } else if sells.count > 0 {
            self.maxAmountInDepthView = sells[sells.count / 2].amountAInDouble * 1.5
        } else {
            self.maxAmountInDepthView = 0
        }
        
        getTradeHistoryFromRelay()

        // 1 day range, use 1 hour interval, 24 counts
        // 1 month range, use 1 day interval, 30 counts
        // 1 year range, use 1 week interval, 52 counts
        // 2 year range, use 1 week interval, 104 counts
        
        MarketDataManager.shared.getAllTrends(market: market.name) { (_) in
            self.trends = MarketDataManager.shared.getTrends(trendRange: TrendRange.oneMonth)
        }
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
        addChildViewController(marketDetailSwipeViewController)
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case MarketDetailSection.swipe.rawValue:
            return getHeightForHeaderInSwipeSection()
        case MarketDetailSection.depthAndTradeHistory.rawValue:
            return swipeViewIndex == 0 ? getHeightForHeaderInSectionDepth() : getHeightForHeaderInSectionTradeHistory()
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case MarketDetailSection.swipe.rawValue:
            return getHeaderViewInSwipeSection()
        case MarketDetailSection.depthAndTradeHistory.rawValue:
            return swipeViewIndex == 0 ? getHeaderViewInSectionDepth() : getHeaderViewInSectionTradeHistory()
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case MarketDetailSection.swipe.rawValue:
            return 0
        case MarketDetailSection.depthAndTradeHistory.rawValue:
            return swipeViewIndex == 0 ? getNumberOfRowsInSectionDepth() : getNumberOfRowsInSectionTradeHistory()
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return MarketDetailSummaryTableViewCell.getHeight()
        case 1:
            return MarketDetailPriceChartTableViewCell.getHeight()
        case MarketDetailSection.depthAndTradeHistory.rawValue:
            return swipeViewIndex == 0 ? getHeightForRowAtSectionDepth(indexPath: indexPath) : getHeightForRowAtSectionTradeHistory(indexPath: indexPath)
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return getMarketDetailSummaryTableViewCell()
        case 1:
            return getMarketDetailPriceChartTableViewCell()
        case MarketDetailSection.depthAndTradeHistory.rawValue:
            return swipeViewIndex == 0 ? getMarketDetailDepthTableViewCell(cellForRowAt: indexPath) : getMarketDetailTradeHistoryTableViewCell(cellForRowAt: indexPath)
        default:
            return UITableViewCell()
        }
    }

    private func getMarketDetailSummaryTableViewCell() -> MarketDetailSummaryTableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: MarketDetailSummaryTableViewCell.getCellIdentifier()) as? MarketDetailSummaryTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("MarketDetailSummaryTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MarketDetailSummaryTableViewCell
        }
        cell?.setup(market: market)
        return cell!
    }

}

extension MarketDetailViewController: MarketDetailPriceChartTableViewCellDelegate {

    func trendRangeUpdated(newTrendRange: TrendRange) {
        self.trends = MarketDataManager.shared.getTrends(trendRange: newTrendRange)
        self.tableView.reloadData()
    }

    func trendDidHighlight(trend: Trend?) {
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? MarketDetailSummaryTableViewCell {
            if trend != nil {
                cell.setHighlighted(trend: trend!)
                tableView.isScrollEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.tableView.isScrollEnabled = true
                }
            } else {
                cell.setup(market: market)
                tableView.isScrollEnabled = true
            }
        }
    }
}
