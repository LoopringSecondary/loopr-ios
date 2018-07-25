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
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 10))
//        footerView.backgroundColor = UIStyleConfig.tableViewBackgroundColor
//        tableView.tableFooterView = footerView
        tableView.separatorStyle = .none
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // Receive button
        receiveButton.setTitle(LocalizedString("Receive", comment: ""), for: .normal)
        receiveButton.setupPrimary(height: 40)
        
        // Send button
        sendButton.setTitle(LocalizedString("Send", comment: ""), for: .normal)
        sendButton.setupSecondary(height: 40)
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        // Creating view for extending background color
//        var frame = tableView.bounds
//        frame.origin.y = -frame.size.height
//        let backgroundView = UIView(frame: frame)
//        backgroundView.autoresizingMask = .flexibleWidth
//        backgroundView.theme_backgroundColor = GlobalPicker.backgroundColor
//
//        // Adding the view below the refresh control
//        tableView.insertSubview(backgroundView, at: 0)
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
                    self.tableView.reloadData()
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AssetTransactionTableViewCell.getHeight()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: AssetTransactionTableViewCell.getCellIdentifier()) as? AssetTransactionTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("AssetTransactionTableViewCell", owner: self, options: nil)
            cell = nib![0] as? AssetTransactionTableViewCell
        }
        cell?.transaction = self.transactions[indexPath.row]
        cell?.update()
        return cell!
    }

    func reloadAfterSwipeViewUpdated() {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transaction = self.transactions[indexPath.row]
        let vc = AssetTransactionDetailViewController()
        vc.transaction = transaction
        vc.dismissClosure = { }
        vc.parentNavController = self.navigationController
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.present(vc, animated: true, completion: nil)
    }
}
