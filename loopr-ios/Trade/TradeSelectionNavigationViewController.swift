//
//  TradeSelectionNavigationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/8/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeSelectionNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tradeSelectionViewController = TradeSelectionViewController()
        navigationBar.shadowImage = UIImage()
        setViewControllers([tradeSelectionViewController], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
