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
        
        keystoreTextView.text = keystore
        
        keystoreTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        // privateKeyTextView.contentOffset = CGPoint(x: 0, y: -10)
        
        keystoreTextView.cornerRadius = 12
        keystoreTextView.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 12.0)
        keystoreTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        keystoreTextView.textColor = UIColor.black
        keystoreTextView.isEditable = false
        
        copyButton.title = LocalizedString("Copy Keystore", comment: "")
        copyButton.setupRoundBlack()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedCopyButton(_ sender: Any) {
        print("pressedCopyButton")
        UIPasteboard.general.string = keystore
        let banner = NotificationBanner.generate(title: "Copy keystore to clipboard successfully!", style: .success)
        banner.duration = 1
        banner.show()
    }
    
}
