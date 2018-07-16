//
//  VerifyMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class VerifyMnemonicViewController: UIViewController, MnemonicBackupModeCollectionViewControllerDelegate {

    var sortedMnemonics: [String] = []

    var infoLabel: UILabel = UILabel()
    var mnemonicsTextView: UITextView = UITextView()

    var undoLastClickButton: UIButton = UIButton()
    var confirmButton: UIButton = UIButton()

    var mnemonicCollectionViewController: MnemonicBackupModeCollectionViewController!
    
    var collectionViewY: CGFloat = 200
    var collectionViewWidth: CGFloat = 200
    var collectionViewHeight: CGFloat = 220
    
    private let originY: CGFloat = 30
    private var padding: CGFloat = 15
    private let buttonPaddingY: CGFloat = 40
    
    private var firstAppear = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // mnemonics.shuffle()
        sortedMnemonics = GenerateWalletDataManager.shared.getMnemonics()
        sortedMnemonics.sort { (a, b) -> Bool in
            return a < b
        }
        
        self.navigationItem.title = LocalizedString("Please Verify Your Mnemonic", comment: "")
        setBackButton()
        updateButtons()
        
        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        
        collectionViewWidth = screenWidth - padding * 2
        collectionViewHeight = CGFloat(sortedMnemonics.count/3) * MnemonicBackupModeCollectionViewCell.getHeight() + 2*padding
        padding = (screenHeight - 120 - collectionViewHeight - 140 - 40) / 3
        
        infoLabel.frame = CGRect(x: 15, y: 5, width: screenWidth - 2*15, height: 40)
        
        infoLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        infoLabel.font = FontConfigManager.shared.getLabelFont(size: 17)
        infoLabel.text = LocalizedString("Please click words in order.", comment: "")
        view.addSubview(infoLabel)
        
        mnemonicsTextView.frame = CGRect(x: 15, y: infoLabel.frame.maxY + 15, width: screenWidth - 2*15, height: 120)
        mnemonicsTextView.font = FontConfigManager.shared.getLabelFont()
        mnemonicsTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        mnemonicsTextView.textColor = .black
        mnemonicsTextView.tintColor = UIColor.black
        mnemonicsTextView.textContainerInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        mnemonicsTextView.cornerRadius = 10
        mnemonicsTextView.isEditable = false
        view.addSubview(mnemonicsTextView)

        collectionViewY = mnemonicsTextView.frame.maxY + padding
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (collectionViewWidth - 30)/3, height: MnemonicBackupModeCollectionViewCell.getHeight())
        flowLayout.scrollDirection = .vertical

        mnemonicCollectionViewController = MnemonicBackupModeCollectionViewController(collectionViewLayout: flowLayout)
        mnemonicCollectionViewController.delegate = self
        mnemonicCollectionViewController.mnemonics = sortedMnemonics
        mnemonicCollectionViewController.view.isHidden = false
        mnemonicCollectionViewController.index = 0
        mnemonicCollectionViewController.view.frame = CGRect(x: 15, y: collectionViewY, width: collectionViewWidth, height: collectionViewHeight)
        view.addSubview(mnemonicCollectionViewController.view)
        addChildViewController(mnemonicCollectionViewController)
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
            self.mnemonicCollectionViewController.view.frame = CGRect(x: 15, y: collectionViewY, width: self.collectionViewWidth, height: self.collectionViewHeight)
            mnemonicCollectionViewController.collectionView?.collectionViewLayout.invalidateLayout()
            
            firstAppear = false
        }
        GenerateWalletDataManager.shared.clearUserInputMnemonic()
    }
    
    func updateButtons() {
        confirmButton.title = LocalizedString("Confirm", comment: "Go to VerifyMnemonicViewController")
        confirmButton.setupSecondary()
        confirmButton.addTarget(self, action: #selector(pressedConfrimButton(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(confirmButton)

        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 15))
        view.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -15))
        view.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 47))
        view.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -15))

        // TODO: the button is not in the correct layout in iPhone 5s
        undoLastClickButton.isHidden = true
        undoLastClickButton.title = LocalizedString("Undo Last Click", comment: "")
        undoLastClickButton.setupPrimary()
        undoLastClickButton.alpha = 0.0
        undoLastClickButton.addTarget(self, action: #selector(pressedUndoLastClickButton(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(undoLastClickButton)
        
        undoLastClickButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: undoLastClickButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 15))
        view.addConstraint(NSLayoutConstraint(item: undoLastClickButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -15))
        view.addConstraint(NSLayoutConstraint(item: undoLastClickButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 47))
        view.addConstraint(NSLayoutConstraint(item: undoLastClickButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -77))
    }
    
    func collectionViewDidSelectItemAt(indexPath: IndexPath) {
        let mnemonic = sortedMnemonics[indexPath.row]
        if !GenerateWalletDataManager.shared.getUserInputMnemonics().contains(mnemonic) {
            GenerateWalletDataManager.shared.addUserInputMnemonic(mnemonic: sortedMnemonics[indexPath.row])
            mnemonicCollectionViewController.userSelections.append(indexPath.row)
        }

        if GenerateWalletDataManager.shared.getUserInputMnemonics().count == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.undoLastClickButton.alpha = 1.0
            })
        }
        mnemonicCollectionViewController.collectionView?.reloadData()
        mnemonicsTextView.text = GenerateWalletDataManager.shared.getUserInputMnemonics().joined(separator: "  ")
    }
    
    @objc func pressedUndoLastClickButton(_ sender: Any) {
        print("pressedUndoLastClickButton")
        GenerateWalletDataManager.shared.undoLastUserInputMnemonic()
        _ = mnemonicCollectionViewController.userSelections.popLast()
        if GenerateWalletDataManager.shared.getUserInputMnemonics().count == 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.undoLastClickButton.alpha = 0.0
            })
        }
        mnemonicsTextView.text = GenerateWalletDataManager.shared.getUserInputMnemonics().joined(separator: "  ")
        mnemonicCollectionViewController.collectionView?.reloadData()
    }
    
    @objc func pressedConfrimButton(_ sender: Any) {
        print("pressedConfrimButton")
        if GenerateWalletDataManager.shared.verify() {
            // Store the new wallet to the local storage and exit the view controller.
            exit()
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
                if GenerateWalletDataManager.shared.getUserInputMnemonics().count == 0 {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.undoLastClickButton.alpha = 0.0
                    })
                }
                // Reset data
                self.mnemonicCollectionViewController.userSelections = []
                self.mnemonicCollectionViewController.collectionView?.reloadData()
                self.mnemonicsTextView.text = GenerateWalletDataManager.shared.getUserInputMnemonics().joined(separator: "  ")
            })
            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }

    func exit() {
        let header = LocalizedString("Create_used_in_creating_wallet", comment: "used in creating wallet")
        let footer = LocalizedString("successfully_used_in_creating_wallet", comment: "used in creating wallet")
        let attributedString = NSAttributedString(string: header + " " + "\(GenerateWalletDataManager.shared.walletName)" + " " + footer, attributes: [
            NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getMedium(), size: 17) ?? UIFont.systemFont(ofSize: 17),
            NSAttributedStringKey.foregroundColor: UIColor.init(rgba: "#030303")
            ])
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertController.setValue(attributedString, forKey: "attributedMessage")
        let confirmAction = UIAlertAction(title: LocalizedString("Enter Wallet", comment: ""), style: .default, handler: { _ in
            GenerateWalletDataManager.shared.complete(completion: {(appWallet, error) in
                if error == nil {
                    self.dismissGenerateWallet()
                } else if error == .duplicatedAddress {
                    self.alertForDuplicatedAddress()
                } else {
                    self.alertForError()
                }
            })
        })
        alertController.addAction(confirmAction)

        // Show the UIAlertController
        self.present(alertController, animated: true, completion: nil)
    }
    
    func dismissGenerateWallet() {
        if SetupDataManager.shared.hasPresented {
            self.dismiss(animated: true, completion: {
                
            })
        } else {
            SetupDataManager.shared.hasPresented = true
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        }
    }
}
