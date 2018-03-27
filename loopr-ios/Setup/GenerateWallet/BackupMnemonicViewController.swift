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

    var titleLabel: UILabel =  UILabel()
    var infoTextView: UITextView = UITextView()

    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var verifyNowButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationItem.title = NSLocalizedString("Backup Mnemonic", comment: "")
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        titleLabel.frame = CGRect(x: padding, y: originY, width: screenWidth - padding * 2, height: 30)
        titleLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 27)
        titleLabel.text = NSLocalizedString("Please Write Down", comment: "")
        view.addSubview(titleLabel)
        
        infoTextView.frame = CGRect(x: padding-3, y: 72, width: screenWidth - (padding-3) * 2, height: 96)
        infoTextView.isEditable = false
        infoTextView.text = "Please make sure you have recorded all the words safely. Otherwise, you will not be able to go through the verification process, and have to start over."
        infoTextView.textColor = UIColor.black.withAlphaComponent(0.6)
        infoTextView.font = FontConfigManager.shared.getLabelFont(size: 17)
        view.addSubview(infoTextView)
        
        tagListView.textFont = UIFont.systemFont(ofSize: 14)
        tagListView.tagBackgroundColor = UIColor.black
        tagListView.cornerRadius = 15
        tagListView.paddingX = 15
        tagListView.paddingY = 10
        tagListView.marginX = 10
        tagListView.marginY = 10

        let mnemoic: [String] = GenerateWalletDataManager.shared.getMnemonic()
        for value in mnemoic {
            tagListView.addTag(value)
        }

        verifyNowButton.title = NSLocalizedString("Verify Now", comment: "Go to VerifyMnemonicViewController")
        verifyNowButton.setupRoundBlack()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedVerifyNowButton(_ sender: Any) {
        print("pressedVerifyNowButton")
        let viewController = VerifyMnemonicViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
