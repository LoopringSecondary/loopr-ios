//
//  GenerateWalletViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateWalletViewController: UIViewController {

    @IBOutlet weak var walletNameTextField: UITextField!
    @IBOutlet weak var walletPasswordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Generate Wallet", comment: "")
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
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
