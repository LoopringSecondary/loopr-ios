//
//  AssetDetailViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var buttonHeightLayoutConstraint: NSLayoutConstraint!

    var asset: Asset?
    var isLaunching: Bool = true
    var transactions: [String: [Transaction]] = [:]
    var transactionDates: [String] = []
    let refreshControl = UIRefreshControl()
    var contextMenuSourceView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

        tableView.dataSource = self
        tableView.delegate = self
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 10))
        footerView.backgroundColor = UIStyleConfig.tableViewBackgroundColor
        tableView.tableFooterView = footerView
        tableView.separatorStyle = .none
        
        view.backgroundColor = UIStyleConfig.tableViewBackgroundColor
        tableView.backgroundColor = UIStyleConfig.tableViewBackgroundColor
        
        // Receive button
        receiveButton.setTitle(LocalizedString("Receive", comment: ""), for: .normal)
        receiveButton.setupRoundBlack(height: 40)
        
        // Send button
        sendButton.setTitle(LocalizedString("Send", comment: ""), for: .normal)
        sendButton.setupRoundBlack(height: 40)
        
        buttonHeightLayoutConstraint.constant = 40
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        // Creating view for extending background color
        var frame = tableView.bounds
        frame.origin.y = -frame.size.height
        let backgroundView = UIView(frame: frame)
        backgroundView.autoresizingMask = .flexibleWidth
        backgroundView.backgroundColor = UIColor.white
        
        // Adding the view below the refresh control
        tableView.insertSubview(backgroundView, at: 0)
    }
    
    func setup() {
        // TODO: putting getMarketsFromServer() here may cause a race condition.
        // It's not perfect, but works. Need improvement in the future.
        // self.transactions = CurrentAppWalletDataManager.shared.getTransactions()
        getTransactionsFromRelay()
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Data
        getTransactionsFromRelay()
    }
    
    func getTransactionsFromRelay() {
        if let asset = asset {
            CurrentAppWalletDataManager.shared.getTransactionsFromServer(asset: asset) { (transactions, error) in
                guard error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    if self.isLaunching {
                        self.isLaunching = false
                    }
                    self.transactions = transactions
                    self.transactionDates = transactions.keys.sorted(by: >)
                    self.tableView.reloadData()
                    // self.tableView.reloadSections(IndexSet(integersIn: 1...1), with: .fade)
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isLaunching {
            getTransactionsFromRelay()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func pressedSendButton(_ sender: Any) {
        print("pressedSendButton")
        let viewController = SendAssetViewController()
        viewController.asset = self.asset!
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func pressedReceiveButton(_ sender: Any) {
        print("pressedReceiveButton")
        let viewController = QRCodeViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionDates.count + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    	if section == 1 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
            headerView.backgroundColor = UIColor.white
            let headerLabel = UILabel(frame: CGRect(x: 16, y: 7, width: view.frame.size.width, height: 25))
            headerLabel.text = transactionDates[section - 1]
            headerLabel.setSubTitleFont()
            headerView.addSubview(headerLabel)
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return transactions[transactionDates[section]]!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return AssetBalanceTableViewCell.getHeight()
        } else {
            return UpdatedAssetTransactionTableViewCell.getHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return AssetBalanceTableViewCell.getHeight()
        } else {
            return AssetTransactionTableViewCell.getHeight()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetBalanceTableViewCell.getCellIdentifier()) as? AssetBalanceTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetBalanceTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetBalanceTableViewCell
                cell?.selectionStyle = .none
            }
            cell?.asset = asset
            cell?.update()
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: UpdatedAssetTransactionTableViewCell.getCellIdentifier()) as? UpdatedAssetTransactionTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("UpdatedAssetTransactionTableViewCell", owner: self, options: nil)
                cell = nib![0] as? UpdatedAssetTransactionTableViewCell
            }
            cell?.transaction = self.transactions[transactionDates[indexPath.section]]![indexPath.row]
            cell?.update()
            return cell!
        }
    }

    @objc func goToMarket(_ sender: AnyObject) {
        if let asset = self.asset {
            if asset.symbol.lowercased() == "eth" || asset.symbol.lowercased() == "weth" {
                let viewController = ConvertETHViewController()
                viewController.asset = asset
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let tradingPair = "\(asset.symbol)/WETH"
                let market = MarketDataManager.shared.getMarket(byTradingPair: tradingPair)
                guard market != nil else {
                    return
                }
                PlaceOrderDataManager.shared.new(tokenA: asset.symbol, tokenB: "WETH", market: market!)
                let viewController = BuyAndSellSwipeViewController()
                viewController.initialType = .buy
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section >= 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            let transaction = self.transactions[transactionDates[indexPath.section]]![indexPath.row]
            let vc = AssetTransactionDetailViewController()
            vc.transaction = transaction
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
