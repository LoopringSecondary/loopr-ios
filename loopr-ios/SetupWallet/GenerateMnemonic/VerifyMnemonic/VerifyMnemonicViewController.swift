//
//  VerifyMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Crashlytics

class VerifyMnemonicViewController: UIViewController, MnemonicBackupModeCollectionViewControllerDelegate {

    var sortedMnemonics: [String] = []

    var infoLabel: UILabel = UILabel()
    var mnemonicsTextView: UITextView = UITextView()

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!

    var mnemonicCollectionViewController: MnemonicBackupModeCollectionViewController!
    
    var collectionViewY: CGFloat = 200
    var collectionViewWidth: CGFloat = 200
    var collectionViewHeight: CGFloat = 220
    
    private let originY: CGFloat = 30
    private let padding: CGFloat = 18
    private let buttonPaddingY: CGFloat = 40
    
    private var firstAppear = true
    
    var blurVisualEffectView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // mnemonics.shuffle()
        sortedMnemonics = GenerateWalletDataManager.shared.getMnemonics()
        sortedMnemonics.sort { (a, b) -> Bool in
            return a < b
        }

        setBackButton()
        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Verify Mnemonic", comment: "")
                
        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        collectionViewWidth = screenWidth - padding * 2
        collectionViewHeight = CGFloat(sortedMnemonics.count/3) * MnemonicBackupModeCollectionViewCell.getHeight() + 2*padding
        // padding = (screenHeight - 120 - collectionViewHeight - 140 - 40) / 3
        
        infoLabel.frame = CGRect(x: 15, y: 30, width: screenWidth - 2*15, height: 19)
        infoLabel.textAlignment = .center
        infoLabel.textColor = Themes.isDark() ? UIColor.white.withAlphaComponent(0.6) : UIColor.dark1
        infoLabel.font = FontConfigManager.shared.getDigitalFont(size: 16)
        infoLabel.text = LocalizedString("Confirm Mnemonic Word", comment: "")
        view.addSubview(infoLabel)
        
        mnemonicsTextView.frame = CGRect(x: 18, y: 70, width: screenWidth - 2*18, height: 140)
        mnemonicsTextView.font = FontConfigManager.shared.getDigitalFont()
        mnemonicsTextView.backgroundColor = UIColor.dark3
        mnemonicsTextView.textColor = UIColor.white.withAlphaComponent(0.8)
        mnemonicsTextView.tintColor = UIColor.white.withAlphaComponent(0.8)
        mnemonicsTextView.textContainerInset = UIEdgeInsets.init(top: 20, left: 20, bottom: 10, right: 20)
        mnemonicsTextView.cornerRadius = 6
        mnemonicsTextView.isEditable = false
        view.addSubview(mnemonicsTextView)

        collectionViewY = mnemonicsTextView.frame.maxY + 20
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (collectionViewWidth - 8)/3, height: MnemonicBackupModeCollectionViewCell.getHeight())
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.minimumLineSpacing = 4
        flowLayout.scrollDirection = .vertical

        mnemonicCollectionViewController = MnemonicBackupModeCollectionViewController(collectionViewLayout: flowLayout)
        mnemonicCollectionViewController.delegate = self
        mnemonicCollectionViewController.mnemonics = sortedMnemonics
        mnemonicCollectionViewController.view.isHidden = false
        mnemonicCollectionViewController.index = 0
        mnemonicCollectionViewController.view.frame = CGRect(x: padding, y: collectionViewY, width: collectionViewWidth, height: collectionViewHeight)
        view.addSubview(mnemonicCollectionViewController.view)
        addChildViewController(mnemonicCollectionViewController)
        
        confirmButton.title = LocalizedString("Confirm", comment: "Go to VerifyMnemonicViewController")
        confirmButton.setupSecondary(height: 44)
        confirmButton.addTarget(self, action: #selector(pressedConfrimButton), for: .touchUpInside)

        skipButton.title = LocalizedString("Skip", comment: "Go to VerifyMnemonicViewController")
        skipButton.setupBlack(height: 44)
        skipButton.addTarget(self, action: #selector(pressedSkipButton), for: .touchUpInside)
        
        blurVisualEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        blurVisualEffectView.alpha = 1
        blurVisualEffectView.frame = UIScreen.main.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // CollectionView won't be layout correctly in viewDidLoad()
        // https://stackoverflow.com/questions/12927027/uicollectionview-flowlayout-not-wrapping-cells-correctly-ios
        // If you want to improve this part, please submit a PR to review
        if firstAppear {
            self.mnemonicCollectionViewController.view.frame = CGRect(x: padding, y: collectionViewY, width: self.collectionViewWidth, height: self.collectionViewHeight)
            mnemonicCollectionViewController.collectionView?.collectionViewLayout.invalidateLayout()
            
            firstAppear = false
        }
        GenerateWalletDataManager.shared.clearUserInputMnemonic()
        mnemonicsTextView.applyShadow(withColor: .black)
    }
    
    func collectionViewDidSelectItemAt(indexPath: IndexPath) {
        print("collectionViewDidSelectItemAt \(indexPath.row)")
        let mnemonic = sortedMnemonics[indexPath.row]
        if !GenerateWalletDataManager.shared.getUserInputMnemonics().contains(mnemonic) {
            GenerateWalletDataManager.shared.addUserInputMnemonic(mnemonic: sortedMnemonics[indexPath.row])
            mnemonicCollectionViewController.userSelections.append(indexPath.row)
        } else {
            GenerateWalletDataManager.shared.undoUserInputMnemonic(mnemonic: sortedMnemonics[indexPath.row])
            if let index = mnemonicCollectionViewController.userSelections.index(of: indexPath.row) {
                mnemonicCollectionViewController.userSelections.remove(at: index)
            }
        }

        mnemonicCollectionViewController.collectionView?.reloadData()
        mnemonicsTextView.text = GenerateWalletDataManager.shared.getUserInputMnemonics().joined(separator: "  ")
    }

    @objc func pressedConfrimButton(_ sender: Any) {
        print("pressedConfrimButton")
        if GenerateWalletDataManager.shared.verify() {
            // Store the new wallet to the local storage and exit the view controller.
            displayWalletCreateSuccessfully(verified: true)
        } else {
            print("User input Mnemonic doesn't match")
            var title = ""
            if GenerateWalletDataManager.shared.getUserInputMnemonics().count == 0 {
                title = LocalizedString("Please click words in order to verify your mnemonic.", comment: "")
            } else {
                title = LocalizedString("Mnemonic doesn't match. Please verify again.", comment: "")
            }

            // Reset
            GenerateWalletDataManager.shared.clearUserInputMnemonic()

            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                // Reset data
                self.mnemonicCollectionViewController.userSelections = []
                self.mnemonicCollectionViewController.collectionView?.reloadData()
                self.mnemonicsTextView.text = GenerateWalletDataManager.shared.getUserInputMnemonics().joined(separator: "  ")
            })
            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func pressedSkipButton(_ sender: Any) {
        displayWalletCreateSuccessfully(verified: false)
    }
    
    func displayWalletCreateSuccessfully(verified: Bool) {
        let vc = WalletCreateSuccessfullyPopViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.confirmClosure = {
            UIView.animate(withDuration: 0.1, animations: {
                self.blurVisualEffectView.alpha = 0.0
            }, completion: { (_) in
                self.blurVisualEffectView.removeFromSuperview()
            })
            
            GenerateWalletDataManager.shared.complete(completion: {(appWallet, error) in
                if error == nil {
                    if verified {
                        Answers.logSignUp(withMethod: QRCodeMethod.create.description + ".verified", success: true, customAttributes: nil)
                    } else {
                        Answers.logSignUp(withMethod: QRCodeMethod.create.description + ".skip", success: true, customAttributes: nil)
                    }
                    self.dismissGenerateWallet()
                } else if error == .duplicatedAddress {
                    self.alertForDuplicatedAddress()
                } else {
                    self.alertForError()
                }
            })
        }

        vc.cancelClosure = {
            UIView.animate(withDuration: 0.1, animations: {
                self.blurVisualEffectView.alpha = 0.0
            }, completion: { (_) in
                self.blurVisualEffectView.removeFromSuperview()
            })
        }

        self.present(vc, animated: true, completion: nil)
        
        self.navigationController?.view.addSubview(self.blurVisualEffectView)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurVisualEffectView.alpha = 1.0
        }, completion: {(_) in
            
        })
    }

    func dismissGenerateWallet() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController = MainTabController()
    }
}
