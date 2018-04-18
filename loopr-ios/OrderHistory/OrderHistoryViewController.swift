//
//  OrderHistoryViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class OrderHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var orderDates: [String] = []
    var orders: [String: [Order]] = [:]

    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.theme_backgroundColor = ["#fff", "#000"]
        historyTableView.theme_backgroundColor = ["#fff", "#000"]
        self.navigationItem.title = NSLocalizedString("Order History", comment: "")
        setBackButton()
        historyTableView.dataSource = self
        historyTableView.delegate = self
        orderDates = orders.keys.sorted(by: >)
        
        let orderSearchButton = UIButton(type: UIButtonType.custom)
        let image = UIImage(named: "Order-history-black")
        orderSearchButton.setBackgroundImage(image, for: .normal)
        orderSearchButton.setBackgroundImage(image?.alpha(0.3), for: .highlighted)
        let item = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.pressOrderSearchButton(_:)))
        self.navigationItem.setRightBarButton(item, animated: true)
    }
    
    @objc func pressOrderSearchButton(_ button: UIBarButtonItem) {
        print("pressOrderSearchButton")
        let viewController = OrderSearchViewController()
        // viewController.hidesBottomBarWhenPushed = true
        
        self.present(viewController, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = orders[orderDates[indexPath.section]]![indexPath.row]
        let viewController = OrderDetailViewController()
        viewController.order = order
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return orders.keys.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
