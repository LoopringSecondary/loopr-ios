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
        self.title = "Add Custom Token"
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        tokenNameTextField.becomeFirstResponder()
        tokenNameTitleLabel.textColor = systemDefaultBlueTintColor

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
        
        if (textField == tokenNameTextField) {
            tokenNameTitleLabel.textColor = systemDefaultBlueTintColor
            tokenSymbolTextField.textColor = systemDefaultBlueTintColor
            /*
            tokenNameTextField.layer.borderWidth = 0.5
            tokenNameTextField.layer.cornerRadius = 8.0
            tokenNameTextField.layer.masksToBounds = true
            tokenNameTextField.layer.borderColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1).cgColor
            */
            tokenContractAddressTitleLabel.textColor = UIColor.black
            tokenSymbolTitleLabel.textColor = UIColor.black
            decimalsTitleLabel.textColor = UIColor.black
            
        } else if (textField == tokenContractAddressTextField) {
            tokenNameTitleLabel.textColor = UIColor.black
            tokenContractAddressTitleLabel.textColor = systemDefaultBlueTintColor
            tokenSymbolTitleLabel.textColor = UIColor.black
            decimalsTitleLabel.textColor = UIColor.black
            
        } else if (textField == tokenSymbolTextField) {
            tokenNameTitleLabel.textColor = UIColor.black
            tokenContractAddressTitleLabel.textColor = UIColor.black
            tokenSymbolTitleLabel.textColor = systemDefaultBlueTintColor
            decimalsTitleLabel.textColor = UIColor.black
            
        } else if (textField == decimalsTextField) {
            tokenNameTitleLabel.textColor = UIColor.black
            tokenContractAddressTitleLabel.textColor = UIColor.black
            tokenSymbolTitleLabel.textColor = UIColor.black
            decimalsTitleLabel.textColor = systemDefaultBlueTintColor
        }
    }
}
