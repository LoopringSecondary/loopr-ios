//
//  SettingChangeWalletNameViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingChangeWalletNameViewController: UIViewController, UITextFieldDelegate {

    var appWallet: AppWallet!
    var nameTextField: UITextField = UITextField()
    var nameFieldUnderLine: UIView = UIView()
    var saveButton: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Change Wallet Name", comment: "")
        setBackButton()
        
        nameTextField.delegate = self
        nameTextField.tag = 0
        nameTextField.inputView = UIView()
        nameTextField.font = FontConfigManager.shared.getLabelFont()
        nameTextField.theme_tintColor = GlobalPicker.textColor
        nameTextField.placeholder = "Enter your wallet name"
        nameTextField.contentMode = UIViewContentMode.bottom
        nameTextField.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2-80, height: 40)
        self.view.addSubview(nameTextField)
        
        nameFieldUnderLine.frame = CGRect(x: padding, y: nameTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        nameFieldUnderLine.backgroundColor = UIColor.black
        self.view.addSubview(nameFieldUnderLine)
        
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .highlighted)
        saveButton.setBackgroundColor(UIColor.black, for: .normal)
        saveButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        saveButton.frame = CGRect(x: screenWidth/2-40, y: nameFieldUnderLine.frame.maxY + padding*2, width: 80, height: 40)
        saveButton.addTarget(self, action: #selector(pressedSaveButton), for: .touchUpInside)
        self.view.addSubview(saveButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveButton.setTitle("Save", for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func pressedSaveButton(_ sender: Any) {
        print("pressedSwitchTokenBButton")
    }
}
