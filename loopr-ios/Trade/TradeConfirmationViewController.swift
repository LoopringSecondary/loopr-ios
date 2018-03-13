//
//  TradeConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeConfirmationViewController: UIViewController {

    @IBOutlet weak var placeOrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.navigationItem.title = NSLocalizedString("Confirmation", comment: "")
        
        placeOrderButton.title = NSLocalizedString("Place Order", comment: "")
        placeOrderButton.backgroundColor = UIColor.black
        placeOrderButton.layer.cornerRadius = 23
        placeOrderButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedPlaceOrderButton(_ sender: Any) {
        print("pressedPlaceOrderButton")
    }
    
}
