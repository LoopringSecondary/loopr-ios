//
//  OrderSearchViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/3.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomSearchControllerDelegate {
    
    @IBOutlet weak var resultTableView: UITableView!
    
    var historyRecord = Set<String>()
    var filteredRecord = Set<String>()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var customSearchController: CustomSearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resultTableView.delegate = self
        resultTableView.dataSource = self
//        configureSearchController()
        configureCustomSearchController()
        setupHistoryRecord()
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
        defaults.set(historyRecord.map{$0}, forKey: key)
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = UIStyleConfig.defaultTintColor
        searchController.searchBar.sizeToFit()
        searchController.searchBar.autocapitalizationType = .allCharacters
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
        shouldShowSearchResults  = false
    }
    
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0.0, y: 0.0, width: resultTableView.frame.size.width, height: 50.0), searchBarFont: UIFont(name: FontConfigManager.shared.getLight(), size: 16.0)!, searchBarTextColor: UIColor.gray, searchBarTintColor: UIColor.white)
        customSearchController.customSearchBar.placeholder = "Search"
        customSearchController.customSearchBar.autocapitalizationType = .allCharacters
        resultTableView.tableHeaderView = customSearchController.customSearchBar
        customSearchController.customDelegate = self
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        headerView.backgroundColor = UIColor.white
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: view.frame.size.width, height: 25))
        headerLabel.textColor = UIColor.gray
        headerLabel.text = "Search History"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let token = getHistoryToken(at: indexPath.row) {
            let viewController = OrderSearchResultViewController()
            viewController.token = token
            viewController.hidesBottomBarWhenPushed = true
            present(viewController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return self.filteredRecord.count
        } else {
            return self.historyRecord.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        OrderSearchViewController.filteredRecord = OrderSearchViewController.historyRecord.filter({ (record) -> Bool in
//            return record.lowercased().hasPrefix(searchText.lowercased())
//        })
//        shouldShowSearchResults = true
//        resultTableView.reloadData()
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        if let searchText = searchBar.text {
//            if let token = Token(symbol: searchText) {
//                OrderSearchViewController.historyRecord.insert(searchText)
//                let viewController = OrderSearchResultViewController()
//                viewController.token = token
//                viewController.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(viewController, animated: true)
//            }
//        }
//    }
    
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
