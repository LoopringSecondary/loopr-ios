//
//  SetupViewController.swift
//  loopr-ios
//
//  Created by Matthew Cox on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SetupWalletViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var loopringLogoImageView: UIImageView!
    @IBOutlet weak var taglineLabel: UILabel!
    
    @IBOutlet weak var unlockWalletButton: UIButton!
    @IBOutlet weak var generateWalletButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.theme_backgroundColor = GlobalPicker.backgroundColor

        let stringValue = "UP Wallet"
        let attrString = NSMutableAttributedString(string: stringValue)
        attrString.addAttribute(NSAttributedStringKey.kern, value: 2.4, range: NSMakeRange(0, attrString.length))
        taglineLabel.attributedText = attrString

        taglineLabel.font = UIFont(name: FontConfigManager.shared.getMedium(), size: 16.0)

        unlockWalletButton.title = LocalizedString("Import Wallet", comment: "")
        unlockWalletButton.setupSecondary(height: 50, gradientOrientation: .horizontal)
        
        // This conflicts to UIImage.
        // unlockWalletButton.set(image: UIImage.init(named: "ImportWalletButtonIcon"), title: LocalizedString("Import Wallet", comment: ""), titlePosition: .right, additionalSpacing: 10, state: .normal)

        unlockWalletButton.addTarget(self, action: #selector(unlockWalletButtonPressed), for: .touchUpInside)

        generateWalletButton.title = LocalizedString("Generate Wallet", comment: "")
        generateWalletButton.setupSecondary(height: 50, gradientOrientation: .horizontal)
        generateWalletButton.addTarget(self, action: #selector(generateWalletButtonPressed), for: .touchUpInside)

        backgroundImageView.image = UIImage(named: "Background")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
