//
//  P2POrderHistoryViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/16/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class P2POrderHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var isLaunching: Bool = true

    // These data need to be loaded when viewDidLoad() is called. Users can also pull to refresh the table view.
    var orderDates: [String] = []
    var orders: [String: [Order]] = [:]
    
    @IBOutlet weak var historyTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
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
        
        // TODO: Add search feature.
        /*
        let orderSearchButton = UIButton(type: UIButtonType.custom)
        let image = UIImage(named: "Order-history-black")
        orderSearchButton.setBackgroundImage(image, for: .normal)
        orderSearchButton.setBackgroundImage(image?.alpha(0.3), for: .highlighted)
        let item = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.pressOrderSearchButton(_:)))
        self.navigationItem.setRightBarButton(item, animated: true)
        */

        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            historyTableView.refreshControl = refreshControl
        } else {
            historyTableView.addSubview(refreshControl)
        }
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        getOrderHistoryFromRelay()
    }
    
    @objc func pressOrderSearchButton(_ button: UIBarButtonItem) {
        print("pressOrderSearchButton")        
        let viewController = OrderSearchViewController()
        let navigationController = UINavigationController.init(rootViewController: viewController)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = UIStyleConfig.defaultTintColor
        self.present(navigationController, animated: true, completion: nil)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isLaunching {
            return 0
        }
        if orders.keys.count == 0 {
            return 1
        }
        return orders.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLaunching {
            return 0
        }
        if orders.keys.count == 0 {
            return 1
        }
        return orders[orderDates[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if orders.keys.count == 0 {
            return 0
        }
        return 45
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OrderTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if orders.keys.count == 0 {
            return nil
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        headerView.backgroundColor = UIColor.white
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: view.frame.size.width, height: 45))
        headerLabel.textColor = UIColor.black.withAlphaComponent(0.3)
        headerLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 17)
        headerLabel.text = orderDates[section]
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
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.getCellIdentifier()) as? OrderTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderTableViewCell
            }
            cell?.order = orders[orderDates[indexPath.section]]![indexPath.row]
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
