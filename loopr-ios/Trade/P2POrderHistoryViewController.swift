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
    var orderDates: [String] = []
    var orders: [String: [Order]] = [:]
    private let refreshControl = UIRefreshControl()
    var viewAppear: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        historyTableView.theme_backgroundColor = GlobalPicker.backgroundColor
        self.navigationItem.title = LocalizedString("P2P Order History", comment: "")
        setBackButton()
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.tableFooterView = UIView()
        historyTableView.separatorStyle = .none
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 8))
        headerView.theme_backgroundColor = GlobalPicker.backgroundColor
        historyTableView.tableHeaderView = headerView

        // Add Refresh Control to Table View
        historyTableView.refreshControl = refreshControl
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        getOrderHistoryFromRelay()
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Data
        getOrderHistoryFromRelay()
    }
    
    func getOrderHistoryFromRelay() {
        P2POrderHistoryDataManager.shared.getOrdersFromServer(completionHandler: { orders, _ in
            DispatchQueue.main.async {
                if self.isLaunching {
                    self.isLaunching = false
                }
                self.orders = P2POrderHistoryDataManager.shared.getDateOrders(orderStatuses: nil)
                self.orderDates = self.orders.keys.sorted(by: >)
                self.historyTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    func isTableEmpty() -> Bool {
        return orders.keys.count == 0 && !isLaunching
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isTableEmpty() ? 1 : orders.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isTableEmpty() ? 1 : orders[orderDates[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if orders.keys.count == 0 {
            return 0
        }
        return 40
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isTableEmpty() {
            return OrderNoDataTableViewCell.getHeight()
        }
        return OrderTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isTableEmpty() {
            return nil
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        headerView.theme_backgroundColor = GlobalPicker.backgroundColor
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        headerLabel.theme_textColor = GlobalPicker.textLightColor
        headerLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        headerLabel.text = orderDates[section]
        headerLabel.textAlignment = .center
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if orders.keys.count == 0 {
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
            let order = orders[orderDates[indexPath.section]]![indexPath.row]
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
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if orders.keys.count == 0 {
            return
        }
        let order = orders[orderDates[indexPath.section]]![indexPath.row]
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
                title = LocalizedString("Order cancelled Failed, Please try again.", comment: "")
                let banner = NotificationBanner.generate(title: title, style: .danger)
                banner.duration = 5
                banner.show()
            }
            return
        }
        DispatchQueue.main.async {
            title = LocalizedString("Order cancelled Successful.", comment: "")
            let banner = NotificationBanner.generate(title: title, style: .success)
            banner.duration = 2
            banner.show()
        }
    }
}
