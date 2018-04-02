//
//  MarketViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var marketTableView: UITableView!
    
    var type: MarketSwipeViewType
    
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
        setup()
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        marketTableView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        marketTableView.dataSource = self
        marketTableView.delegate = self
        marketTableView.reorder.delegate = self
        marketTableView.tableFooterView = UIView()
        marketTableView.separatorStyle = .none
        
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
        
        // Get a copy from get markets.
        markets = MarketDataManager.shared.getMarkets(type: type)
        // Add observer.
        NotificationCenter.default.addObserver(self, selector: #selector(tickerResponseReceivedNotification), name: .tickerResponseReceived, object: nil)
    }
    
    func setup() {
        OrderDataManager.shared.getOrdersFromServer()
    }

    @objc func tickerResponseReceivedNotification() {
        // TODO: Perform a diff algorithm
        if self.markets.count == 0 {
            self.markets = MarketDataManager.shared.getMarkets()
            marketTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if type == .favorite {
            reload()
        }
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
            market = markets[indexPath.row]
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
        self.navigationController?.pushViewController(marketDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let market = MarketDataManager.shared.getMarkets(type: self.type)[indexPath.row]
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
        let movedObject = markets[sourceIndexPath.row]
        markets.remove(at: sourceIndexPath.row)
        markets.insert(movedObject, at: destinationIndexPath.row)
        MarketDataManager.shared.exchange(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}
