//
//  SendAssetViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SendAssetViewController: UIViewController, UITextFieldDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonBackgroundView: UIView!
    @IBOutlet weak var sendButton: UIButton!

    // Keyboard
    var isKeyboardShow: Bool = false
    var keyboardView: DefaultNumericKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        sendButton.backgroundColor = UIColor.black
        sendButton.layer.cornerRadius = 23
        sendButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        
        scrollViewButtonLayoutConstraint.constant = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedSendButton(_ sender: Any) {
        print("pressedSendButton")

    }
    
    func getActiveTextField() -> UITextField? {
        return nil
    }
    
    func showKeyboard(textField: UITextField) {
        
    }
    
    func hideKeyboard() {
        
    }

}
