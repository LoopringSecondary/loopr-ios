//
//  SetupWalletViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 9/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SetupWalletViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!

    @IBOutlet weak var generateWalletButton: UIButton!
    @IBOutlet weak var unlockWalletButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backgroundImageView.theme_backgroundColor = ColorPicker.backgroundColor
        // backgroundImageView.image = UIImage(named: "Background" + ColorTheme.getTheme())
        
        // This part of elements are not easy to match the value in the design.
        let iconTitlePadding: CGFloat = 30

        unlockWalletButton.addTarget(self, action: #selector(unlockWalletButtonPressed), for: .touchUpInside)
        unlockWalletButton.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 14)
        unlockWalletButton.set(image: UIImage(named: "SetupWallet-generate"), title: LocalizedString("Import Wallet", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        unlockWalletButton.set(image: UIImage(named: "SetupWallet-generate")?.alpha(0.6), title: LocalizedString("Import Wallet", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        unlockWalletButton.theme_setTitleColor(GlobalPicker.textLightColor, forState: .normal)
        
        generateWalletButton.addTarget(self, action: #selector(generateWalletButtonPressed), for: .touchUpInside)
        generateWalletButton.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 14)
        generateWalletButton.set(image: UIImage(named: "SetupWallet-import"), title: LocalizedString("Generate Wallet", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        generateWalletButton.set(image: UIImage(named: "SetupWallet-import")?.alpha(0.6), title: LocalizedString("Generate Wallet", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        generateWalletButton.theme_setTitleColor(GlobalPicker.textLightColor, forState: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func unlockWalletButtonPressed(_ sender: Any) {
        print("unlockWalletButtonPressed")
        let viewController = UnlockWalletSwipeViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func generateWalletButtonPressed(_ sender: Any) {
        print("generateWalletButtonPressed")
        let viewController = GenerateWalletEnterNameViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
