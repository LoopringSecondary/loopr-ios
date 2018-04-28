//
//  BackupMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class BackupMnemonicViewController: UIViewController {

    var isExportMode: Bool = false
    var mnemonics: [String] = []

    var titleLabel: UILabel =  UILabel()
    var infoTextView: UITextView = UITextView()

    @IBOutlet weak var verifyNowButton: UIButton!
    
    var currentMnemonicCollectionView = 0
    var mnemonicCollectionViewController0: MnemonicCollectionViewController!
    var mnemonicCollectionViewController1: MnemonicCollectionViewController!

    var switchMnemonicCollectionViewButton0 = UIButton()
    var switchMnemonicCollectionViewButton1 = UIButton()

    var blurVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationItem.title = NSLocalizedString("Backup Mnemonic", comment: "")
        setBackButton()
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        titleLabel.frame = CGRect(x: padding, y: originY, width: screenWidth - padding * 2, height: 30)
        titleLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 27)
        titleLabel.text = NSLocalizedString("Please write them down", comment: "")
        view.addSubview(titleLabel)
        
        infoTextView.frame = CGRect(x: padding-3, y: 72, width: screenWidth - (padding-3) * 2, height: 96)
        infoTextView.isEditable = false
        infoTextView.textColor = UIColor.black.withAlphaComponent(0.6)
        infoTextView.font = FontConfigManager.shared.getLabelFont(size: 17)
        view.addSubview(infoTextView)

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (screenWidth - padding * 2 - 30)/3, height: 30)
        flowLayout.scrollDirection = .vertical
        
        mnemonicCollectionViewController0 = MnemonicCollectionViewController(collectionViewLayout: flowLayout)
        mnemonicCollectionViewController0.view.isHidden = false
        mnemonicCollectionViewController0.index = 0
        mnemonicCollectionViewController0.view.frame = CGRect(x: 15, y: infoTextView.frame.maxY + 35, width: screenWidth - padding * 2, height: 220)
        view.addSubview(mnemonicCollectionViewController0.view)

        mnemonicCollectionViewController1 = MnemonicCollectionViewController(collectionViewLayout: flowLayout)
        mnemonicCollectionViewController1.view.isHidden = true
        mnemonicCollectionViewController1.index = 1
        mnemonicCollectionViewController1.view.frame = CGRect(x: 15 + screenWidth, y: infoTextView.frame.maxY + 35, width: screenWidth - padding * 2, height: 220)
        view.addSubview(mnemonicCollectionViewController1.view)

        switchMnemonicCollectionViewButton0.isHidden = false
        switchMnemonicCollectionViewButton0.frame = CGRect(x: 100, y: mnemonicCollectionViewController0.view.frame.maxY + 25, width: screenWidth - 2*100, height: 20)
        switchMnemonicCollectionViewButton0.setTitle("Next 12 Words" + "  ", for: .normal)
        switchMnemonicCollectionViewButton0.theme_setTitleColor(["#000", "#fff"], forState: .normal)
        switchMnemonicCollectionViewButton0.setTitleColor(UIColor.init(white: 0, alpha: 0.3), for: .highlighted)
        switchMnemonicCollectionViewButton0.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        switchMnemonicCollectionViewButton0.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        switchMnemonicCollectionViewButton0.setImage(UIImage.init(named: "Arrow-button-right"), for: .normal)
        switchMnemonicCollectionViewButton0.setImage(UIImage.init(named: "Arrow-button-right")?.alpha(0.3), for: .highlighted)
        switchMnemonicCollectionViewButton0.semanticContentAttribute = .forceRightToLeft
        view.addSubview(switchMnemonicCollectionViewButton0)

        switchMnemonicCollectionViewButton1.isHidden = true
        switchMnemonicCollectionViewButton1.frame = CGRect(x: 100 + screenWidth, y: mnemonicCollectionViewController0.view.frame.maxY + 25, width: screenWidth - 2*100, height: 20)
        switchMnemonicCollectionViewButton1.setTitle("  " + "Previous 12 Words", for: .normal)
        switchMnemonicCollectionViewButton1.setTitleColor(UIColor.black, for: .normal)
        switchMnemonicCollectionViewButton1.setTitleColor(UIColor.init(white: 0, alpha: 0.3), for: .highlighted)
        switchMnemonicCollectionViewButton1.addTarget(self, action: #selector(pressedButton), for: .touchUpInside)
        switchMnemonicCollectionViewButton1.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        switchMnemonicCollectionViewButton1.setImage(UIImage.init(named: "Arrow-button-left"), for: .normal)
        switchMnemonicCollectionViewButton1.setImage(UIImage.init(named: "Arrow-button-left")?.alpha(0.3), for: .highlighted)
        switchMnemonicCollectionViewButton1.semanticContentAttribute = .forceLeftToRight
        view.addSubview(switchMnemonicCollectionViewButton1)
        
        verifyNowButton.title = NSLocalizedString("Verify Now", comment: "Go to VerifyMnemonicViewController")
        verifyNowButton.setupRoundBlack()

        blurVisualEffectView.alpha = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let halfLength: Int = mnemonics.count / 2
        mnemonicCollectionViewController0.mnemonics = Array(mnemonics[0..<halfLength])
        mnemonicCollectionViewController1.mnemonics = Array(mnemonics[halfLength..<mnemonics.count])
        if isExportMode {
            verifyNowButton.isHidden = true
            infoTextView.text = "Loopring wallet never keeps your mnemonic words, It is strongly recommended that you back up these information offline (with USB or physical paper)."
        } else {
            infoTextView.text = NSLocalizedString("Please make sure you have recorded all words safely. Otherwise, you will not be able to go through the verification process, and have to start over.", comment: "")
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @IBAction func pressedVerifyNowButton(_ sender: Any) {
        print("pressedVerifyNowButton")
        
        // TODO: need to improve the blur effect
        let screenSize: CGRect = UIScreen.main.bounds
        blurVisualEffectView.frame = screenSize

        self.blurVisualEffectView.alpha = 1.0
        
        let attributedString = NSAttributedString(string: NSLocalizedString("Please make sure you have backed up mnemonic words.", comment: ""), attributes: [
            NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getMedium(), size: 17) ?? UIFont.systemFont(ofSize: 17),
            NSAttributedStringKey.foregroundColor: UIColor.init(rgba: "#030303")
        ])

        let alertController = UIAlertController(title: nil,
            message: nil,
            preferredStyle: .alert)

        alertController.setValue(attributedString, forKey: "attributedMessage")

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.blurVisualEffectView.alpha = 0.0
            }, completion: {(_) in
                self.blurVisualEffectView.removeFromSuperview()
            })
            
        })
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
            // Avoid a delay in the animation
            let viewController = VerifyMnemonicViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.blurVisualEffectView.alpha = 0.0
            }, completion: {(_) in
                self.blurVisualEffectView.removeFromSuperview()
                
            })
            
        })
        alertController.addAction(confirmAction)
        
        let backView = alertController.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 10.0
        backView?.backgroundColor = UIColor.white
        
        // Add a blur view to the whole screen
        self.navigationController?.view.addSubview(blurVisualEffectView)
        
        // Show the UIAlertController
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func pressedButton() {
        print("pressedButton")
        
        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = mnemonicCollectionViewController0.view.frame.minY
        let padding: CGFloat = 15

        if currentMnemonicCollectionView == 0 {
            currentMnemonicCollectionView = 1
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 30, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
                self.mnemonicCollectionViewController0.view.isHidden = true
                self.mnemonicCollectionViewController0.view.frame = CGRect(x: 15 - screenWidth, y: originY, width: screenWidth - padding * 2, height: 220)
                
                self.mnemonicCollectionViewController1.view.isHidden = false
                self.mnemonicCollectionViewController1.view.frame = CGRect(x: 15, y: originY, width: screenWidth - padding * 2, height: 220)
                
                self.switchMnemonicCollectionViewButton0.isHidden = true
                self.switchMnemonicCollectionViewButton0.frame = CGRect(x: 100 - screenWidth, y: self.mnemonicCollectionViewController0.view.frame.maxY + 25, width: screenWidth - 2*100, height: 20)
                
                self.switchMnemonicCollectionViewButton1.isHidden = false
                self.switchMnemonicCollectionViewButton1.frame = CGRect(x: 100, y: self.mnemonicCollectionViewController0.view.frame.maxY + 25, width: screenWidth - 2*100, height: 20)
            }, completion: { (_) in
                
            })
        } else {
            currentMnemonicCollectionView = 0

            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 30, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
                self.mnemonicCollectionViewController0.view.isHidden = false
                self.mnemonicCollectionViewController0.view.frame = CGRect(x: 15, y: originY, width: screenWidth - padding * 2, height: 220)
                
                self.mnemonicCollectionViewController1.view.isHidden = true
                self.mnemonicCollectionViewController1.view.frame = CGRect(x: 15 + screenWidth, y: originY, width: screenWidth - padding * 2, height: 220)

                self.switchMnemonicCollectionViewButton0.isHidden = false
                self.switchMnemonicCollectionViewButton0.frame = CGRect(x: 100, y: self.mnemonicCollectionViewController0.view.frame.maxY + 25, width: screenWidth - 2*100, height: 20)
                
                self.switchMnemonicCollectionViewButton1.isHidden = true
                self.switchMnemonicCollectionViewButton1.frame = CGRect(x: 100 + screenWidth, y: self.mnemonicCollectionViewController0.view.frame.maxY + 25, width: screenWidth - 2*100, height: 20)
            }, completion: { (_) in
                
            })
        }
    }

}
