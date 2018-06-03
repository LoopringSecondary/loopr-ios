//
//  AssetMarketViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetMarketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var asset: Asset?
    var markets: [Market] = []

    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    var isLaunching: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none

        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        getTickersFromRelay()
    }

    @objc private func refreshData(_ sender: Any) {
        // Fetch Data
        getTickersFromRelay()
    }
    
    func getTickersFromRelay() {
        if let asset = asset {
            let market = "\(asset.symbol)-WETH"
            LoopringAPIRequest.getTickers(market: market, completionHandler: { (markets, error) in
                guard error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    if self.isLaunching {
                        self.isLaunching = false
                    }
                    self.markets = markets
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return markets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AssetMarketTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: AssetMarketTableViewCell.getCellIdentifier()) as? AssetMarketTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("AssetMarketTableViewCell", owner: self, options: nil)
            cell = nib![0] as? AssetMarketTableViewCell
            cell?.selectionStyle = .none
        }
        cell?.market = markets[indexPath.row]
        cell?.update()
        return cell!
    }

}
