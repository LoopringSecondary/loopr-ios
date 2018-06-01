//
//  BackupMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class BackupMnemonicViewController_Archive: UIViewController {

    var isExportMode: Bool = false
    var mnemonics: [String] = []

    var titleLabel: UILabel =  UILabel()
    var infoTextView: UITextView = UITextView()

    @IBOutlet weak var verifyNowButton: UIButton!
    
    var mnemonicCollectionViewController0: MnemonicCollectionViewController!

    var collectionViewY: CGFloat = 200
    var collectionViewWidth: CGFloat = 200
    var collectionViewHeight: CGFloat = 220
    
    private let originY: CGFloat = 30
    private let padding: CGFloat = 15
    private let buttonPaddingY: CGFloat = 40
    
    private var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationItem.title = NSLocalizedString("Backup Mnemonic", comment: "")
        setBackButton()
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        titleLabel.frame = CGRect(x: padding, y: originY, width: screenWidth - padding * 2, height: 30)
        titleLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 27)
        titleLabel.text = NSLocalizedString("Please write them down", comment: "")
        view.addSubview(titleLabel)
        
        infoTextView.frame = CGRect(x: padding-3, y: 72, width: screenWidth - (padding-3) * 2, height: 96)
        infoTextView.isEditable = false
        infoTextView.textColor = UIColor.black.withAlphaComponent(0.6)
        infoTextView.font = FontConfigManager.shared.getLabelFont(size: 17)
        view.addSubview(infoTextView)

        collectionViewWidth = screenWidth - padding * 2
        collectionViewHeight = 4*MnemonicCollectionViewCell.getHeight() + 2*padding
        collectionViewY = infoTextView.frame.maxY + 40
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (collectionViewWidth - 30)/3, height: MnemonicCollectionViewCell.getHeight())
        flowLayout.scrollDirection = .vertical
        
        mnemonicCollectionViewController0 = MnemonicCollectionViewController(collectionViewLayout: flowLayout)
        // assign first 12 words
        mnemonicCollectionViewController0.mnemonics = mnemonics
        mnemonicCollectionViewController0.view.isHidden = false
        mnemonicCollectionViewController0.view.frame = CGRect(x: 15, y: collectionViewY, width: collectionViewWidth, height: collectionViewHeight)
        view.addSubview(mnemonicCollectionViewController0.view)
        addChildViewController(mnemonicCollectionViewController0)

        verifyNowButton.title = NSLocalizedString("Verify Now", comment: "Go to VerifyMnemonicViewController")
        verifyNowButton.setupRoundBlack()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isExportMode {
            verifyNowButton.isHidden = true
            infoTextView.text = "Loopring wallet never keeps your mnemonic words. It's strongly recommended that you backup these information offline (with USB or physical paper)."
        } else {
            infoTextView.text = NSLocalizedString("Please make sure you have recorded all words safely. Otherwise, you will not be able to go through the verification process, and have to start over.", comment: "")
        }
        
        // CollectionView won't be layout correctly in viewDidLoad()
        // https://stackoverflow.com/questions/12927027/uicollectionview-flowlayout-not-wrapping-cells-correctly-ios
        // If you want to improve this part, please submit a PR to review
        if firstAppear {
            self.mnemonicCollectionViewController0.view.frame = CGRect(x: 15, y: collectionViewY, width: self.collectionViewWidth, height: self.collectionViewHeight)
            mnemonicCollectionViewController0.collectionView?.collectionViewLayout.invalidateLayout()
            
            firstAppear = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @IBAction func pressedVerifyNowButton(_ sender: Any) {
        print("pressedVerifyNowButton")
        let viewController = VerifyMnemonicViewController()
        viewController.mnemonics = GenerateWalletDataManager.shared.getMnemonics()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
