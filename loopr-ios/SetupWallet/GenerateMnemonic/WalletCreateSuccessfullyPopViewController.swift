//
//  WalletCreateSuccessfullyPopViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 9/8/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class WalletCreateSuccessfullyPopViewController: UIViewController {

    @IBOutlet weak var resultIconImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var dismissClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .custom
        view.backgroundColor = .clear
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        containerView.layer.cornerRadius = 6
        containerView.clipsToBounds = true
        
        resultIconImageView.image = UIImage(named: "Result-header-success")

        infoLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        infoLabel.textColor = UIColor.success
        infoLabel.text = LocalizedString("Wallet Create Successull！", comment: "")

        confirmButton.titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 18)
        confirmButton.tintColor = UIColor.success
        confirmButton.title = LocalizedString("OK, Got It", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedConfirmButton(_ sender: Any) {
        dismissClosure?()
        self.dismiss(animated: true, completion: {
        })
    }
    
}
