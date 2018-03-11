//
//  PlaceOrderConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class PlaceOrderConfirmationViewController: UIViewController {

    @IBOutlet weak var confirmationButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.navigationItem.title = NSLocalizedString("Confirmation", comment: "")
        
        confirmationButton.title = NSLocalizedString("Confirmation", comment: "")
        confirmationButton.backgroundColor = UIColor.black
        confirmationButton.layer.cornerRadius = 23
        confirmationButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedConfirmationButton(_ sender: Any) {
        print("pressedConfirmationButton")
    }

}
