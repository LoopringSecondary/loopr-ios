//
//  AddAssetViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AddAssetViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tokenNameTitleLabel: UILabel!
    @IBOutlet weak var tokenNameTextField: UITextField!
    
    @IBOutlet weak var tokenContractAddressTitleLabel: UILabel!
    @IBOutlet weak var tokenContractAddressTextField: UITextField!
    
    @IBOutlet weak var tokenSymbolTitleLabel: UILabel!
    @IBOutlet weak var tokenSymbolTextField: UITextField!
    
    @IBOutlet weak var decimalsTitleLabel: UILabel!
    @IBOutlet weak var decimalsTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        self.navigationItem.title = "Add Custom Token"
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        tokenNameTextField.becomeFirstResponder()
        tokenNameTitleLabel.textColor = systemDefaultBlueTintColor
        tokenNameTextField.setActive()

        tokenNameTextField.delegate = self
        tokenContractAddressTextField.delegate = self
        tokenSymbolTextField.delegate = self
        decimalsTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        
        if textField == tokenNameTextField {
            tokenNameTitleLabel.textColor = systemDefaultBlueTintColor
            tokenNameTextField.setActive()
            
            tokenContractAddressTitleLabel.textColor = UIColor.black
            tokenContractAddressTextField.setDefault()
            
            tokenSymbolTitleLabel.textColor = UIColor.black
            tokenSymbolTextField.setDefault()
            
            decimalsTitleLabel.textColor = UIColor.black
            decimalsTextField.setDefault()
            
        } else if textField == tokenContractAddressTextField {
            tokenNameTitleLabel.textColor = UIColor.black
            tokenNameTextField.setDefault()
            
            tokenContractAddressTitleLabel.textColor = systemDefaultBlueTintColor
            tokenContractAddressTextField.setActive()
            
            tokenSymbolTitleLabel.textColor = UIColor.black
            tokenSymbolTextField.setDefault()
            
            decimalsTitleLabel.textColor = UIColor.black
            decimalsTextField.setDefault()
            
        } else if textField == tokenSymbolTextField {
            tokenNameTitleLabel.textColor = UIColor.black
            tokenNameTextField.setDefault()
            
            tokenContractAddressTitleLabel.textColor = UIColor.black
            tokenContractAddressTextField.setDefault()
            
            tokenSymbolTitleLabel.textColor = systemDefaultBlueTintColor
            tokenSymbolTextField.setActive()
            
            decimalsTitleLabel.textColor = UIColor.black
            decimalsTextField.setDefault()
            
        } else if textField == decimalsTextField {
            tokenNameTitleLabel.textColor = UIColor.black
            tokenNameTextField.setDefault()
            
            tokenContractAddressTitleLabel.textColor = UIColor.black
            tokenContractAddressTextField.setDefault()
            
            tokenSymbolTitleLabel.textColor = UIColor.black
            tokenSymbolTextField.setDefault()
            
            decimalsTitleLabel.textColor = systemDefaultBlueTintColor
            decimalsTextField.setActive()
        }
    }
}
