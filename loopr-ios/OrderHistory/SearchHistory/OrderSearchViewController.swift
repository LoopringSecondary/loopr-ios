//
//  OrderSearchViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/3.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomSearchControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var searchRecord: [String] = []
    var filteredRecord: [String] = []
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var customSearchController: CustomSearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureCustomSearchController()
    }
    
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 50.0), searchBarFont: UIFont(name: "Futura", size: 16.0)!, searchBarTextColor: UIColor.orange, searchBarTintColor: UIColor.black)
        customSearchController.customSearchBar.placeholder = "Search"
        tableView.tableHeaderView = customSearchController.customSearchBar
        customSearchController.customDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func didStartSearching() {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func didChangeSearchText(searchText: String) {
        filteredRecord = searchRecord.filter({ (record) -> Bool in
            return record.lowercased().range(of: searchText.lowercased()) != nil
        })
        tableView.reloadData()
    }
}
