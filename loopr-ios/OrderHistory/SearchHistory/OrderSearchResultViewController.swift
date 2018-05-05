//
//  OrderSearchResultViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderSearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomSearchControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var token: Token?
    var orderDates: [String] = []
    var orders: [String: [Order]] = [:]
    var isFiltering = false
    var historyRecord = Set<String>()
    var filteredRecord = Set<String>()
    var customSearchController: CustomSearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        configureCustomSearchController()
        updateOrders()
        setupHistoryRecord()
    }
    
    func setupHistoryRecord() {
        let defaults = UserDefaults.standard
        let key = UserDefaultsKeys.orderHistory.rawValue
        if let array = defaults.stringArray(forKey: key) {
            historyRecord = Set(array)
        }
    }
    
    func updateOrders() {
        orders = OrderDataManager.shared.getDateOrders(tokenSymbol: token?.symbol)
        orderDates = orders.keys.sorted(by: >)
    }
    
    func updateHistoryRecord() {
        let defaults = UserDefaults.standard
        let key = UserDefaultsKeys.orderHistory.rawValue
        defaults.set(historyRecord.map {$0}, forKey: key)
    }
    
    func getHistoryToken(at index: Int) -> Token? {
        var result: Token?
        if isFiltering {
            let index = filteredRecord.index(filteredRecord.startIndex, offsetBy: index)
            result = Token(symbol: filteredRecord[index])
        } else {
            let index = historyRecord.index(historyRecord.startIndex, offsetBy: index)
            result = Token(symbol: historyRecord[index])
        }
        return result
    }

    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 50.0), searchBarFont: UIFont(name: FontConfigManager.shared.getLight(), size: 16.0)!, searchBarTextColor: UIColor.gray, searchBarTintColor: UIColor.white)
        customSearchController.customSearchBar.text = token!.symbol
        customSearchController.customSearchBar.autocapitalizationType = .allCharacters
        customSearchController.customSearchBar.showsCancelButton = true
        customSearchController.customDelegate = self
        tableView.tableHeaderView = customSearchController.customSearchBar
        definesPresentationContext = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        } else {
            return orderDates.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        headerView.backgroundColor = UIColor.white
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: view.frame.size.width, height: 25))
        headerLabel.textColor = UIColor.gray
        headerLabel.text = isFiltering ? "Search History" : orderDates[section]
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredRecord.count
        } else {
            return orders[orderDates[section]]!.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OrderHistoryTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFiltering {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderHistorySearchResultCell.getCellIdentifier()) as? OrderHistorySearchResultCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderHistorySearchResultCell", owner: self, options: nil)
                cell = nib![0] as? OrderHistorySearchResultCell
            }
            if let token = getHistoryToken(at: indexPath.row) {
                cell?.token = token
                cell?.update()
            }
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderHistoryTableViewCell.getCellIdentifier()) as? OrderHistoryTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderHistoryTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderHistoryTableViewCell
            }
            cell?.order = orders[orderDates[indexPath.section]]![indexPath.row]
            cell?.update()
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isFiltering {
            if let token = getHistoryToken(at: indexPath.row) {
                self.token = token
                self.updateOrders()
                self.isFiltering = false
                self.tableView.reloadData()
                self.customSearchController.customSearchBar.text = token.symbol
            }
        } else {
            let order = orders[orderDates[indexPath.section]]![indexPath.row]
            let viewController = OrderDetailViewController()
            viewController.order = order
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func didStartSearching() {
        isFiltering = true
        tableView.reloadData()
    }
    
    func didTapOnCancelButton() {
        isFiltering = false
        tableView.reloadData()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func didTapOnSearchButton(searchText: String?) {
        if let searchText = searchText {
            if let token = Token(symbol: searchText) {
                self.historyRecord.insert(searchText)
                self.updateHistoryRecord()
                self.token = token
                self.updateOrders()
                self.isFiltering = false
                self.tableView.reloadData()
            }
        }
    }
    
    func didChangeSearchText(searchText: String) {
        self.isFiltering = true
        self.filteredRecord = historyRecord.filter({ (record) -> Bool in
            return record.lowercased().range(of: searchText.lowercased()) != nil
        })
        self.tableView.reloadData()
    }
}
