//
//  BackupMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Crashlytics

class BackupMnemonicViewController: UIViewController {

    var mnemonics: [String] = []

    var backgroundImageView1 = UIImageView(frame: .zero)
    var infoTextView: UITextView = UITextView(frame: .zero)
    
    @IBOutlet weak var skipVerifyNowButton: UIButton!
    @IBOutlet weak var verifyNowButton: UIButton!
    
    var backgroundImageView2 = UIImageView(frame: .zero)
    var mnemonicCollectionViewController0: MnemonicCollectionViewController!

    var collectionViewY: CGFloat = 200
    var collectionViewWidth: CGFloat = 200
    var collectionViewHeight: CGFloat = 220
    
    private let originY: CGFloat = 30
    private let padding: CGFloat = 15
    private let buttonPaddingY: CGFloat = 40
    
    private var firstAppear = true
    var hideButtons: Bool = false
    var blurVisualEffectView = UIView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Backup Mnemonic", comment: "")

        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        backgroundImageView1.frame = CGRect(x: 18, y: 10, width: screenWidth - 18 * 2, height: 200)
        backgroundImageView1.backgroundColor = UIColor.clear
        backgroundImageView1.image = UIImage.init(named: "MnemonicBackgroundImage1" + ColorTheme.getTheme())
        backgroundImageView1.round(corners: [.topLeft, .topRight], radius: 6)
        view.addSubview(backgroundImageView1)
        
        backgroundImageView2.frame = CGRect(x: 18, y: backgroundImageView1.bottomY, width: screenWidth - 18 * 2, height: 200)
        backgroundImageView2.backgroundColor = UIColor.clear
        backgroundImageView2.image = UIImage.init(named: "MnemonicBackgroundImage2" + ColorTheme.getTheme())
        backgroundImageView2.round(corners: [.bottomLeft, .bottomRight], radius: 6)
        view.addSubview(backgroundImageView2)

        infoTextView.frame = CGRect(x: 20, y: 30, width: backgroundImageView1.width - 20*2, height: 160)
        infoTextView.isEditable = false
        infoTextView.textColor = UIColor.white
        infoTextView.backgroundColor = UIColor.clear
        infoTextView.font = UIFont.init(name: "Rubik-Italic", size: 14)
        backgroundImageView1.addSubview(infoTextView)

        collectionViewWidth = backgroundImageView1.width - 20 * 2
        collectionViewHeight = 4*MnemonicCollectionViewCell.getHeight() + 2*padding
        collectionViewY = 22
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (collectionViewWidth - 30)/3, height: MnemonicCollectionViewCell.getHeight())
        flowLayout.scrollDirection = .vertical
        
        mnemonicCollectionViewController0 = MnemonicCollectionViewController(collectionViewLayout: flowLayout)
        mnemonicCollectionViewController0.mnemonics = mnemonics
        mnemonicCollectionViewController0.view.isHidden = true
        mnemonicCollectionViewController0.view.frame = CGRect(x: 20, y: collectionViewY, width: collectionViewWidth, height: collectionViewHeight)
        backgroundImageView2.addSubview(mnemonicCollectionViewController0.view)
        addChildViewController(mnemonicCollectionViewController0)

        skipVerifyNowButton.title = LocalizedString("Skip_Verification", comment: "Go to VerifyMnemonicViewController")
        skipVerifyNowButton.setupBlack(height: 44)
        skipVerifyNowButton.isHidden = hideButtons
        
        verifyNowButton.title = LocalizedString("Verify", comment: "Go to VerifyMnemonicViewController")
        verifyNowButton.setupSecondary(height: 44)
        verifyNowButton.isHidden = hideButtons
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidTakeScreenshot), name: .UIApplicationUserDidTakeScreenshot, object: nil)
        
        blurVisualEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        blurVisualEffectView.alpha = 1
        blurVisualEffectView.frame = UIScreen.main.bounds

        displayWarning()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let stringValue = LocalizedString("Please don't show up in public places (prevent cameras from taking photos) or take a screen shot(your operating system may back up images to cloud storage). These operations can bring you huge and irreversible security risks.", comment: "")
        let attributedString = NSMutableAttributedString(string: stringValue)
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 20
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSRange(location: 0, length: stringValue.count))
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: stringValue.count))
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.init(name: "Rubik-Italic", size: 14) ?? UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: stringValue.count))
        infoTextView.attributedText = attributedString

        // CollectionView won't be layout correctly in viewDidLoad()
        // https://stackoverflow.com/questions/12927027/uicollectionview-flowlayout-not-wrapping-cells-correctly-ios
        // If you want to improve this part, please submit a PR to review
        if firstAppear {
            self.mnemonicCollectionViewController0.view.frame = CGRect(x: 20, y: collectionViewY, width: self.collectionViewWidth, height: self.collectionViewHeight)
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
    
    @objc func willEnterForeground() {
        displayWarning()
    }
    
    // If user takes a screenshot, regenerate new mnemonics
    @objc func userDidTakeScreenshot() {
        if !hideButtons {
            _ = GenerateWalletDataManager.shared.newMnemonics()
            mnemonics = GenerateWalletDataManager.shared.getMnemonics()
            mnemonicCollectionViewController0.mnemonics = mnemonics
            mnemonicCollectionViewController0.collectionView?.reloadData()
            displayWarning(tipInfo: LocalizedString("Because you did a screen capture, we have updated the wallet mnemonics for you, and your screenshots have been voided! This is for your asset security.", comment: ""))
        }
    }

    @IBAction func pressedVerifyNowButton(_ sender: Any) {
        let viewController = VerifyMnemonicViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func pressedSkipVerifyNowButton(_ sender: Any) {
        displayWalletCreateSuccessfully()
    }
    
    func displayWalletCreateSuccessfully() {
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
                    Answers.logSignUp(withMethod: QRCodeMethod.create.description + ".skip", success: true, customAttributes: nil)
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
    
    func displayWarning(tipInfo: String? = nil) {
        let vc = PreventScreenShotViewController()
        
        if tipInfo != nil {
            vc.tipInfo = tipInfo!
        }
        
        vc.modalPresentationStyle = .overFullScreen
        vc.dismissClosure = {
            UIView.animate(withDuration: 0.1, animations: {
                self.blurVisualEffectView.alpha = 0.0
            }, completion: { (_) in
                self.blurVisualEffectView.removeFromSuperview()
                self.mnemonicCollectionViewController0.view.isHidden = false
            })
        }
        self.present(vc, animated: true, completion: nil)
        
        self.navigationController?.view.addSubview(self.blurVisualEffectView)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurVisualEffectView.alpha = 1.0
        }, completion: {(_) in
            
        })
    }
    
}
