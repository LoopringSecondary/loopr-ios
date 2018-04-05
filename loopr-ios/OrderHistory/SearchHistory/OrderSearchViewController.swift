//
//  OrderSearchViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/3.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, CustomSearchControllerDelegate {

    @IBOutlet weak var resultTableView: UITableView!
    
    var searchRecord: [String] = []
    var filteredRecord: [String] = []
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var customSearchController: CustomSearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        configureSearchController()
//        configureCustomSearchController()
    }
    
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = UIStyleConfig.defaultTintColor
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0.0, y: 0.0, width: resultTableView.frame.size.width, height: 50.0), searchBarFont: UIFont(name: FontConfigManager.shared.getLight(), size: 16.0)!, searchBarTextColor: UIColor.gray, searchBarTintColor: UIColor.white)
        customSearchController.customSearchBar.placeholder = "Search"
        resultTableView.tableHeaderView = customSearchController.customSearchBar
        customSearchController.customDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
        if shouldShowSearchResults {
            cell.textLabel?.text = filteredRecord[indexPath.row]
        } else {
            cell.textLabel?.text = searchRecord[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredRecord.count
        } else {
            return searchRecord.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func didStartSearching() {
        shouldShowSearchResults = true
        resultTableView.reloadData()
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            resultTableView.reloadData()
        }
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        resultTableView.reloadData()
    }
    
    func didChangeSearchText(searchText: String) {
        filteredRecord = searchRecord.filter({ (record) -> Bool in
            return record.lowercased().range(of: searchText.lowercased()) != nil
        })
        resultTableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        filteredRecord = searchRecord.filter({ (record) -> Bool in
            return record.lowercased().range(of: searchText.lowercased()) != nil
        })
        resultTableView.reloadData()
    }
}
