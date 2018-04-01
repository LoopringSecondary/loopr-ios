//
//  BackupMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import TagListView

class BackupMnemonicViewController: UIViewController {

    var titleLabel: UILabel =  UILabel()
    var infoTextView: UITextView = UITextView()

    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var verifyNowButton: UIButton!
    
    var blurVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationItem.title = NSLocalizedString("Backup Mnemonic", comment: "")
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        titleLabel.frame = CGRect(x: padding, y: originY, width: screenWidth - padding * 2, height: 30)
        titleLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 27)
        titleLabel.text = NSLocalizedString("Please Write Down", comment: "")
        view.addSubview(titleLabel)
        
        infoTextView.frame = CGRect(x: padding-3, y: 72, width: screenWidth - (padding-3) * 2, height: 96)
        infoTextView.isEditable = false
        infoTextView.text = "Please make sure you have recorded all the words safely. Otherwise, you will not be able to go through the verification process, and have to start over."
        infoTextView.textColor = UIColor.black.withAlphaComponent(0.6)
        infoTextView.font = FontConfigManager.shared.getLabelFont(size: 17)
        view.addSubview(infoTextView)
        
        tagListView.textFont = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 14)!
        tagListView.tagBackgroundColor = UIColor.white
        tagListView.textColor = UIColor.black
        tagListView.cornerRadius = 15
        tagListView.paddingX = 15
        tagListView.paddingY = 10
        tagListView.marginX = 10
        tagListView.marginY = 10

        let mnemoics: [String] = GenerateWalletDataManager.shared.getMnemonics()
        for value in mnemoics {
            tagListView.addTag(value)
        }

        verifyNowButton.title = NSLocalizedString("Verify Now", comment: "Go to VerifyMnemonicViewController")
        verifyNowButton.setupRoundBlack()

        blurVisualEffectView.alpha = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let attributedString = NSAttributedString(string: "Please make sure you have backed up mnemonic.", attributes: [
            NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getMedium(), size: 17) ?? UIFont.systemFont(ofSize: 17),
            NSAttributedStringKey.foregroundColor: UIColor.init(rgba: "#030303")
        ])

        let alertController = UIAlertController(title: nil,
            message: nil,
            preferredStyle: .alert)

        alertController.setValue(attributedString, forKey: "attributedMessage")

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.blurVisualEffectView.alpha = 0.0
            }, completion: {(_) in
                self.blurVisualEffectView.removeFromSuperview()
            })
            
        })
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { _ in
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
    
}
