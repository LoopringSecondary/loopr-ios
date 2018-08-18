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
    
    var asset: Asset?
    var type: TxSwipeViewType
    var viewAppear: Bool = false
    var isLaunching: Bool = true
    var transactions: [Transaction] = []
    let refreshControl = UIRefreshControl()
    var contextMenuSourceView: UIView = UIView()
    
    convenience init(type: TxSwipeViewType) {
        self.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        type = .all
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
        setBackButton()

        view.theme_backgroundColor = GlobalPicker.backgroundColor
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 8))
        tableView.tableHeaderView = headerView
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
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
                    self.transactions = self.sortTransactions(transactions)
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func sortTransactions(_ transsactions: [Transaction]) -> [Transaction] {
        var result: [Transaction] = []
        switch self.type {
        case .status:
            result = transsactions.sorted { (tx1, tx2) -> Bool in
                return tx1.status.description > tx2.status.description
            }
        case .type:
            result = transsactions.sorted { (tx1, tx2) -> Bool in
                return tx1.type.description < tx2.type.description
            }
        default:
            result = transsactions.sorted { (tx1, tx2) -> Bool in
                return tx1.createTime > tx2.createTime
            }
        }
        return result
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func isTableEmpty() -> Bool {
        return transactions.count == 0 && !isLaunching
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isTableEmpty() ? 1 : transactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isTableEmpty() {
            return OrderNoDataTableViewCell.getHeight() - 120
        } else {
            return AssetTransactionTableViewCell.getHeight()
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
            cell?.noDataImageView.image = #imageLiteral(resourceName: "No-data-transaction")
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetTransactionTableViewCell.getCellIdentifier()) as? AssetTransactionTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetTransactionTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetTransactionTableViewCell
            }
            cell?.transaction = self.transactions[indexPath.row]
            cell?.update()
            return cell!
        }
    }

    func reloadAfterSwipeViewUpdated() {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // https://stackoverflow.com/questions/22585416/slow-performance-for-presentviewcontroller-depends-on-complexity-of-presenting
        // https://stackoverflow.com/questions/21075540/presentviewcontrolleranimatedyes-view-will-not-appear-until-user-taps-again
        // Set animated to false or put self.present in DispatchQueue.main.async
        tableView.deselectRow(at: indexPath, animated: false)
        let transaction = self.transactions[indexPath.row]
        let parentView = self.parent!.view!
        parentView.alpha = 0.25
        
        let vc = AssetTransactionDetailViewController()
        vc.transaction = transaction
        vc.dismissClosure = { parentView.alpha = 1 }
        vc.parentNavController = self.navigationController
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.present(vc, animated: true, completion: nil)
    }
}
