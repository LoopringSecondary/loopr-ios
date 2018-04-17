//
//  GenerateMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateMnemonicViewController: UIViewController {

    var congratulationIconView = UIImageView()
    var congratulationsLabel: UILabel = UILabel()
    var infoTextView: UITextView = UITextView()
    @IBOutlet weak var backupNowButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()

        backupNowButton.setupRoundBlack()

        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        congratulationIconView.frame = CGRect(x: 15, y: originY+1, width: 22, height: 22)
        congratulationIconView.image = UIImage(named: "CongratulationIcon")
        view.addSubview(congratulationIconView)

        congratulationsLabel.frame = CGRect(x: 45, y: originY, width: screenWidth - padding * 2, height: 30)
        congratulationsLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 27)
        congratulationsLabel.text = "Congratualations!"
        view.addSubview(congratulationsLabel)

        infoTextView.frame = CGRect(x: padding-3, y: 72, width: screenWidth - (padding-3) * 2, height: 150)
        infoTextView.isEditable = false
        infoTextView.text = "Your wallet has been generated. Please take a moment to backup your wallet by writing down the mnemonic words on paper. Mnemonic words are required to resotre your wallets. Please do not share your mnemonic words with anyone, nor save them on cloud storage."
        infoTextView.textColor = UIColor.black.withAlphaComponent(0.6)
        infoTextView.font = FontConfigManager.shared.getLabelFont()
        view.addSubview(infoTextView)

        view.theme_backgroundColor = GlobalPicker.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedBackupNowButton(_ sender: Any) {
        print("pressedBackupNowButton")
        let viewController = BackupMnemonicViewController()
        viewController.mnemonics = GenerateWalletDataManager.shared.getMnemonics()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
