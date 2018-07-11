//
//  MarketViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class MarketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var marketTableView: UITableView!
    
    var type: MarketSwipeViewType
    let refreshControl = UIRefreshControl()
    
    var viewAppear: Bool = false
    var isReordering: Bool = false
    var isListeningSocketIO: Bool = false
    
    var didSelectRowClosure: ((Market) -> Void)?
    var didSelectBlankClosure: (() -> Void)?

    var searchText: String = ""
    var isSearching: Bool = false
    var filteredMarkets = [Market]()
    
    var canHideKeyboard = true
    
    // TODO: copy data from MarketDataManager.shared.getMarkets()
    var markets = [Market]()
    
    convenience init(type: MarketSwipeViewType) {
        self.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        type = .all
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        marketTableView.dataSource = self
        marketTableView.delegate = self
        // marketTableView.reorder.delegate = self
        marketTableView.tableFooterView = UIView()
        marketTableView.separatorStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        marketTableView.addGestureRecognizer(tap)
        /*
        // one part of record
        marketTableView.estimatedRowHeight = 0
        marketTableView.estimatedSectionHeaderHeight = 0
        marketTableView.estimatedSectionFooterHeight = 0
        */

        // No need to call here
        // getMarketsFromRelay()
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        marketTableView.theme_backgroundColor = GlobalPicker.backgroundColor

        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            marketTableView.refreshControl = refreshControl
        } else {
            marketTableView.addSubview(refreshControl)
        }
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc func tableTapped(tap: UITapGestureRecognizer) {
        let location = tap.location(in: marketTableView)
        let path = marketTableView.indexPathForRow(at: location)
        if let indexPathForRow = path {
            self.tableView(marketTableView, didSelectRowAt: indexPathForRow)
        } else {
            if let didSelectBlankClosure = self.didSelectBlankClosure {
                didSelectBlankClosure()
            }
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        getTickersFromRelay()
    }
    
    func getTickersFromRelay() {
        LoopringAPIRequest.getTicker { (markets, error) in
            print("receive LoopringAPIRequest.getMarkets")
            guard error == nil else {
                print("error=\(String(describing: error))")
                let notificationTitle = LocalizedString("Sorry. Network error, please try again later", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .info)
                banner.duration = 2.0
                banner.show()
                return
            }
            // We don't any filter in the API requests. So no need to filter the response.
            MarketDataManager.shared.setMarkets(newMarkets: markets)
            DispatchQueue.main.async {
                self.marketTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func tickerResponseReceivedNotification() {
        if !isReordering && viewAppear && !isSearching && isListeningSocketIO {
            print("MarketViewController reload table \(type.description)")
            marketTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isListeningSocketIO = true
        // We have started startGetTicker() in the AppDelegate. No need to start again
        // MarketDataManager.shared.startGetTicker()
        // Add observer.
        NotificationCenter.default.addObserver(self, selector: #selector(tickerResponseReceivedNotification), name: .tickerResponseReceived, object: nil)
        
        if type == .favorite {
            marketTableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isSearching = false
        isListeningSocketIO = false
        // MarketDataManager.shared.stopGetTicker()
        NotificationCenter.default.removeObserver(self, name: .tickerResponseReceived, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadAfterSwipeViewUpdated(isSearching: Bool, searchText: String) {
        markets = MarketDataManager.shared.getMarketsWithoutReordered(type: type)
        self.isSearching = isSearching
        self.searchText = searchText.trim()
        if isSearching {
            filterContentForSearchText(self.searchText)
        } else {
            marketTableView.reloadData()
            // marketTableView.reloadSections(IndexSet(integersIn: 0...0), with: .fade)
        }
    }
    
    func searchTextDidUpdate(searchText: String) {
        print("MarketViewController searchTextDidUpdate")
        self.searchText = searchText.trim()
        if self.searchText != "" {
            isSearching = true
            filterContentForSearchText(self.searchText)
        } else {
            isSearching = false
            marketTableView.reloadSections(IndexSet(integersIn: 0...0), with: .fade)
        }
    }

    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String) {
        let newFilteredMarkets = MarketDataManager.shared.getMarketsWithoutReordered(type: type).filter({(market: Market) -> Bool in
            return market.tradingPair.tradingA.lowercased().contains(searchText.lowercased()) || market.tradingPair.tradingB.lowercased().contains(searchText.lowercased())
        })

        filteredMarkets = newFilteredMarkets

        if marketTableView.contentOffset.y == 0 {
            marketTableView.reloadSections(IndexSet(integersIn: 0...0), with: .fade)
        } else {
            canHideKeyboard = false
            _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                self.canHideKeyboard = true
            }
            
            marketTableView.reloadData()
            // tableView.setContentOffset(.zero, animated: false)
            let topIndex = IndexPath(row: 0, section: 0)
            marketTableView.scrollToRow(at: topIndex, at: .top, animated: true)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isListeningSocketIO = false
        print("scrollViewWillBeginDragging")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if canHideKeyboard {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isListeningSocketIO = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MarketTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredMarkets.count
        } else {
            return MarketDataManager.shared.getMarketsWithoutReordered(type: type).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = marketTableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        var cell = tableView.dequeueReusableCell(withIdentifier: MarketTableViewCell.getCellIdentifier()) as? MarketTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("MarketTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MarketTableViewCell
        }
        let market: Market
        if isSearching {
            market = filteredMarkets[indexPath.row]
        } else {
            market = MarketDataManager.shared.getMarketsWithoutReordered(type: type)[indexPath.row]
        }
        cell?.market = market
        cell?.update()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let market: Market
        if isSearching {
            market = filteredMarkets[indexPath.row]
        } else {
            market = MarketDataManager.shared.getMarketsWithoutReordered(type: type)[indexPath.row]
        }
        if let didSelectRowClosure = self.didSelectRowClosure {
            didSelectRowClosure(market)
        }

        let marketDetailViewController = MarketDetailViewController()
        marketDetailViewController.market = market
        marketDetailViewController.hidesBottomBarWhenPushed = true

        self.navigationController?.view.endEditing(true)
        self.navigationController?.pushViewController(marketDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let market = MarketDataManager.shared.getMarketsWithoutReordered(type: type)[indexPath.row]
        if type == .favorite {
            let action = UIContextualAction(style: .normal, title: nil, handler: { (_: UIContextualAction, _:  UIView, success: (Bool) -> Void) in
                print("OK, marked as Unfavorite")
                MarketDataManager.shared.removeFavoriteMarket(market: market)
                success(true)
                
                // TODO: need to improve the animation
                // self.markets.remove(at: indexPath.row)
                self.marketTableView.deleteRows(at: [indexPath], with: .fade)
            })
            action.image = UIImage(named: "Unfavorite")!
            action.backgroundColor = UIStyleConfig.defaultTintColor
            return UISwipeActionsConfiguration(actions: [action])
        } else {
            let action = UIContextualAction(style: .normal, title: nil, handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
                print("OK, marked as Favorite")
                MarketDataManager.shared.setFavoriteMarket(market: market)
                success(true)
            })
            action.image = UIImage(named: "Favorite")!
            action.backgroundColor = UIStyleConfig.defaultTintColor
            return UISwipeActionsConfiguration(actions: [action])
        }
    }
}

extension MarketViewController: TableViewReorderDelegate {
    // MARK: - Reorder Delegate
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        MarketDataManager.shared.exchange(at: sourceIndexPath.row, to: destinationIndexPath.row, type: type)
    }
    
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        return false
        /*
        if isFiltering {
            return false
        }

        if indexPath.row >= 0 {
            return true
        } else {
            return false
        }
        */
    }
    
    func tableViewDidBeginReordering(_ tableView: UITableView) {
        print("tableViewDidBeginReordering")
        isReordering = true
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
        print("tableViewDidFinishReordering")
        isReordering = false
    }
}
