//
//  GenerateWalletViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateWalletViewController: UIViewController, UITextFieldDelegate {

    var titleLabel: UILabel =  UILabel()

    var walletNameTextField: UITextField = UITextField()
    var walletNameUnderLine: UIView = UIView()
    
    var walletPasswordTextField: UITextField = UITextField()
    var walletPasswordUnderLine: UIView = UIView()
    
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationItem.title = NSLocalizedString("Generate Wallet", comment: "")
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
        titleLabel.text = "Create a new wallet"
        view.addSubview(titleLabel)

        walletNameTextField.delegate = self
        walletNameTextField.tag = 0
        // walletNameTextField.inputView = UIView()
        walletNameTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        walletNameTextField.placeholder = "Give your wallet an awesome name"
        walletNameTextField.contentMode = UIViewContentMode.bottom
        walletNameTextField.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 80, width: screenWidth-padding*2, height: 40)
        view.addSubview(walletNameTextField)

        walletNameUnderLine.frame = CGRect(x: padding, y: walletNameTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        walletNameUnderLine.backgroundColor = UIColor.black
        view.addSubview(walletNameUnderLine)

        walletPasswordTextField.delegate = self
        walletPasswordTextField.tag = 1
        // walletPasswordTextField.inputView = UIView()
        walletPasswordTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        walletPasswordTextField.placeholder = "Set a password"
        walletPasswordTextField.contentMode = UIViewContentMode.bottom
        walletPasswordTextField.frame = CGRect(x: padding, y: walletNameUnderLine.frame.maxY + 45, width: screenWidth-padding*2, height: 40)
        view.addSubview(walletPasswordTextField)
        
        walletPasswordUnderLine.frame = CGRect(x: padding, y: walletPasswordTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        walletPasswordUnderLine.backgroundColor = UIColor.black
        view.addSubview(walletPasswordUnderLine)
        
        continueButton.frame = CGRect(x: padding, y: walletPasswordUnderLine.frame.maxY + 50, width: screenWidth - padding * 2, height: 47)
        continueButton.backgroundColor = UIColor.black
        continueButton.layer.cornerRadius = 23
        continueButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)

        view.theme_backgroundColor = GlobalPicker.backgroundColor

        _ = GenerateWalletDataManager.shared.new()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedContinueButton(_ sender: Any) {
        print("pressedContinueButton")
        
        // TODO: Check if walletNameTextField and walletPasswordTextField have valid input.
        
        GenerateWalletDataManager.shared.setWalletName(walletNameTextField.text!)
        
        let viewController = GenerateMnemonicViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
