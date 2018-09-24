//
//  P2POrderHistoryViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/16/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class P2POrderHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var historyTableView: UITableView!

    var isLaunching: Bool = true

    // These data need to be loaded when viewDidLoad() is called. Users can also pull to refresh the table view.
    var orders: [Order] = []

    private let refreshControl = UIRefreshControl()
    var viewAppear: Bool = false
    
    var previousOrderCount: Int = 0
    var pageIndex: UInt = 1
    var hasMoreData: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.theme_backgroundColor = ColorPicker.backgroundColor
        historyTableView.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("P2P Order History", comment: "")
        setBackButton()
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.tableFooterView = UIView()
        historyTableView.separatorStyle = .none
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 8))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        historyTableView.tableHeaderView = headerView

        // Add Refresh Control to Table View
        historyTableView.refreshControl = refreshControl
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        P2POrderHistoryDataManager.shared.shouldReloadData = false
        getOrderHistoryFromRelay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if P2POrderHistoryDataManager.shared.shouldReloadData {
            pageIndex = 1
            hasMoreData = true
            getOrderHistoryFromRelay()
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        pageIndex = 1
        hasMoreData = true
        getOrderHistoryFromRelay()
    }
    
    func getOrderHistoryFromRelay() {
        P2POrderHistoryDataManager.shared.getOrdersFromServer(pageIndex: self.pageIndex, completionHandler: { orders, _ in
            DispatchQueue.main.async {
                if self.isLaunching {
                    self.isLaunching = false
                }
                self.orders = P2POrderHistoryDataManager.shared.getOrders(orderStatuses: nil)
                if self.previousOrderCount != self.orders.count {
                    self.hasMoreData = true
                } else {
                    self.hasMoreData = false
                }
                self.previousOrderCount = self.orders.count
                self.historyTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    func isTableEmpty() -> Bool {
        return orders.count == 0 && !isLaunching
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isTableEmpty() ? 1 : orders.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if orders.count == 0 {
            return 0
        }
        return 30+0.5
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenWidth = view.frame.size.width
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30+0.5))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        
        let baseView = UIView(frame: CGRect(x: 15, y: 0, width: screenWidth - 15*2, height: 30))
        baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        baseView.round(corners: [.topLeft, .topRight], radius: 6)
        headerView.addSubview(baseView)
        
        let labelWidth = (view.frame.size.width-15*2)/3
        let paddingX: CGFloat = 10
        
        let label1 = UILabel(frame: CGRect(x: paddingX, y: 0, width: labelWidth, height: 30))
        label1.theme_textColor = GlobalPicker.textLightColor
        label1.font = FontConfigManager.shared.getCharactorFont(size: 13)
        label1.text = LocalizedString("Market/Price", comment: "")
        label1.textAlignment = .left
        baseView.addSubview(label1)
        
        let label2 = UILabel(frame: CGRect(x: UIScreen.main.bounds.width*0.3+paddingX, y: 0, width: labelWidth, height: 30))
        label2.theme_textColor = GlobalPicker.textLightColor
        label2.font = FontConfigManager.shared.getCharactorFont(size: 13)
        label2.text = LocalizedString("Amount/Filled", comment: "")
        label2.textAlignment = .left
        baseView.addSubview(label2)
        
        let label3 = UILabel(frame: CGRect(x: baseView.width - labelWidth - 10, y: 0, width: labelWidth, height: 30))
        label3.theme_textColor = GlobalPicker.textLightColor
        label3.font = FontConfigManager.shared.getCharactorFont(size: 13)
        label3.text = LocalizedString("Status/Date", comment: "")
        label3.textAlignment = .right
        baseView.addSubview(label3)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isTableEmpty() {
            return OrderNoDataTableViewCell.getHeight()
        }
        return OrderTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if orders.count == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderNoDataTableViewCell.getCellIdentifier()) as? OrderNoDataTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderNoDataTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderNoDataTableViewCell
            }
            cell?.noDataLabel.text = LocalizedString("No_Data_Tip", comment: "")
            cell?.noDataImageView.image = #imageLiteral(resourceName: "No-data-order")
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.getCellIdentifier()) as? OrderTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderTableViewCell
            }
            let order = orders[indexPath.row]
            cell?.order = order
            cell?.pressedCancelButtonClosure = {
                let title = LocalizedString("You are going to cancel the order.", comment: "")
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: LocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                    SendCurrentAppWalletDataManager.shared._cancelOrder(order: order.originalOrder, completion: { (txHash, error) in
                        self.getOrderHistoryFromRelay()
                        self.completion(txHash, error)
                    })
                }))
                alert.addAction(UIAlertAction(title: LocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
                }))

                self.present(alert, animated: true, completion: nil)
            }
            cell?.update()
            
            // Pagination
            if hasMoreData && indexPath.row == orders.count - 1 {
                pageIndex += 1
                getOrderHistoryFromRelay()
            }
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if orders.count == 0 {
            return
        }
        let order = orders[indexPath.row]
        let viewController = OrderDetailViewController()
        viewController.order = order
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension P2POrderHistoryViewController {
    
    func completion(_ txHash: String?, _ error: Error?) {
        var title: String = ""
        guard error == nil && txHash != nil else {
            DispatchQueue.main.async {
                title = LocalizedString("Order cancellation Failed, Please try again.", comment: "")
                let banner = NotificationBanner.generate(title: title, style: .danger)
                banner.duration = 5
                banner.show()
            }
            return
        }
        DispatchQueue.main.async {
            title = LocalizedString("Order cancellation Successful.", comment: "")
            let banner = NotificationBanner.generate(title: title, style: .success)
            banner.duration = 2
            banner.show()
        }
    }
}
