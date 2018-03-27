//
//  SetupViewController.swift
//  loopr-ios
//
//  Created by Matthew Cox on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
    
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var unlockWalletButton: UIButton!
    @IBOutlet weak var generateWalletButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: update the background color to #ECEEF0
        view.backgroundColor = UIColor.white // UIColor.init(rgba: "#ECEEF0")
        // self.navigationController?.navigationBar.barTintColor = UIColor.init(rgba: "#ECEEF0")

        taglineLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 16)

        unlockWalletButton.backgroundColor = UIColor.white
        unlockWalletButton.titleColor = UIColor.black
        unlockWalletButton.layer.cornerRadius = 23
        unlockWalletButton.layer.borderWidth = 1
        unlockWalletButton.layer.borderColor = UIColor.black.cgColor
        unlockWalletButton.title = NSLocalizedString("Import Wallet", comment: "")
        unlockWalletButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 17.0)
        
        generateWalletButton.backgroundColor = UIColor.black
        generateWalletButton.layer.cornerRadius = 23
        generateWalletButton.title = NSLocalizedString("Generate Wallet", comment: "")

        // TODO: what is the color for highlighted state
        generateWalletButton.setBackgroundColor(UIColor.init(white: 0.1, alpha: 1), for: .highlighted)
        generateWalletButton.clipsToBounds = true
        generateWalletButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 17.0)

        // TODO: skip button is not in the design. Add "Go to Market" button.
        /*
        let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(self.skipButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = skipButton
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unlockWalletButtonPressed(_ sender: Any) {
        let viewController = UnlockWalletSwipeViewController()
        // viewController.navigationController?.navigationBar.theme_barTintColor = GlobalPicker.barTintColor
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func generateWalletButtonPressed(_ sender: Any) {
        let viewController = GenerateWalletViewController()
        // viewController.navigationController?.navigationBar.theme_barTintColor = GlobalPicker.barTintColor
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func skipButtonPressed(_ sender: Any) {
        if SetupDataManager.shared.hasPresented {
            self.dismiss(animated: true, completion: {
                
            })
        } else {
            SetupDataManager.shared.hasPresented = true
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            // TODO: improve the animation between two view controllers.
            UIView.transition(with: appDelegate!.window!, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
            }, completion: nil)
        }
    }

}
