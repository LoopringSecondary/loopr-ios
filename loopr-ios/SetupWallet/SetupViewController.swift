//
//  SetupViewController.swift
//  loopr-ios
//
//  Created by Matthew Cox on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
    
    @IBOutlet weak var loopringLogoImageView: UIImageView!
    @IBOutlet weak var taglineLabel: UILabel!
    var unlockWalletButton = UIButton()
    var generateWalletButton = UIButton()
    
    var isCreatingFirstWallet: Bool = true
    var button = UIButton()
    
    var backgrondImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        taglineLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 15)

        button.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        button.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)

        unlockWalletButton.title = NSLocalizedString("Import Wallet", comment: "")
        unlockWalletButton.setupRoundWhite()
        unlockWalletButton.addTarget(self, action: #selector(unlockWalletButtonPressed), for: .touchUpInside)

        generateWalletButton.title = NSLocalizedString("Generate Wallet", comment: "")
        generateWalletButton.setupRoundBlack()
        generateWalletButton.addTarget(self, action: #selector(generateWalletButtonPressed), for: .touchUpInside)
        
        let screenSize: CGRect = UIScreen.main.bounds
        backgrondImageView.frame = screenSize
        backgrondImageView.image = UIImage(named: "Background")
        backgrondImageView.isUserInteractionEnabled = true
        
        view.addSubview(backgrondImageView)
        backgrondImageView.addSubview(loopringLogoImageView)
        backgrondImageView.addSubview(taglineLabel)
        backgrondImageView.addSubview(button)
        backgrondImageView.addSubview(unlockWalletButton)
        backgrondImageView.addSubview(generateWalletButton)
        
        self.navigationController?.isNavigationBarHidden = true

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true

        // TODO: May need to use auto layout.
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        loopringLogoImageView.frame = CGRect(x: 24, y: 64, width: 136, height: 41)
        taglineLabel.frame = CGRect(x: 24, y: 119, width: screenWidth - 24 * 2, height: 20)
        
        if isCreatingFirstWallet {
            
        } else {
            button.title = "Go Back"
            button.frame = CGRect(x: 80, y: screenHeight - 47 - 10, width: screenWidth - 80 * 2, height: 47)
            button.setRightImage(imageName: "Arrow-down-black-bold", imagePaddingTop: 3, imagePaddingLeft: 5, titlePaddingRight: 10)
        }

        unlockWalletButton.frame = CGRect(x: 15, y: screenHeight - 47 - 63, width: screenWidth - 15 * 2, height: 47)
        generateWalletButton.frame = CGRect(x: 15, y: screenHeight - 47 - 125, width: screenWidth - 15 * 2, height: 47)
    }
    
    @objc func pressedButton(_ sender: Any) {
        if isCreatingFirstWallet {
            
        } else {
            self.dismiss(animated: true, completion: {
                
            })
        }
    }
    
    @objc func unlockWalletButtonPressed(_ sender: Any) {
        print("unlockWalletButtonPressed")
        // backgrondImageView.removeFromSuperview()
        let viewController = UnlockWalletSwipeViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func generateWalletButtonPressed(_ sender: Any) {
        print("generateWalletButtonPressed")
        // backgrondImageView.removeFromSuperview()
        let viewController = GenerateWalletViewController(setupWalletMethod: .create)
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
