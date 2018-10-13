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
    let refreshControl = UIRefreshControl()

    var transactions: [Transaction] = []
    var pageIndex: UInt = 1
    var hasMoreData: Bool = true
    
    // Mask view
    var blurVisualEffectView = UIView(frame: .zero)
    
    // Drag down to close a present view controller.
    var dismissInteractor = MiniToLargeViewInteractive()

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
        
        getTransactionsFromRelay()

        // Do any additional setup after loading the view.
        setBackButton()

        view.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.theme_backgroundColor = ColorPicker.backgroundColor

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 0))
        tableView.tableHeaderView = headerView
        
        view.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.theme_backgroundColor = ColorPicker.backgroundColor
        
        // Add Refresh Control to Table View
        tableView.refreshControl = refreshControl
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        blurVisualEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        blurVisualEffectView.alpha = 1
        blurVisualEffectView.frame = UIScreen.main.bounds
    }
    
    @objc private func refreshData(_ sender: Any) {
        pageIndex = 1
        hasMoreData = true
        getTransactionsFromRelay()
    }
    
    func getTransactionsFromRelay() {
        if let asset = asset {
            CurrentAppWalletDataManager.shared.getTransactionsFromServer(asset: asset, pageIndex: pageIndex) { (newTransactions, error) in
                guard error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    if self.isLaunching {
                        self.isLaunching = false
                    }
                    if newTransactions.count < 50 {
                        self.hasMoreData = false
                    }
                    if self.pageIndex == 1 {
                        self.transactions = self.sortTransactions(newTransactions)
                    } else {
                        self.transactions += self.sortTransactions(newTransactions)
                    }
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
            cell?.noDataImageView.image = UIImage(named: "No-data-transaction")
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetTransactionTableViewCell.getCellIdentifier()) as? AssetTransactionTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetTransactionTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetTransactionTableViewCell
            }
            cell?.transaction = self.transactions[indexPath.row]
            cell?.update()
            
            // Pagination
            if hasMoreData && indexPath.row == transactions.count - 1 {
                pageIndex += 1
                getTransactionsFromRelay()
            }
            
            return cell!
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isTableEmpty() else { return }
        tableView.deselectRow(at: indexPath, animated: false)
        let transaction = self.transactions[indexPath.row]
        
        let vc = AssetTransactionDetailViewController()
        vc.transaction = transaction
        vc.parentNavController = self.navigationController
        
        // TODO: drag to dismiss is broken.
        // vc.transitioningDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.dismissClosure = {
            UIView.animate(withDuration: 0.1, animations: {
                self.blurVisualEffectView.alpha = 0.0
            }, completion: {(_) in
                self.blurVisualEffectView.removeFromSuperview()
            })
        }
        
        dismissInteractor.percentThreshold = 0.2
        dismissInteractor.dismissClosure = {

        }
        
        self.present(vc, animated: true) {
            // self.dismissInteractor.attachToViewController(viewController: vc, withView: vc.view, presentViewController: nil, backgroundView: self.blurVisualEffectView)
        }
        
        self.navigationController?.view.addSubview(self.blurVisualEffectView)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurVisualEffectView.alpha = 1.0
        }, completion: {(_) in
            
        })
    }

}

extension AssetDetailViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // TODO: Have to disable this one.
        let animator = MiniToLargeViewAnimator()
        animator.transitionType = .Dismiss
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // guard !disableInteractivePlayerTransitioning else { return nil }
        return dismissInteractor
    }
    
}
