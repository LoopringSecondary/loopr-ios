//
//  MarketDetailViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import PopupDialog
import NotificationBannerSwift

class MarketDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var market: Market!
    var trends: [Trend]?
    var sells: [Order] = []
    var buys: [Order] = []
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var buttonHeightLayoutConstraint: NSLayoutConstraint!
    
    // Drag down to close a present view controller.
    let interactor = Interactor()
    
    var blurVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        self.navigationItem.title = market?.description
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        setBackButton()
        udpateStarButton()
        blurVisualEffectView.alpha = 1
        // Sell button
        sellButton.setTitle(NSLocalizedString("Sell", comment: ""), for: .normal)
        sellButton.setupRoundWhite()
        
        // Buy button
        buyButton.setTitle(NSLocalizedString("Buy", comment: ""), for: .normal)
        buyButton.setupRoundBlack()

        getDataFromRelay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Add observer.
        NotificationCenter.default.addObserver(self, selector: #selector(trendResponseReceivedNotification), name: .trendResponseReceived, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .trendResponseReceived, object: nil)
    }
    
    func setup() {
        // TODO: putting getMarketsFromServer() here may cause a race condition.
        // It's not perfect, but works. Need improvement in the future.
        if let market = market {
            let tokenPair = market.tradingPair.description
            MarketDataManager.shared.startGetTrend(market: tokenPair)
            MarketDataManager.shared.getTrendsFromServer(market: tokenPair, completionHandler: { (trends, error) in
                guard error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    self.trends = trends
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Data
        getDataFromRelay()
    }
    
    func getDataFromRelay() {
        OrderDataManager.shared.getOrdersFromServer(completionHandler: { _, _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })

        OrderBookDataManager.shared.getOrderBookFromServer(market: market.name, completionHandler: { sells, buys, _ in
            self.sells = Array(sells.prefix(4))
            self.buys = Array(buys.prefix(4))
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }

    @objc func trendResponseReceivedNotification() {
        print("MarketDetailViewController trendReceivedNotification")
        if self.trends == nil {
            self.trends = MarketDataManager.shared.getTrends(market: market!.tradingPair.description)
            self.tableView.reloadData()
        } else {
            // TODO: Perform a diff algorithm
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func udpateStarButton() {
        var icon: UIImage?
        if market!.isFavorite() {
            icon = UIImage(named: "Star")?.withRenderingMode(.alwaysOriginal)
        } else {
            icon = UIImage(named: "StarOutline")?.withRenderingMode(.alwaysOriginal)
        }
        let starButton = UIBarButtonItem(image: icon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.pressStarButton(_:)))
        self.navigationItem.rightBarButtonItem = starButton
    }
    
    @objc func pressStarButton(_ button: UIBarButtonItem) {
        print("pressStarButton")
        
        guard let market = market else {
            return
        }
        if market.isFavorite() {
            MarketDataManager.shared.removeFavoriteMarket(market: market)
        } else {
            MarketDataManager.shared.setFavoriteMarket(market: market)
        }
        udpateStarButton()
    }
    
    @IBAction func pressedSellButton(_ sender: Any) {
        print("pressedSellButton")
        PlaceOrderDataManager.shared.new(tokenA: self.market!.tradingPair.tradingA, tokenB: self.market!.tradingPair.tradingB, market: self.market!)
        let viewController = BuyAndSellSwipeViewController()
        viewController.initialType = .sell
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func pressedBuyButton(_ sender: Any) {
        print("pressedBuyButton")
        PlaceOrderDataManager.shared.new(tokenA: self.market!.tradingPair.tradingA, tokenB: self.market!.tradingPair.tradingB, market: self.market!)
        let viewController = BuyAndSellSwipeViewController()
        viewController.initialType = .buy
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return 0
        case 2:
            return sells.count
        case 3:
            return buys.count
        case 4:
            let count = OrderDataManager.shared.getOrders(hideOtherPairs: SettingDataManager.shared.getHideOtherPairs(), currentMarket: market, orderStatuses: [.opened, .cutoff, .cancelled, .expire, .unknown]).count
            if count == 0 {
                return 2
            } else {
                return count + 1
            }
        case 5:
            let count = OrderDataManager.shared.getOrders(hideOtherPairs: SettingDataManager.shared.getHideOtherPairs(), currentMarket: market, orderStatuses: [.finished]).count
            if count == 0 {
                return 1
            } else {
                return count
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let padding: CGFloat = 15

        if section == 1 || section == 4 || section == 5 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
            // headerView.theme_backgroundColor = GlobalPicker.backgroundColor
            headerView.backgroundColor = UIColor.init(rgba: "#F8F8F8")

            let label = UILabel(frame: CGRect(x: padding, y: 0, width: view.frame.size.width, height: 45))
            label.theme_textColor = GlobalPicker.textColor
            label.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 17)
            headerView.addSubview(label)
            
            if section == 1 {
                label.text = NSLocalizedString("Order Book", comment: "")
            } else if section == 4 {
                label.text = NSLocalizedString("My Orders", comment: "")
            } else if section == 5 {
                label.text = NSLocalizedString("My Trades", comment: "")
            }
            return headerView

        } else if section == 2 || section == 3 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
            // Default background color in section is UIColor(white: 0.97, alpha: 1)
            // headerView.backgroundColor = UIColor(white: 0.97, alpha: 1)
            headerView.theme_backgroundColor = GlobalPicker.backgroundColor
            
            let seperateLine = UIView(frame: CGRect(x: padding, y: 44.5, width: view.frame.size.width, height: 0.5))
            seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
            headerView.addSubview(seperateLine)
            
            let label1 = UILabel(frame: CGRect(x: padding, y: 0, width: (view.frame.size.width-padding*2)/3, height: 45))
            label1.theme_textColor = GlobalPicker.textColor
            label1.font = FontConfigManager.shared.getLabelFont()
            headerView.addSubview(label1)
            
            let label2 = UILabel(frame: CGRect(x: label1.frame.maxX, y: 0, width: (view.frame.size.width-padding*2)/3, height: 45))
            label2.textAlignment = .right
            label2.theme_textColor = GlobalPicker.textColor
            label2.font = FontConfigManager.shared.getLabelFont()
            headerView.addSubview(label2)
            
            let label3 = UILabel(frame: CGRect(x: label2.frame.maxX, y: 0, width: (view.frame.size.width-padding*2)/3, height: 45))
            label3.textAlignment = .right
            label3.theme_textColor = GlobalPicker.textColor
            label3.font = FontConfigManager.shared.getLabelFont()
            headerView.addSubview(label3)
            
            if section == 2 {
                label1.text = "Sell"
            } else if section == 3 {
                label1.text = "Buy"
            }
            
            label2.text = "Amount (\(market.tradingPair.tradingA))"
            label3.text = "Total (\(market.tradingPair.tradingB))"
            
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 45
        case 2:
            return 45
        case 3:
            return 45
        case 4:
            return 45
        case 5:
            return 45
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            // TODO: Simplify the code and make it reusable in other places.
            // window only available after iOS 11.0
            guard #available(iOS 11.0, *),
                let window = UIApplication.shared.keyWindow else {
                    let navBarHeight = (self.navigationController?.navigationBar.intrinsicContentSize.height)!
                        + UIApplication.shared.statusBarFrame.height
                    return MarketLineChartTableViewCell.getHeight(navigationBarHeight: navBarHeight)
            }

            let safeAreaHeight = window.safeAreaInsets.top + window.safeAreaInsets.bottom
            // Check if it's an iPhone X
            if safeAreaHeight > 0 {
                let navBarHeight = (self.navigationController?.navigationBar.intrinsicContentSize.height)!
                return MarketLineChartTableViewCell.getHeight(navigationBarHeight: navBarHeight) - safeAreaHeight
            } else {
                let navBarHeight = (self.navigationController?.navigationBar.intrinsicContentSize.height)!
                    + UIApplication.shared.statusBarFrame.height
                return MarketLineChartTableViewCell.getHeight(navigationBarHeight: navBarHeight)
            }

        } else if indexPath.section == 2 {
            return OrderBookTableViewCell.getHeight()
        } else if indexPath.section == 3 {
            return OrderBookTableViewCell.getHeight()
        } else if indexPath.section == 4 {
            return OrderTableViewCell.getHeight()
        } else if indexPath.section == 5 {
            // return TradeTableViewCell.getHeight()
            return OrderTableViewCell.getHeight()
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: MarketLineChartTableViewCell.getCellIdentifier()) as? MarketLineChartTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("MarketLineChartTableViewCell", owner: self, options: nil)
                cell = nib![0] as? MarketLineChartTableViewCell
                cell?.selectionStyle = .none
            }
            if let market = self.market {
                cell?.market = market
            }
            if let trends = self.trends {
                cell?.trends = trends
            }
            cell!.pressedBuyButtonClosure = {
                PlaceOrderDataManager.shared.new(tokenA: self.market!.tradingPair.tradingA, tokenB: self.market!.tradingPair.tradingB, market: self.market!)
                let viewController = BuyAndSellSwipeViewController()
                viewController.initialType = .buy
                self.navigationController?.pushViewController(viewController, animated: true)
                
                // We may use this part of code in the future.
                /*
                let buyViewController = ArchiveBuyViewController()
                buyViewController.transitioningDelegate = self
                buyViewController.interactor = self.interactor
                self.present(buyViewController, animated: true) {
                    
                }
                */
            }
            
            cell!.pressedSellButtonClosure = {
                PlaceOrderDataManager.shared.new(tokenA: self.market!.tradingPair.tradingA, tokenB: self.market!.tradingPair.tradingB, market: self.market!)
                let viewController = BuyAndSellSwipeViewController()
                viewController.initialType = .sell
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            return cell!
        } else if indexPath.section == 2 {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderBookTableViewCell.getCellIdentifier()) as? OrderBookTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderBookTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderBookTableViewCell
            }
            cell?.selectionStyle = .none
            let order = sells[indexPath.row]
            cell?.order = order
            cell?.update()
            return cell!

        } else if indexPath.section == 3 {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderBookTableViewCell.getCellIdentifier()) as? OrderBookTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderBookTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderBookTableViewCell
            }
            cell?.selectionStyle = .none
            let order = buys[indexPath.row]
            cell?.order = order
            cell?.update()
            return cell!
            
        } else if indexPath.section == 4 {
            let screenSize: CGRect = UIScreen.main.bounds
            self.blurVisualEffectView.frame = screenSize

            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCell(withIdentifier: CancelAllOpenOrdersTableViewCell.getCellIdentifier()) as? CancelAllOpenOrdersTableViewCell
                if cell == nil {
                    let nib = Bundle.main.loadNibNamed("CancelAllOpenOrdersTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? CancelAllOpenOrdersTableViewCell
                    cell?.selectionStyle = .none
                }
                cell?.pressedCancelAllButtonClosure = {
                    self.blurVisualEffectView.alpha = 1.0
                    let title = NSLocalizedString("You are going to cancel all open orders.", comment: "")
                    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                        UIView.animate(withDuration: 0.1, animations: {
                            self.blurVisualEffectView.alpha = 0.0
                        }, completion: {(_) in
                            self.blurVisualEffectView.removeFromSuperview()
                        })
                        self.cancelAllOrders()
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
                        UIView.animate(withDuration: 0.1, animations: {
                            self.blurVisualEffectView.alpha = 0.0
                        }, completion: {(_) in
                            self.blurVisualEffectView.removeFromSuperview()
                        })
                    }))
                    self.navigationController?.view.addSubview(self.blurVisualEffectView)
                    self.present(alert, animated: true, completion: nil)
                }
                cell?.toggleHidePairSwitchClosure = {
                    self.tableView.reloadData()
                }
                return cell!
            } else {
                let count = OrderDataManager.shared.getOrders(hideOtherPairs: SettingDataManager.shared.getHideOtherPairs(), currentMarket: market, orderStatuses: [.opened, .cutoff, .cancelled, .expire, .unknown]).count
                if count == 0 {
                    var cell = tableView.dequeueReusableCell(withIdentifier: OrderNoDataTableViewCell.getCellIdentifier()) as? OrderNoDataTableViewCell
                    if cell == nil {
                        let nib = Bundle.main.loadNibNamed("OrderNoDataTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? OrderNoDataTableViewCell
                    }
                    return cell!
                } else {
                    var cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.getCellIdentifier()) as? OrderTableViewCell
                    if cell == nil {
                        let nib = Bundle.main.loadNibNamed("OrderTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? OrderTableViewCell
                    }
                    let order = OrderDataManager.shared.getOrders(hideOtherPairs: SettingDataManager.shared.getHideOtherPairs(), currentMarket: market, orderStatuses: [.opened, .cutoff, .cancelled, .expire, .unknown])[indexPath.row-1]
                    cell?.order = order
                    cell?.update()
                    cell?.cancelButton.isHidden = false
                    cell?.pressedCancelButtonClosure = {
                        self.blurVisualEffectView.alpha = 1.0
                        let title = NSLocalizedString("You are going to cancel the order.", comment: "")
                        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                            print("Confirm to cancel the order")
                            UIView.animate(withDuration: 0.1, animations: {
                                self.blurVisualEffectView.alpha = 0.0
                            }, completion: {(_) in
                                self.blurVisualEffectView.removeFromSuperview()
                            })
                            self.cancelOrder(order: order.originalOrder)
                        }))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
                            UIView.animate(withDuration: 0.1, animations: {
                                self.blurVisualEffectView.alpha = 0.0
                            }, completion: {(_) in
                                self.blurVisualEffectView.removeFromSuperview()
                            })
                        }))
                        self.navigationController?.view.addSubview(self.blurVisualEffectView)
                        self.present(alert, animated: true, completion: nil)
                    }
                    return cell!
                }
            }
        } else {
            let count = OrderDataManager.shared.getOrders(hideOtherPairs: SettingDataManager.shared.getHideOtherPairs(), currentMarket: market, orderStatuses: [.finished]).count
            if count == 0 {
                var cell = tableView.dequeueReusableCell(withIdentifier: OrderNoDataTableViewCell.getCellIdentifier()) as? OrderNoDataTableViewCell
                if cell == nil {
                    let nib = Bundle.main.loadNibNamed("OrderNoDataTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? OrderNoDataTableViewCell
                }
                return cell!
            } else {
                var cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.getCellIdentifier()) as? OrderTableViewCell
                if cell == nil {
                    let nib = Bundle.main.loadNibNamed("OrderTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? OrderTableViewCell
                    // cell?.selectionStyle = .none
                }
                cell?.order = OrderDataManager.shared.getOrders(hideOtherPairs: SettingDataManager.shared.getHideOtherPairs(), currentMarket: market, orderStatuses: [.finished])[indexPath.row]
                cell?.update()
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 4 && indexPath.row > 0 {
            let order = OrderDataManager.shared.getOrders(hideOtherPairs: SettingDataManager.shared.getHideOtherPairs(), currentMarket: market, orderStatuses: [.opened, .cutoff, .cancelled, .expire, .unknown])[indexPath.row-1]
            let viewController = OrderDetailViewController()
            viewController.order = order
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath.section == 5 {
            let order = OrderDataManager.shared.getOrders(hideOtherPairs: SettingDataManager.shared.getHideOtherPairs(), currentMarket: market, orderStatuses: [.finished])[indexPath.row]
            let viewController = OrderDetailViewController()
            viewController.order = order
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        /*
        // TODO: Use UIAlertController or PopupDialog
        if indexPath.section == 1 {
            // TODO: Pass a view controller to PopupDialog https://github.com/Orderella/PopupDialog#custom-view-controller
            
            let dialogAppearance = PopupDialogDefaultView.appearance()
            dialogAppearance.titleFont = .boldSystemFont(ofSize: 17)
            dialogAppearance.titleColor = UIColor(white: 0, alpha: 1)
            dialogAppearance.titleTextAlignment = .center
            dialogAppearance.messageFont = .systemFont(ofSize: 17)
            dialogAppearance.messageTextAlignment = .left
            dialogAppearance.messageColor = UIColor(white: 0.2, alpha: 1)
            
            // Prepare the popup assets
            let title = "Order"
            let message = "This is the message section of the popup dialog default view"
            let image = UIImage(named: "Logo")
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message, image: image, transitionStyle: PopupDialogTransitionStyle.zoomIn)

            // Present dialog
            self.present(popup, animated: true, completion: nil)
        } else if indexPath.section == 2 {
            let alert = UIAlertController(title: "My Alert", message: "This is an alert.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        */
    }
}

extension MarketDetailViewController: UIViewControllerTransitioningDelegate {
    
    func cancelOrder(order: OriginalOrder) {
        SendCurrentAppWalletDataManager.shared._cancelOrder(order: order, completion: completion)
    }
    
    func cancelAllOrders() {
        SendCurrentAppWalletDataManager.shared._cancelAllOrders(completion: completion)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func completion(_ txHash: String?, _ error: Error?) {
        var title: String = ""
        guard error == nil && txHash != nil else {
            DispatchQueue.main.async {
                title = NSLocalizedString("Failed, Please try again.", comment: "")
                let banner = NotificationBanner.generate(title: title, style: .danger)
                banner.duration = 5
                banner.show()
            }
            return
        }
        DispatchQueue.main.async {
            print(txHash!)
            title = NSLocalizedString("Order(s) Cancelled Successful.", comment: "")
            let banner = NotificationBanner.generate(title: title, style: .success)
            banner.duration = 5
            banner.show()
        }
    }
}
