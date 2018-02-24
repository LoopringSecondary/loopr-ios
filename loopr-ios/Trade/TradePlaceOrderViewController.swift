//
//  TradePlaceOrderViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

protocol TradePlaceOrderDelegate: class {
    func closeTradePlaceOrderViewController()
}

class TradePlaceOrderViewController: UIViewController {

    weak var delegate: TradePlaceOrderDelegate?
    @IBOutlet weak var navigationBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.shadowImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedCloseButton(_ sender: Any) {
        delegate?.closeTradePlaceOrderViewController()
    }

}
