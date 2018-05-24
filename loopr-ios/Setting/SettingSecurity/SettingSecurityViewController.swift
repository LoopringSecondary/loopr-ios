//
//  SettingSecurityViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/23/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingSecurityViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Security Settings", comment: "")
        setBackButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
