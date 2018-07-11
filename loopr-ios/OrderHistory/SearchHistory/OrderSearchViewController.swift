//
//  OrderSearchViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/3.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CustomSearchControllerDelegate {
    
    @IBOutlet weak var resultTableView: UITableView!
    
    let searchBar = UISearchBar()
    
    var enteredSearchText = false
    var orders: [String: [Order]] = [:]
    var orderDates: [String] = []
    
    var historyRecord = Set<String>()
    var filteredRecord = Set<String>()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    // var customSearchController: CustomSearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultTableView.separatorStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        resultTableView.addGestureRecognizer(tap)
        setupHistoryRecord()
        setupSearchBar()

        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.pressedCancelButton))
        self.navigationItem.rightBarButtonItem = leftButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    @objc func tableTapped(tap: UITapGestureRecognizer) {
        let location = tap.location(in: resultTableView)
        let path = resultTableView.indexPathForRow(at: location)
        if let indexPathForRow = path {
            self.tableView(resultTableView, didSelectRowAt: indexPathForRow)
        } else {
            self.searchBar.resignFirstResponder()
        }
    }
    
    func setupHistoryRecord() {
        let defaults = UserDefaults.standard
        let key = UserDefaultsKeys.orderHistory.rawValue
        if let array = defaults.stringArray(forKey: key) {
            historyRecord = Set(array)
        }
    }
    
    func updateHistoryRecord() {
        let defaults = UserDefaults.standard
        let key = UserDefaultsKeys.orderHistory.rawValue
        defaults.set(historyRecord.map {$0}, forKey: key)
    }
    
    func setupSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.placeholder = LocalizedString("Search", comment: "")
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.keyboardType = .alphabet
        searchBar.autocapitalizationType  = .allCharacters
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
    }
    
    @objc func pressedCancelButton() {
        searchBar.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func configureSearchController() {

        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = LocalizedString("Search", comment: "") 
        searchController.searchBar.tintColor = UIStyleConfig.defaultTintColor
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.autocapitalizationType = .allCharacters
        searchController.searchBar.becomeFirstResponder()

        navigationItem.hidesBackButton = true
        navigationItem.titleView = searchController.searchBar
        navigationItem.rightBarButtonItem = nil
        //        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.becomeFirstResponder()
        definesPresentationContext = true
        shouldShowSearchResults  = false
    }
    
    /*
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0.0, y: 0.0, width: resultTableView.frame.size.width, height: 50.0), searchBarFont: UIFont(name: FontConfigManager.shared.getLight(), size: 16.0)!, searchBarTextColor: UIColor.gray, searchBarTintColor: UIColor.white)
        customSearchController.customSearchBar.placeholder = "Search"
        customSearchController.customSearchBar.autocapitalizationType = .allCharacters
        resultTableView.tableHeaderView = customSearchController.customSearchBar
        customSearchController.customDelegate = self
    }
    */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        headerView.backgroundColor = UIColor.white
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: view.frame.size.width, height: 25))
        headerLabel.textColor = UIColor.gray
        
        if enteredSearchText {
            headerLabel.text = orderDates[section]
        } else {
            headerLabel.text = LocalizedString("Search History", comment: "")
        }

        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHistoryToken(at index: Int) -> Token? {
        var result: Token?
        if shouldShowSearchResults {
            let index = filteredRecord.index(filteredRecord.startIndex, offsetBy: index)
            result = Token(symbol: filteredRecord[index])
        } else {
            let index = historyRecord.index(historyRecord.startIndex, offsetBy: index)
            result = Token(symbol: historyRecord[index])
        }
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if enteredSearchText {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.getCellIdentifier()) as? OrderTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderTableViewCell
            }
            cell?.order = orders[orderDates[indexPath.section]]![indexPath.row]
            cell?.update()
            return cell!
        } else {
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
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if enteredSearchText {
            let order = orders[orderDates[indexPath.section]]![indexPath.row]
            let viewController = OrderDetailViewController()
            viewController.order = order
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.view.endEditing(true)
            self.navigationController?.pushViewController(viewController, animated: true)
            
        } else {
            enteredSearchText = true

            if let token = getHistoryToken(at: indexPath.row) {
                searchBar.text = token.symbol
                
                orders = OrderDataManager.shared.getDateOrders(tokenSymbol: token.symbol)
                orderDates = orders.keys.sorted(by: >)
                
                resultTableView.reloadData()
                
                /*
                 let viewController = OrderSearchResultViewController()
                 viewController.token = token
                 viewController.hidesBottomBarWhenPushed = true
                 // present(viewController, animated: true, completion: nil)
                 */
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if enteredSearchText {
            return orders[orderDates[section]]!.count
        } else {
            if shouldShowSearchResults {
                return self.filteredRecord.count
            } else {
                return self.historyRecord.count
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if enteredSearchText {
            return orderDates.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if enteredSearchText {
            return OrderTableViewCell.getHeight()
        } else {
            return OrderHistorySearchResultCell.getHeight()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        enteredSearchText = false
        filteredRecord = historyRecord.filter({ (record) -> Bool in
            return record.lowercased().hasPrefix(searchText.lowercased())
        })
        shouldShowSearchResults = true
        resultTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // searchBar.resignFirstResponder()
        enteredSearchText = true
        if let searchText = searchBar.text {
            /*
            if let token = Token(symbol: searchText) {
                historyRecord.insert(searchText)
                let viewController = OrderSearchResultViewController()
                viewController.token = token
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            */
            if let _ = Token(symbol: searchText) {
                self.historyRecord.insert(searchText)
                updateHistoryRecord()
            }
            orders = OrderDataManager.shared.getDateOrders(tokenSymbol: searchText)
            orderDates = orders.keys.sorted(by: >)
            resultTableView.reloadData()
        }
    }
    
    func didStartSearching() {
        shouldShowSearchResults = true
        resultTableView.reloadData()
    }

    func didTapOnSearchButton(searchText: String?) {
        if let searchText = searchText {
            if let token = Token(symbol: searchText) {
                self.historyRecord.insert(searchText)
                updateHistoryRecord()
                let viewController = OrderSearchResultViewController()
                viewController.token = token
                viewController.hidesBottomBarWhenPushed = true
                present(viewController, animated: true, completion: nil)
            }
        }
    }

    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        resultTableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }

    func didChangeSearchText(searchText: String) {
        filteredRecord = historyRecord.filter({ (record) -> Bool in
            return record.lowercased().hasPrefix(searchText.lowercased())
        })
        shouldShowSearchResults = true
        resultTableView.reloadData()
    }
}
