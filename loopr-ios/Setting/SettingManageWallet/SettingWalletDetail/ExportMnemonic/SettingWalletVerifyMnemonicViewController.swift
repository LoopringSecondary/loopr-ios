//
//  SettingWalletVerifyMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingWalletVerifyMnemonicViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Please Verify Your Mnemonic", comment: "")
        setBackButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
