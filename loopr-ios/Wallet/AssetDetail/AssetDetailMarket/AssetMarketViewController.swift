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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let padding: CGFloat = 15
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        // headerView.theme_backgroundColor = GlobalPicker.backgroundColor
        headerView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        
        let label = UILabel(frame: CGRect(x: padding, y: 0, width: view.frame.size.width, height: 45))
        label.theme_textColor = GlobalPicker.textColor
        label.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 17)
        headerView.addSubview(label)
        
        if section == 0 {
            label.text = LocalizedString("Loopring DEX Markets", comment: "")
        } else if section == 1 {
            label.text = LocalizedString("Reference Markets", comment: "")
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return markets.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 0
        case 1:
            return AssetMarketTableViewCell.getHeight()
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return UITableViewCell()
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetMarketTableViewCell.getCellIdentifier()) as? AssetMarketTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetMarketTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetMarketTableViewCell
                cell?.selectionStyle = .none
            }
            cell?.market = markets[indexPath.row]
            cell?.update()
            return cell!
        default:
            return UITableViewCell()
        }
    }

}
