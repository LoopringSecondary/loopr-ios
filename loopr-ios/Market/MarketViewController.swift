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
        marketTableView.dataSource = self
        marketTableView.delegate = self
                
        // TODO: putting getMarketsFromServer() here may cause a race condition.
        // It's not perfect, but works. Need improvement in the future.
        MarketDataManager.shared.getMarketsFromServer { (markets, error) in
            guard error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.markets = MarketDataManager.shared.getMarkets(type: self.type)
                self.marketTableView.reloadData()
                self.marketTableView.isEditing = true
                self.marketTableView.allowsSelectionDuringEditing = true
            }
        }

        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "LRC"
        searchController.searchBar.tintColor = defaultTintColor
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        // searchController.searchBar.scopeButtonTitles = ["All", "ETH", "LRC", "Other"]
        // searchController.searchBar.delegate = self
        
        markets = MarketDataManager.shared.getMarkets(type: type)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureRecognized(_:)))
        self.marketTableView.addGestureRecognizer(longPress)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (type == .favorite) {
            self.marketTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private instance methods
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
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
        var cell = tableView.dequeueReusableCell(withIdentifier: MarketTableViewCell.getCellIdentifier()) as? MarketTableViewCell
        if (cell == nil) {
            let nib = Bundle.main.loadNibNamed("MarketTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MarketTableViewCell
        }
        
        let market: Market
        if isFiltering() {
            market = filteredMarkets[indexPath.row]
        } else {
            market = markets[indexPath.row] // MarketDataManager.shared.getMarkets(type: type)[indexPath.row]
        }

        cell?.market = market
        cell?.update()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let marketDetailViewController = MarketDetailViewController();
        let market = MarketDataManager.shared.getMarkets(type: type)[indexPath.row]
        marketDetailViewController.market = market
        marketDetailViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(marketDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (type == .favorite) {
            // return nil
        }

        let action = UIContextualAction(style: .normal, title:  "Favorite", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("OK, marked as Favorite")
            
            let market = MarketDataManager.shared.getMarkets(type: self.type)[indexPath.row]
            MarketDataManager.shared.setFavoriteMarket(market: market)
            // self.marketTableView.reloadData()
            success(true)
        })
        action.backgroundColor = defaultTintColor
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (type == .favorite) {
            let action = UIContextualAction(style: .normal, title:  "Unfavourite", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("OK, marked as Unfavourite")
                
                let market = MarketDataManager.shared.getMarkets(type: self.type)[indexPath.row]
                MarketDataManager.shared.removeFavoriteMarket(market: market)
                // self.marketTableView.reloadData()
                success(true)
            })
            action.backgroundColor = defaultTintColor
            
            return UISwipeActionsConfiguration(actions: [action])
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = markets[sourceIndexPath.row]
        markets.remove(at: sourceIndexPath.row)
        markets.insert(movedObject, at: destinationIndexPath.row)
        self.marketTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    

    var snapshot: UIView? = nil
    var sourceIndexPath: IndexPath? = nil
    
    @objc func longPressGestureRecognized(_ sender: UILongPressGestureRecognizer) {
        print("longPressGestureRecognized")
        
        let state = sender.state
        let location = sender.location(in: self.marketTableView)
        let indexPath = self.marketTableView.indexPathForRow(at: location)
        
        switch state {
        case .began:
            guard let indexPath = indexPath else {
                return
            }
            sourceIndexPath = indexPath
            let cell = self.marketTableView.cellForRow(at: sourceIndexPath!)!
            snapshot = self.customSnapshotFromView(inputView: cell)
            
            var center = cell.center
            snapshot?.center = center
            snapshot?.alpha = 0
            self.marketTableView.addSubview(snapshot!)
            
            UIView.animate(withDuration: 0.25, animations: {
                // Offset for gesture location
                center.y = location.y
                self.snapshot?.center = center
                self.snapshot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.snapshot?.alpha = 0.98
                cell.alpha = 0.0
                cell.isHidden = true
            })
            
            break
        
        case .changed:
            
            var center = snapshot!.center
            center.y = location.y
            snapshot!.center = center
            
            if (indexPath != nil && indexPath == sourceIndexPath) {
                markets.swapAt(indexPath!.row, sourceIndexPath!.row)
                // swap(&markets[indexPath!.row], &markets[sourceIndexPath!.row])
                self.marketTableView.moveRow(at: sourceIndexPath!, to: indexPath!)
                sourceIndexPath = indexPath
            }
            
            break
        
        default:
            let cell = self.marketTableView.cellForRow(at: sourceIndexPath!)!
            cell.alpha = 0.0
            
            UIView.animate(withDuration: 0.25, animations: {
                self.snapshot?.center = cell.center
                self.snapshot?.transform = CGAffineTransform.identity
                self.snapshot?.alpha = 0.0
                cell.alpha = 1.0
            }, completion: { (finished) in
                cell.isHidden = false
                self.sourceIndexPath = nil
                self.snapshot?.removeFromSuperview()
                self.snapshot = nil
            })

        }
    }
    
    func customSnapshotFromView(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Create an image view
        let snapshot = UIImageView.init(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4

        return snapshot
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
