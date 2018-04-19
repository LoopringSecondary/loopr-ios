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
    
    var selectedCellClosure: ((Market) -> Void)?
    // TODO: searchController conflicts to SwipeViewController.
    let searchController = UISearchController(searchResultsController: nil)
    var filteredMarkets = [Market]()
    
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
        marketTableView.reorder.delegate = self
        marketTableView.tableFooterView = UIView()
        marketTableView.separatorStyle = .none
        
        marketTableView.estimatedRowHeight = 0
        marketTableView.estimatedSectionHeaderHeight = 0
        marketTableView.estimatedSectionFooterHeight = 0
        
        getMarketsFromRelay()
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        marketTableView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "LRC"
        searchController.searchBar.tintColor = UIStyleConfig.defaultTintColor
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        // searchController.searchBar.scopeButtonTitles = ["All", "ETH", "LRC", "Other"]
        // searchController.searchBar.delegate = self
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            marketTableView.refreshControl = refreshControl
        } else {
            marketTableView.addSubview(refreshControl)
        }
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshData(_ sender: Any) {
        getMarketsFromRelay()
    }
    
    func getMarketsFromRelay() {
        LoopringAPIRequest.getMarkets { (markets, error) in
            print("receive LoopringAPIRequest.getMarkets")
            guard error == nil else {
                print("error=\(String(describing: error))")
                let notificationTitle = NSLocalizedString("Sorry. Network error", comment: "")
                let attribute = [NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)!]
                let attributeString = NSAttributedString(string: notificationTitle, attributes: attribute)
                let banner = NotificationBanner(attributedTitle: attributeString, style: .info, colors: NotificationBannerStyle())
                banner.duration = 2.0
                banner.show()
                return
            }
            MarketDataManager.shared.setMarkets(newMarkets: markets, type: self.type)
            DispatchQueue.main.async {
                self.marketTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func tickerResponseReceivedNotification() {
        // TODO: Perform a diff algorithm
//        if self.markets.count == 0 {
//            self.markets = MarketDataManager.shared.getMarkets(type: type)
//            marketTableView.reloadData()
//        }
        
        if !isReordering && viewAppear {
            print("MarketViewController reload table \(type.description)")
            marketTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Add observer.
        NotificationCenter.default.addObserver(self, selector: #selector(tickerResponseReceivedNotification), name: .tickerResponseReceived, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .tickerResponseReceived, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload() {
        markets = MarketDataManager.shared.getMarkets(type: type)
        marketTableView.reloadData()
    }

    // MARK: - Private instance methods
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        
        // TODO
//        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
//        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
        return false
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredMarkets = MarketDataManager.shared.getMarkets(type: type).filter({(market: Market) -> Bool in
            return market.tradingPair.tradingA.lowercased().contains(searchText.lowercased()) || market.tradingPair.tradingB.lowercased().contains(searchText.lowercased())
        })
        marketTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MarketTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredMarkets.count
        } else {
            return MarketDataManager.shared.getMarkets(type: type).count
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
        if isFiltering() {
            market = filteredMarkets[indexPath.row]
        } else {
            market = MarketDataManager.shared.getMarkets(type: type)[indexPath.row]
        }
        cell?.market = market
        cell?.update()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let marketDetailViewController = MarketDetailViewController()
        let market = MarketDataManager.shared.getMarkets(type: type)[indexPath.row]
        marketDetailViewController.market = market
        marketDetailViewController.hidesBottomBarWhenPushed = true
        
        self.navigationController?.view.endEditing(true)
        self.navigationController?.pushViewController(marketDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let market = MarketDataManager.shared.getMarkets(type: type)[indexPath.row]
        if market.isFavorite() {
            let action = UIContextualAction(style: .normal, title: "Unfavorite", handler: { (_: UIContextualAction, _:  UIView, success: (Bool) -> Void) in
                print("OK, marked as Unfavorite")
                MarketDataManager.shared.removeFavoriteMarket(market: market)
                success(true)
                
                // TODO: need to improve the animation
                if self.type == .favorite {
                    self.markets.remove(at: indexPath.row)
                    self.marketTableView.deleteRows(at: [indexPath], with: .fade)
                }
            })
            action.backgroundColor = UIStyleConfig.defaultTintColor
            return UISwipeActionsConfiguration(actions: [action])
        } else {
            let action = UIContextualAction(style: .normal, title: "Favorite", handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
                print("OK, marked as Favorite")
                MarketDataManager.shared.setFavoriteMarket(market: market)
                success(true)
            })
            action.backgroundColor = UIStyleConfig.defaultTintColor
            return UISwipeActionsConfiguration(actions: [action])
        }
    }
}

extension MarketViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension MarketViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // let searchBar = searchController.searchBar
        // let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension MarketViewController: TableViewReorderDelegate {
    // MARK: - Reorder Delegate
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        MarketDataManager.shared.exchange(at: sourceIndexPath.row, to: destinationIndexPath.row, type: type)
    }
    
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row >= 0 {
            return true
        } else {
            return false
        }
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
