//
//  OrderHistoryViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class OrderHistoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Order History", comment: "")
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
