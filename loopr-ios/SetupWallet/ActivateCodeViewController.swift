//
//  ActivateCodeViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/8.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class ActivateCodeViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var activateCodeTextField: UITextField!
    
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .custom
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Code_Tip", comment: "")
        activateCodeTextField.placeholder = LocalizedString("Please input activate code", comment: "")
        activateCodeTextField.setLeftPaddingPoints(8)
        cancelButton.title = LocalizedString("Cancel", comment: "")
        cancelButton.titleLabel?.setTitleCharFont()
        cancelButton.round(corners: .bottomLeft, radius: 6)
        cancelButton.tintColor = UIColor.text1
        confirmButton.title = LocalizedString("Confirm", comment: "")
        confirmButton.titleLabel?.setTitleCharFont()
        confirmButton.round(corners: .bottomRight, radius: 6)
        confirmButton.tintColor = UIColor.text1
        confirmButton.backgroundColor = UIColor.success
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        activateCodeTextField.resignFirstResponder()
        if let closure = self.dismissClosure {
            closure()
        }
        self.dismiss(animated: true, completion: {
        })
    }
    
    @IBAction func pressedCancelButton(_ sender: UIButton) {
        self.close()
    }
    
    @IBAction func pressedConfirmButton(_ sender: UIButton) {
        if let code = activateCodeTextField.text {
            CityPartnerDataManager.shared.submitCode(code: code) { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.activateCodeTextField.resignFirstResponder()
                        let title = LocalizedString("Code_Error_Tip", comment: "")
                        let banner = NotificationBanner.generate(title: title, style: .danger)
                        banner.duration = 10
                        banner.show()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.close()
                        let vc = SetupWalletViewController()
                        self.parentNavController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
}
