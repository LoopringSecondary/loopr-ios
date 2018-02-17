//
//  PrivateKeyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class PrivateKeyViewController: UIViewController {

    @IBOutlet weak var privateKeyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        privateKeyTextView.becomeFirstResponder()
    }

}
