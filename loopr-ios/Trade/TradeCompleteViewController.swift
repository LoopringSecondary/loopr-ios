//
//  TradeCompleteViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeCompleteViewController: UIViewController {

    @IBOutlet weak var checkDetailsButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setBackButton()

        checkDetailsButton.setTitle(NSLocalizedString("Check Details", comment: ""), for: .normal)
        
        checkDetailsButton.backgroundColor = UIColor.clear
        checkDetailsButton.titleColor = UIColor.black
        checkDetailsButton.layer.cornerRadius = 23
        checkDetailsButton.layer.borderWidth = 0.5
        checkDetailsButton.layer.borderColor = UIColor.black.cgColor
        checkDetailsButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        
        doneButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        
        doneButton.backgroundColor = UIColor.black
        doneButton.layer.cornerRadius = 23
        doneButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedCheckDetailsButton(_ sender: Any) {
        print("pressedCheckDetailsButton")
    }
    
    @IBAction func pressedDoneButton(_ sender: Any) {
        print("pressedDoneButton")
    }

}
