//
//  DisplayKeystoreViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class DisplayKeystoreViewController: UIViewController {
    
    var appWallet: AppWallet!
    
    @IBOutlet weak var keystoreTextView: UITextView!
    @IBOutlet weak var copyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        keystoreTextView.text = appWallet.getKeystore().description
        
        keystoreTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        // privateKeyTextView.contentOffset = CGPoint(x: 0, y: -10)
        
        keystoreTextView.cornerRadius = 12
        keystoreTextView.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 12.0)
        keystoreTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        keystoreTextView.textColor = UIColor.black
        keystoreTextView.isEditable = false
        
        copyButton.title = "Copy Keystore"
        copyButton.setupRoundBlack()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedCopyButton(_ sender: Any) {
        print("pressedCopyButton")
    }
    
}
