//
//  ExportKeystoreEnterPasswordViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class ExportKeystoreEnterPasswordViewController: UIViewController, UITextFieldDelegate {

    var titleLabel: UILabel =  UILabel()

    var passwordTextField: UITextField = UITextField()
    var passwordUnderLine: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Verification", comment: "")
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        titleLabel.frame = CGRect(x: padding, y: originY, width: screenWidth - padding * 2, height: 30)
        titleLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 27)
        titleLabel.text = NSLocalizedString("Enter password", comment: "")
        view.addSubview(titleLabel)
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        passwordTextField.tag = 1
        passwordTextField.theme_tintColor = GlobalPicker.textColor
        passwordTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        passwordTextField.placeholder = ""
        passwordTextField.contentMode = UIViewContentMode.bottom
        passwordTextField.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 30, width: screenWidth-padding*2, height: 40)
        view.addSubview(passwordTextField)
        
        passwordUnderLine.frame = CGRect(x: padding, y: passwordTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        passwordUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.addSubview(passwordUnderLine)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
