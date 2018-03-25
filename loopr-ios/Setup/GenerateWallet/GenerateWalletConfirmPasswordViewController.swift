//
//  GenerateWalletConfirmPasswordViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/25/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateWalletConfirmPasswordViewController: UIViewController, UITextFieldDelegate {

    var titleLabel: UILabel =  UILabel()
    
    var walletPasswordTextField: UITextField = UITextField()
    var walletPasswordUnderLine: UIView = UIView()
    
    var continueButton: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        titleLabel.text = "Confirm password"
        view.addSubview(titleLabel)
        
        walletPasswordTextField.delegate = self
        walletPasswordTextField.tag = 1
        // walletPasswordTextField.inputView = UIView()
        walletPasswordTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        walletPasswordTextField.placeholder = "Set a password"
        walletPasswordTextField.contentMode = UIViewContentMode.bottom
        walletPasswordTextField.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 90, width: screenWidth-padding*2, height: 40)
        view.addSubview(walletPasswordTextField)
        
        walletPasswordUnderLine.frame = CGRect(x: padding, y: walletPasswordTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        walletPasswordUnderLine.backgroundColor = UIColor.black
        view.addSubview(walletPasswordUnderLine)
        
        continueButton.setTitle("Enter Wallet", for: .normal)
        continueButton.setTitleColor(UIColor.white, for: .normal)
        continueButton.setBackgroundColor(UIColor.init(white: 0.6, alpha: 1), for: .highlighted)
        continueButton.frame = CGRect(x: padding, y: walletPasswordUnderLine.frame.maxY + 103, width: screenWidth - padding * 2, height: 47)
        continueButton.backgroundColor = UIColor.black
        continueButton.layer.cornerRadius = 23
        continueButton.clipsToBounds = true
        continueButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        continueButton.addTarget(self, action: #selector(self.pressedContinueButton(_:)), for: .touchUpInside)
        view.addSubview(continueButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedContinueButton(_ sender: Any) {
        print("pressedContinueButton")
        let viewController = GenerateMnemonicViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
