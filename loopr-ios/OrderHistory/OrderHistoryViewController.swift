//
//  OrderHistoryViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class OrderHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var orders: [String: [Order]] = [:]
    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.theme_backgroundColor = ["#fff", "#000"]
        historyTableView.theme_backgroundColor = ["#fff", "#000"]
        self.navigationItem.title = NSLocalizedString("Order History", comment: "")
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        historyTableView.dataSource = self
        historyTableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = orders.index(orders.startIndex, offsetBy: section)
        return orders[index].value.count
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
        let index = orders.index(orders.startIndex, offsetBy: indexPath.section)
        cell?.order = orders[index].value[indexPath.row]
        cell?.update()
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        headerView.backgroundColor = UIColor.clear
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 7, width: view.frame.size.width, height: 25))
        headerLabel.textColor = UIColor.gray
        let index = orders.index(orders.startIndex, offsetBy: section)
        headerLabel.text = orders.keys[index]
        headerView.addSubview(headerLabel)
        return headerView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return orders.keys.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
