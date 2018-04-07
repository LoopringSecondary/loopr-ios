//
//  OrderSearchResultViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderSearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var token: Token?
    var orderDates: [String] = []
    var orders: [String: [Order]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        orders = OrderDataManager.shared.getDataOrders(token: token?.symbol)
        orderDates = orders.keys.sorted(by: >)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderDates.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        headerView.backgroundColor = UIColor.white
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: view.frame.size.width, height: 25))
        headerLabel.textColor = UIColor.gray
        headerLabel.text = orderDates[section]
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders[orderDates[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OrderHistoryTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: OrderHistoryTableViewCell.getCellIdentifier()) as? OrderHistoryTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("OrderHistoryTableViewCell", owner: self, options: nil)
            cell = nib![0] as? OrderHistoryTableViewCell
        }
        cell?.order = orders[orderDates[indexPath.section]]![indexPath.row]
        cell?.update()
        return cell!
    }
}
