//
//  DisplayPrivateKeyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class DisplayPrivateKeyViewController: UIViewController {

    var appWallet: AppWallet!

    @IBOutlet weak var privateKeyTextView: UITextView!
    @IBOutlet weak var copyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = LocalizedString("Export Private Key", comment: "")
        setBackButton()
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        privateKeyTextView.contentInset = UIEdgeInsets.init(top: 17, left: 20, bottom: 15, right: 20)
        privateKeyTextView.cornerRadius = 6
        privateKeyTextView.font = FontConfigManager.shared.getRegularFont(size: 14)
        privateKeyTextView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        privateKeyTextView.theme_textColor = GlobalPicker.textColor
        privateKeyTextView.isEditable = false
        // privateKeyTextView.isScrollEnabled = false
        
        privateKeyTextView.text = appWallet.privateKey
        
        copyButton.title = LocalizedString("Copy Private Key", comment: "")
        copyButton.setupSecondary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedCopyButton(_ sender: Any) {
        print("pressedCopyButton")
        UIPasteboard.general.string = appWallet.privateKey
        let banner = NotificationBanner.generate(title: "Copy private key to clipboard successfully!", style: .success)
        banner.duration = 1
        banner.show()
    }
    
}
