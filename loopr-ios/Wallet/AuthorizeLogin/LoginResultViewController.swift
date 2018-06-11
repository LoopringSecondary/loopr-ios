//
//  LoginResultViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/6/11.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class LoginResultViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var result: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        resultLabel.font = UIFont(name: FontConfigManager.shared.getBold(), size: 40.0)
        detailLabel.setHeaderFont()
        doneButton.title = NSLocalizedString("Done", comment: "")
        doneButton.setupRoundBlack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if result {
            resultLabel.text = NSLocalizedString("Authorze Successfully", comment: "")
            detailLabel.text = NSLocalizedString("Login Authorzation Successful! Please transfer to our website to continue.", comment: "")
        } else {
            resultLabel.text = NSLocalizedString("Authorze Failed", comment: "")
            detailLabel.text = NSLocalizedString("Login Authorzation failed! Please review your signing address and try again later.", comment: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedDoneButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
