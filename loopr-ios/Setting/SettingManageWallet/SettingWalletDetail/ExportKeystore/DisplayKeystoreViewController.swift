//
//  DisplayKeystoreViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class DisplayKeystoreViewController: UIViewController {
    
    var keystore: String = ""
    
    @IBOutlet weak var keystoreTextView: UITextView!
    @IBOutlet weak var copyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor

        keystoreTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        // privateKeyTextView.contentOffset = CGPoint(x: 0, y: -10)
        
        keystoreTextView.cornerRadius = 12
        keystoreTextView.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 12.0)
        keystoreTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        keystoreTextView.textColor = UIColor.black
        keystoreTextView.isEditable = false
        
        keystoreTextView.contentInset = UIEdgeInsets.init(top: 17, left: 20, bottom: 15, right: 20)
        keystoreTextView.cornerRadius = 6
        keystoreTextView.font = FontConfigManager.shared.getRegularFont(size: 14)
        keystoreTextView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        keystoreTextView.theme_textColor = GlobalPicker.textColor
        keystoreTextView.isEditable = false
        
        keystoreTextView.text = keystore

        copyButton.title = LocalizedString("Copy Keystore", comment: "")
        copyButton.setupSecondary(height: 44)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keystoreTextView.applyShadow()
    }

    @IBAction func pressedCopyButton(_ sender: Any) {
        print("pressedCopyButton")
        UIPasteboard.general.string = keystore
        let banner = NotificationBanner.generate(title: "Copy keystore to clipboard successfully!", style: .success)
        banner.duration = 1
        banner.show()
    }
    
}
