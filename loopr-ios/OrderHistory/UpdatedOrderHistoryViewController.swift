//
//  UpdatedOrderHistoryViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/12/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class UpdatedOrderHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var historyTableView: UITableView!

    // Data source
    var orders: [Order] = []
    
    let refreshControl = UIRefreshControl()
    
    var viewAppear: Bool = false
    var isLaunching: Bool = true
    
    var didSelectRowClosure: ((Market) -> Void)?
    var didSelectBlankClosure: (() -> Void)?
    
    var searchText: String = ""
    var isSearching: Bool = false
    var filteredOrders = [Order]()
    
    var canHideKeyboard = true
    
    var previousOrderCount: Int = 0
    var pageIndex: UInt = 1
    var hasMoreData: Bool = true

    let searchBar = UISearchBar()
    var searchButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = LocalizedString("Orders", comment: "")
        view.theme_backgroundColor = ColorPicker.backgroundColor
        historyTableView.theme_backgroundColor = ColorPicker.backgroundColor
        
        setupSearchBar()
        setBackButton()

        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.tableFooterView = UIView(frame: .zero)
        historyTableView.separatorStyle = .none
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 10))
        historyTableView.tableHeaderView = headerView
        historyTableView.refreshControl = refreshControl
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        getOrderHistoryFromRelay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSearching {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.pressSearchCancel))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isSearching = false
    }
    
    func setupSearchBar() {
        searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.pressOrderSearchButton(_:)))
        searchBar.showsCancelButton = false
        searchBar.placeholder = LocalizedString("Search", comment: "")
        searchBar.delegate = self
        searchBar.searchBarStyle = .default
        searchBar.keyboardType = .alphabet
        searchBar.autocapitalizationType = .allCharacters
        searchBar.keyboardAppearance = Themes.isDark() ? .dark : .default
        searchBar.theme_tintColor = GlobalPicker.textColor
        searchBar.textColor = Themes.isDark() ? UIColor.init(rgba: "#ffffffcc") : UIColor.init(rgba: "#000000cc")
        searchBar.setTextFieldColor(color: UIColor.dark3)
        self.navigationItem.setRightBarButton(searchButton, animated: true)
    }
    
    @objc func pressOrderSearchButton(_ button: UIBarButtonItem) {
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.pressSearchCancel))
        self.navigationItem.rightBarButtonItems = [cancelBarButton]
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        self.navigationItem.titleView = searchBarContainer
        
        searchBar.becomeFirstResponder()
    }
    
    @objc func pressSearchCancel(_ button: UIBarButtonItem) {
        print("pressSearchCancel")
        self.navigationItem.rightBarButtonItems = [searchButton]
        searchBar.resignFirstResponder()
        searchBar.text = nil
        navigationItem.titleView = nil
        self.navigationItem.title = LocalizedString("Orders", comment: "")
        isSearching = false
        searchTextDidUpdate(searchText: "")
        setBackButton()
    }
    
    @objc private func refreshData(_ sender: Any) {
        pageIndex = 1
        hasMoreData = true
        getOrderHistoryFromRelay()
    }
    
    func getOrderHistoryFromRelay() {
        OrderDataManager.shared.getOrdersFromServer(pageIndex: pageIndex, completionHandler: { _ in
            DispatchQueue.main.async {
                if self.isLaunching {
                    self.isLaunching = false
                }
                self.orders = OrderDataManager.shared.getOrders(type: .all)
                if self.previousOrderCount != self.orders.count {
                    self.hasMoreData = true
                } else {
                    self.hasMoreData = false
                }
                self.previousOrderCount = self.orders.count
                self.historyTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    func isTableEmpty() -> Bool {
        return orders.count == 0 && !isLaunching
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredOrders.count
        } else {
            return isTableEmpty() ? 1 : orders.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if orders.count == 0 {
            return 0
        }
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
        
        let labelWidth = (view.frame.size.width-15*2)/3
        let paddingX: CGFloat = 10
        
        let label1 = UILabel(frame: CGRect(x: paddingX, y: 0, width: labelWidth, height: 30))
        label1.theme_textColor = GlobalPicker.textLightColor
        label1.font = FontConfigManager.shared.getCharactorFont(size: 13)
        label1.text = LocalizedString("Market/Price", comment: "")
        label1.textAlignment = .left
        baseView.addSubview(label1)
        
        let label2Width = LocalizedString("Amount/Filled", comment: "").textWidth(font: FontConfigManager.shared.getCharactorFont(size: 13))
        let label2 = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width-15*2)*0.5-label2Width*0.5, y: 0, width: labelWidth, height: 30))
        label2.theme_textColor = GlobalPicker.textLightColor
        label2.font = FontConfigManager.shared.getCharactorFont(size: 13)
        label2.text = LocalizedString("Amount/Filled", comment: "")
        label2.textAlignment = .left
        baseView.addSubview(label2)
        
        let label3 = UILabel(frame: CGRect(x: baseView.width - labelWidth - 10, y: 0, width: labelWidth, height: 30))
        label3.theme_textColor = GlobalPicker.textLightColor
        label3.font = FontConfigManager.shared.getCharactorFont(size: 13)
        label3.text = LocalizedString("Status/Date", comment: "")
        label3.textAlignment = .right
        baseView.addSubview(label3)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isTableEmpty() {
            return OrderNoDataTableViewCell.getHeight()
        } else {
            return OrderTableViewCell.getHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isTableEmpty() {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderNoDataTableViewCell.getCellIdentifier()) as? OrderNoDataTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderNoDataTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderNoDataTableViewCell
            }
            cell?.noDataLabel.text = LocalizedString("No_Data_Tip", comment: "")
            cell?.noDataImageView.image = UIImage(named: "No-data-order")
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.getCellIdentifier()) as? OrderTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderTableViewCell
            }
            let order: Order
            if isSearching {
                order = filteredOrders[indexPath.row]
            } else {
                order = orders[indexPath.row]
            }
            cell?.order = order
            cell?.pressedCancelButtonClosure = {
                let title = LocalizedString("You are going to cancel the order.", comment: "")
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: LocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                    SendCurrentAppWalletDataManager.shared._cancelOrder(order: order.originalOrder, completion: { (txHash, error) in
                        self.getOrderHistoryFromRelay()
                        self.completion(txHash, error)
                    })
                }))
                alert.addAction(UIAlertAction(title: LocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
            }
            cell?.update()
            
            // Pagination
            if hasMoreData && indexPath.row == orders.count - 1 {
                pageIndex += 1
                getOrderHistoryFromRelay()
            }
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !isTableEmpty() else { return }
        let order: Order
        if isSearching {
            order = filteredOrders[indexPath.row]
        } else {
            order = orders[indexPath.row]
        }
        
        let viewController = OrderDetailViewController()
        viewController.order = order
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.view.endEditing(true)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - SearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar textDidChange \(searchText)")
        searchTextDidUpdate(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
        isSearching = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.pressSearchCancel))
        searchBar.becomeFirstResponder()
        
        // No need to reload nor call searchTextDidUpdate
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
    }

    func searchTextDidUpdate(searchText: String) {
        self.searchText = searchText.trim()
        if self.searchText != "" {
            isSearching = true
            filterContentForSearchText(self.searchText)
        } else {
            isSearching = false
            historyTableView.reloadSections(IndexSet(integersIn: 0...0), with: .fade)
        }
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let newFilteredOrders = OrderDataManager.shared.getOrders(type: .all).filter { (order) -> Bool in
            return order.originalOrder.market.lowercased().contains(searchText.lowercased())
        }
        filteredOrders = newFilteredOrders
        if historyTableView.contentOffset.y == 0 {
            historyTableView.reloadSections(IndexSet(integersIn: 0...0), with: .fade)
        } else {
            canHideKeyboard = false
            _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                self.canHideKeyboard = true
            }
            
            historyTableView.reloadData()
            // tableView.setContentOffset(.zero, animated: false)
            let topIndex = IndexPath(row: 0, section: 0)
            historyTableView.scrollToRow(at: topIndex, at: .top, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if canHideKeyboard {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

}

extension UpdatedOrderHistoryViewController {
    
    func completion(_ txHash: String?, _ error: Error?) {
        var title: String = ""
        guard error == nil && txHash != nil else {
            DispatchQueue.main.async {
                title = NSLocalizedString("Order cancellation Failed, Please try again.", comment: "")
                let banner = NotificationBanner.generate(title: title, style: .danger)
                banner.duration = 5
                banner.show()
            }
            return
        }
        DispatchQueue.main.async {
            print(txHash!)
            title = NSLocalizedString("Order cancellation Successful.", comment: "")
            let banner = NotificationBanner.generate(title: title, style: .success)
            banner.duration = 2
            banner.show()
        }
    }
}
