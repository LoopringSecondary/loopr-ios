//
//  VerifyMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class VerifyMnemonicViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Verification", comment: "")
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        view.theme_backgroundColor = GlobalPicker.backgroundColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedCompleteButton(_ sender: Any) {
        print("pressedCompleteButton")
        
        // TODO: Since we haven't implemented the UI to enter mnemonic, this should always return false.
        if GenerateWalletDataManager.shared.verify() {
            
        } else {
            // Store the new wallet to the local storage.
            let appWallet = GenerateWalletDataManager.shared.complete()
            
            let alertController = UIAlertController(title: "Create \(appWallet.name) successfully",
                                                    message: "We are working on the features in the verification page.",
                                                    preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismissGenerateWallet()
            })
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func dismissGenerateWallet() {
        self.dismiss(animated: true) {
            
        }
    }

}
