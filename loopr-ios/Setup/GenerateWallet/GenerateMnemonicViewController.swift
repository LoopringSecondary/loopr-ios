//
//  GenerateMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateMnemonicViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        view.theme_backgroundColor = GlobalPicker.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedBackupNowButton(_ sender: Any) {
        print("pressedBackupNowButton")
        let viewController = BackupMnemonicViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
