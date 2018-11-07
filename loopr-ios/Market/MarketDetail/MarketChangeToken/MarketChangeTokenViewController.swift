//
//  MarketChangeTokenViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class MarketChangeTokenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var marketTableView: UITableView!
    
    var type: MarketSwipeViewType
    let refreshControl = UIRefreshControl()
    
    var viewAppear: Bool = false
    
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
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 10))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        marketTableView.tableHeaderView = headerView
        
        marketTableView.tableFooterView = UIView()
        marketTableView.separatorStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        marketTableView.addGestureRecognizer(tap)

        view.theme_backgroundColor = ColorPicker.backgroundColor
        marketTableView.theme_backgroundColor = ColorPicker.backgroundColor
        
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        marketTableView.refreshControl = refreshControl
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
        // TODO: config in setting
        LoopringAPIRequest.getTicker(by: .coinmarketcap) { (markets, error) in
            print("receive LoopringAPIRequest.getMarkets")
            guard error == nil else {
                print("error=\(String(describing: error))")
                let notificationTitle = LocalizedString("Network Error", comment: "")
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if type == .favorite {
            marketTableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isSearching = false
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if canHideKeyboard {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MarketChangeTokenTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredMarkets.count
        } else {
            return MarketDataManager.shared.getMarketsWithoutReordered(type: type).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: MarketChangeTokenTableViewCell.getCellIdentifier()) as? MarketChangeTokenTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("MarketChangeTokenTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MarketChangeTokenTableViewCell
        }
        let market: Market
        if isSearching {
            market = filteredMarkets[indexPath.row]
        } else {
            market = MarketDataManager.shared.getMarketsWithoutReordered(type: type)[indexPath.row]
        }
        cell?.market = market
        cell?.update()
        
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            cell?.baseView.round(corners: [.bottomLeft, .bottomRight], radius: 6)
        } else if indexPath.row == 0 {
            cell?.baseView.round(corners: [.topLeft, .topRight], radius: 6)
        } else {
            cell?.baseView.round(corners: [], radius: 0)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let market: Market
        if isSearching && filteredMarkets.count > 0 {
            market = filteredMarkets[indexPath.row]
        } else {
            market = MarketDataManager.shared.getMarketsWithoutReordered(type: type)[indexPath.row]
        }
        self.dismiss(animated: true) {
            
        }
        didSelectRowClosure?(market)
    }

}
