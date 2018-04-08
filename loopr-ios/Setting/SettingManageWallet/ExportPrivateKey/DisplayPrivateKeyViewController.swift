//
//  DisplayPrivateKeyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class DisplayPrivateKeyViewController: UIViewController {

    @IBOutlet weak var privateKeyTextView: UITextView!
    @IBOutlet weak var copyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Export Private Key", comment: "")
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        privateKeyTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        privateKeyTextView.contentOffset = CGPoint(x: 0, y: -10)

        privateKeyTextView.cornerRadius = 12
        privateKeyTextView.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17.0)
        privateKeyTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        privateKeyTextView.textColor = .lightGray
        privateKeyTextView.tintColor = UIColor.black
        privateKeyTextView.isEditable = false
        privateKeyTextView.isScrollEnabled = false
        
        copyButton.title = "Copy Private Key"
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
