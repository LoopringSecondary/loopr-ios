//
//  MarketDetailDepthViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/28/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailDepthViewController: UIViewController {

    var market: Market!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        tableView.separatorStyle = .none
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        getDataFromRelay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getDataFromRelay() {
        DepthDataManager.shared.getDepthFromServer(market: market.name, completionHandler: { sells, buys, _ in
            
        })
    }

}
