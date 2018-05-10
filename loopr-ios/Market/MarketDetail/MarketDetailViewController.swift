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
    
    @IBOutlet weak var tableView: UITableView!
    
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

        OrderDataManager.shared.getOrdersFromServer(completionHandler: { orders, error in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        OrderBookDataManager.shared.getOrderBookFromServer(market: market.name, completionHandler: { sells, buys, error in
            
        })
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return OrderDataManager.shared.getOrders(orderStatuses: [.opened, .cutoff, .cancelled, .expire, .unknown]).count + 1
        default:
            return OrderDataManager.shared.getOrders(orderStatuses: [.finished]).count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return NSLocalizedString("Orders", comment: "")
        case 2:
            return NSLocalizedString("Trades", comment: "")
        default:
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

        } else if indexPath.section == 1 {
            return OrderTableViewCell.getHeight()
        } else {
            // return TradeTableViewCell.getHeight()
            return OrderTableViewCell.getHeight()
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

        } else if indexPath.section == 1 {
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
            } else {
                var cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.getCellIdentifier()) as? OrderTableViewCell
                if cell == nil {
                    let nib = Bundle.main.loadNibNamed("OrderTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? OrderTableViewCell
                }
                let order = OrderDataManager.shared.getOrders(orderStatuses: [.opened, .cutoff, .cancelled, .expire, .unknown])[indexPath.row-1]
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
        } else {            
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.getCellIdentifier()) as? OrderTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderTableViewCell
                // cell?.selectionStyle = .none
            }
            cell?.order = OrderDataManager.shared.getOrders(orderStatuses: [.finished])[indexPath.row]
            cell?.update()
            cell?.cancelButton.isHidden = true
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row > 0 {
            let order = OrderDataManager.shared.getOrders(orderStatuses: [.opened, .cutoff, .cancelled, .expire, .unknown])[indexPath.row-1]
            let viewController = OrderDetailViewController()
            viewController.order = order
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath.section == 2 {
            let order = OrderDataManager.shared.getOrders(orderStatuses: [.finished])[indexPath.row]
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
