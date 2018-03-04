//
//  BackupMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import TagListView

class BackupMnemonicViewController: UIViewController {

    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var verifyNowButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Backup Mnemonic", comment: "")
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        tagListView.textFont = UIFont.systemFont(ofSize: 17)
        tagListView.tagBackgroundColor = UIColor.black
        tagListView.cornerRadius = 15
        tagListView.paddingX = 15
        tagListView.paddingY = 10
        tagListView.marginX = 10
        tagListView.marginY = 10

        let mnemoic: [String] = WalletDataManager.shared.generateWalletAndReturnMnemonic()
        for value in mnemoic {
            tagListView.addTag(value)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedVerifyNowButton(_ sender: Any) {
        print("pressedVerifyNowButton")
        
    }
    
}
