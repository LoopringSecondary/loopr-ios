//
//  ExportMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class ExportMnemonicViewController: UIViewController {

    var appWallet: AppWallet!
    
    var infoTextView: UITextView = UITextView()
    var mnemonicCollectionViewController0: MnemonicCollectionViewController!

    var collectionViewY: CGFloat = 200
    var collectionViewWidth: CGFloat = 200
    var collectionViewHeight: CGFloat = 220

    private let originY: CGFloat = 30
    private let padding: CGFloat = 15
    private let buttonPaddingY: CGFloat = 40

    var verifyNowButton: UIButton = UIButton()
    
    private var firstAppear = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = LocalizedString("Backup Mnemonic", comment: "")
        setBackButton()
        
        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        infoTextView.text = LocalizedString("Loopr doesn't keep a copy of your mnemonic words. Make sure you back up these information immediately.", comment: "")
        infoTextView.frame = CGRect(x: padding-3, y: 15, width: screenWidth - (padding-3) * 2, height: 110)
        infoTextView.isEditable = false
        infoTextView.textColor = UIColor.black  // UIColor.black.withAlphaComponent(0.6)
        infoTextView.font = FontConfigManager.shared.getLabelFont()
        view.addSubview(infoTextView)
        
        collectionViewWidth = screenWidth - padding * 2
        collectionViewHeight = 4*MnemonicCollectionViewCell.getHeight() + 2*padding
        collectionViewY = infoTextView.frame.maxY + padding

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (collectionViewWidth - 30)/3, height: MnemonicCollectionViewCell.getHeight())
        flowLayout.scrollDirection = .vertical
        
        mnemonicCollectionViewController0 = MnemonicCollectionViewController(collectionViewLayout: flowLayout)
        // assign first 12 words
        mnemonicCollectionViewController0.mnemonics = appWallet.mnemonics
        mnemonicCollectionViewController0.view.isHidden = false
        mnemonicCollectionViewController0.view.frame = CGRect(x: 15, y: collectionViewY, width: collectionViewWidth, height: collectionViewHeight)
        view.addSubview(mnemonicCollectionViewController0.view)
        addChildViewController(mnemonicCollectionViewController0)
        
        // TODO: Need to consider 24 mnemonic words.
        if !appWallet.isVerified {
            verifyNowButton.title = LocalizedString("Verify Now", comment: "Go to VerifyMnemonicViewController")
            verifyNowButton.setupSecondary()
            view.addSubview(verifyNowButton)
            verifyNowButton.addTarget(self, action: #selector(pressedVerifyNowButton), for: .touchUpInside)

            verifyNowButton.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: verifyNowButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 15))
            view.addConstraint(NSLayoutConstraint(item: verifyNowButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -15))
            view.addConstraint(NSLayoutConstraint(item: verifyNowButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 47))
            view.addConstraint(NSLayoutConstraint(item: verifyNowButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -15))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstAppear {
            collectionViewHeight = self.view.bounds.height - collectionViewY - padding*2 - 47
            self.mnemonicCollectionViewController0.view.frame = CGRect(x: 15, y: collectionViewY, width: self.collectionViewWidth, height: self.collectionViewHeight)
            mnemonicCollectionViewController0.collectionView?.collectionViewLayout.invalidateLayout()
            firstAppear = false
        }
        
        if AppWalletDataManager.shared.isWalletVerified(address: appWallet.address) {
            verifyNowButton.isHidden = true
        } else {
            verifyNowButton.isHidden = false
        }
    }
    
    @objc func pressedVerifyNowButton(_ sender: Any) {
        let viewController = SettingWalletVerifyMnemonicViewController()
        viewController.appWallet = appWallet
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
