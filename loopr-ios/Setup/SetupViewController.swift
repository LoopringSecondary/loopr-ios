//
//  SetupViewController.swift
//  loopr-ios
//
//  Created by Matthew Cox on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {

    @IBOutlet weak var unlockWalletButton: UIButton!
    @IBOutlet weak var generateWalletButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unlockWalletButton.layer.cornerRadius = 10
        unlockWalletButton.title = NSLocalizedString("Unlock Wallet", comment: "")
        
        generateWalletButton.layer.cornerRadius = 10
        generateWalletButton.title = NSLocalizedString("Generate Wallet", comment: "")

        let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(self.skipButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = skipButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unlockWalletButtonPressed(_ sender: Any) {
        let viewController = UnlockWalletSwipeViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func generateWalletButtonPressed(_ sender: Any) {
        let generateWalletViewController = GenerateWalletViewController()
        self.navigationController?.pushViewController(generateWalletViewController, animated: true)
    }
    
    @objc func skipButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }

}
