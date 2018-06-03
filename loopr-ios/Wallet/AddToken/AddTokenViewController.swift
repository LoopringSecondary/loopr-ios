//
//  AddTokenViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AddTokenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var isSearching = false
    let searchBar = UISearchBar()
    var searchButton = UIBarButtonItem()
    var addCustomizedTokenButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.pressOrderSearchButton(_:)))
        addCustomizedTokenButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.pressAddButton(_:)))
        self.navigationItem.rightBarButtonItems = [addCustomizedTokenButton, searchButton]
        
        searchBar.showsCancelButton = false
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        
        self.navigationItem.title = NSLocalizedString("Tokens", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func pressAddButton(_ button: UIBarButtonItem) {
        let viewController = AddCustomizedTokenViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pressOrderSearchButton(_ button: UIBarButtonItem) {
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        
        self.navigationItem.titleView = searchBarContainer
        // self.navigationItem.leftBarButtonItem = nil
        // self.navigationItem.hidesBackButton = true
        
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.pressSearchCancel))
        self.navigationItem.rightBarButtonItems = [cancelBarButton]
        
        searchBar.becomeFirstResponder()
    }
    
    @objc func pressSearchCancel(_ button: UIBarButtonItem) {
        print("pressSearchCancel")
        self.navigationItem.rightBarButtonItems = [addCustomizedTokenButton, searchButton]
        searchBar.resignFirstResponder()
        searchBar.text = nil
        navigationItem.titleView = nil
        self.navigationItem.title = NSLocalizedString("Tokens", comment: "")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TokenDataManager.shared.getUnlistedTokensInCurrentAppWallet().count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AddTokenTableViewCell.getHeight()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: AddTokenTableViewCell.getCellIdentifier()) as? AddTokenTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("AddTokenTableViewCell", owner: self, options: nil)
            cell = nib![0] as? AddTokenTableViewCell
        }
        
        let token = TokenDataManager.shared.getUnlistedTokensInCurrentAppWallet()[indexPath.row]
        cell?.token = token
        cell?.update()
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - SearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar textDidChange \(searchText)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
        isSearching = true
        searchBar.becomeFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
    }

}
