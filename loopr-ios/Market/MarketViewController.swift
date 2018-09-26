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
    var isListeningSocketIO: Bool = false
    
    var didSelectRowClosure: ((Market) -> Void)?
    var didSelectBlankClosure: (() -> Void)?

    var searchText: String = ""
    var isSearching: Bool = false
    var filteredMarkets = [Market]()
    
    var canHideKeyboard = true
    
    var markets = [Market]()
    
    convenience init(type: MarketSwipeViewType) {
        self.init(nibName: nil, bundle: nil)
        self.type = type
        // TO reduce the number of TableViewCells that are created during init()
        if self.type == .favorite || self.type == .ETH {
            markets = MarketDataManager.shared.getMarketsWithoutReordered(type: type, tag: .whiteList)
        }
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

        /*
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 0))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        marketTableView.tableHeaderView = headerView
        */
        
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
                let notificationTitle = LocalizedString("No network", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .info)
                banner.duration = 2.0
                banner.show()
                return
            }
            // We don't any filter in the API requests. So no need to filter the response.
            MarketDataManager.shared.setMarkets(newMarkets: markets)
            if self.type == .favorite {
                self.markets = MarketDataManager.shared.getMarketsWithoutReordered(type: .favorite)
            }
            DispatchQueue.main.async {
                self.marketTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func tickerResponseReceivedNotification() {
        if viewAppear && !isSearching && isListeningSocketIO {
            print("MarketViewController reload table \(type.description)")
            markets = MarketDataManager.shared.getMarketsWithoutReordered(type: type, tag: .whiteList)
            marketTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if type == .favorite || MarketDataManager.shared.isMarketsEmpty() {
            getTickersFromRelay()
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
        isListeningSocketIO = false
        NotificationCenter.default.removeObserver(self, name: .tickerResponseReceived, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadAfterSwipeViewUpdated(isSearching: Bool, searchText: String) {
        markets = MarketDataManager.shared.getMarketsWithoutReordered(type: type, tag: .whiteList)
        self.isSearching = isSearching
        self.searchText = searchText.trim()
        if isSearching {
            filterContentForSearchText(self.searchText)
        } else {
            marketTableView.reloadData()
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
            marketTableView.reloadData()
            // marketTableView.reloadSections(IndexSet(integersIn: 0...0), with: .fade)
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30+0.5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenWidth = view.frame.size.width

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30+0.5))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor

        let baseView = UIView(frame: CGRect(x: 15, y: 0, width: screenWidth - 15*2, height: 30))
        baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        baseView.round(corners: [.topLeft, .topRight], radius: 6)
        headerView.addSubview(baseView)

        let labelWidth = (view.frame.size.width-20*2)/3
        let paddingX: CGFloat = 41
        
        let label1 = UILabel(frame: CGRect(x: paddingX, y: 0, width: labelWidth, height: 30))
        label1.theme_textColor = GlobalPicker.textLightColor
        label1.font = FontConfigManager.shared.getMediumFont(size: 14)
        label1.text = LocalizedString("Market", comment: "")
        label1.textAlignment = .left
        baseView.addSubview(label1)

        let label2 = UILabel(frame: CGRect(x: UIScreen.main.bounds.width*0.3+paddingX, y: 0, width: labelWidth, height: 30))
        label2.theme_textColor = GlobalPicker.textLightColor
        label2.font = FontConfigManager.shared.getMediumFont(size: 14)
        label2.text = LocalizedString("Price", comment: "")
        label2.textAlignment = .left
        baseView.addSubview(label2)

        let label3 = UILabel(frame: CGRect(x: baseView.width - 80 - 10, y: 0, width: 80, height: 30))
        label3.theme_textColor = GlobalPicker.textLightColor
        label3.font = FontConfigManager.shared.getMediumFont(size: 14)
        label3.text = LocalizedString("Change", comment: "")
        label3.textAlignment = .center
        baseView.addSubview(label3)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MarketTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredMarkets.count
        } else {
            return markets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: MarketTableViewCell.getCellIdentifier()) as? MarketTableViewCell
        if cell == nil {
            // 37 TableViewCell is created during init()
            let nib = Bundle.main.loadNibNamed("MarketTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MarketTableViewCell
        }
        let market: Market
        if isSearching {
            market = filteredMarkets[indexPath.row]
        } else {
            market = markets[indexPath.row]
        }
        cell?.market = market
        cell?.update()
        
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            cell?.baseView.round(corners: [.bottomLeft, .bottomRight], radius: 6)
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
        if let didSelectRowClosure = self.didSelectRowClosure {
            didSelectRowClosure(market)
        }

        let marketDetailViewController = MarketDetailViewController()
        marketDetailViewController.market = market
        marketDetailViewController.hidesBottomBarWhenPushed = true

        self.navigationController?.view.endEditing(true)
        self.navigationController?.pushViewController(marketDetailViewController, animated: true)
    }

}
