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

    var backgroundImageView1 = UIImageView()
    var titleLabel: UILabel =  UILabel()
    var infoTextView: UITextView = UITextView()
    
    @IBOutlet weak var skipVerifyNowButton: UIButton!
    @IBOutlet weak var verifyNowButton: UIButton!
    
    var backgroundImageView2 = UIImageView()
    var mnemonicCollectionViewController0: MnemonicCollectionViewController!

    var collectionViewY: CGFloat = 200
    var collectionViewWidth: CGFloat = 200
    var collectionViewHeight: CGFloat = 220
    
    private let originY: CGFloat = 30
    private let padding: CGFloat = 15
    private let buttonPaddingY: CGFloat = 40
    
    private var firstAppear = true
    var hideButtons: Bool = false
    var blurVisualEffectView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Verify Mnemonic", comment: "")

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
        
        titleLabel.frame = CGRect(x: padding, y: 30, width: backgroundImageView1.width - padding * 2, height: 20)
        titleLabel.textColor = UIColor.white
        titleLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        titleLabel.text = LocalizedString("Backup Mnemonic", comment: "")
        titleLabel.textAlignment = .center
        backgroundImageView1.addSubview(titleLabel)
        
        infoTextView.frame = CGRect(x: 20, y: 65, width: backgroundImageView1.width - 20*2, height: 120)
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
        // assign first 12 words
        mnemonicCollectionViewController0.mnemonics = mnemonics
        mnemonicCollectionViewController0.view.isHidden = false
        mnemonicCollectionViewController0.view.frame = CGRect(x: 20, y: collectionViewY, width: collectionViewWidth, height: collectionViewHeight)
        backgroundImageView2.addSubview(mnemonicCollectionViewController0.view)
        addChildViewController(mnemonicCollectionViewController0)

        skipVerifyNowButton.title = LocalizedString("Skip Verification", comment: "Go to VerifyMnemonicViewController")
        skipVerifyNowButton.setupBlack(height: 44)
        skipVerifyNowButton.isHidden = hideButtons
        
        verifyNowButton.title = LocalizedString("Verify Now", comment: "Go to VerifyMnemonicViewController")
        verifyNowButton.setupSecondary(height: 44)
        verifyNowButton.isHidden = hideButtons
        
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
        let stringValue = LocalizedString("Revealing your mnemonic phrases on web sites is highly dangerous. If the site is compromised or you accidentally visit a phishing website, your assets in all associated addresses can be stolen.", comment: "")
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

    @IBAction func pressedVerifyNowButton(_ sender: Any) {
        let viewController = VerifyMnemonicViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func pressedSkipVerifyNowButton(_ sender: Any) {
        exit()
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

        let backAction = UIAlertAction(title: LocalizedString("Back", comment: ""), style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(backAction)

        let confirmAction = UIAlertAction(title: LocalizedString("Enter Wallet", comment: ""), style: .default, handler: { _ in
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
        })
        alertController.addAction(confirmAction)
        
        // Show the UIAlertController
        self.present(alertController, animated: true, completion: nil)
    }

    func dismissGenerateWallet() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController = MainTabController()
    }
    
    func displayWarning() {
        let vc = PreventScreenShotViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.dismissClosure = {
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
    
}
