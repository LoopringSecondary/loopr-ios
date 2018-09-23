//
//  SettingChangeWalletNameViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingChangeWalletNameViewController: UIViewController, UITextFieldDelegate {

    var appWallet: AppWallet!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var separateLineUp: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var separateLineDown: UIView!

    var didChangeWalletName: ((_ newWalletName: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = LocalizedString("Wallet Name", comment: "")
        setBackButton()
        view.theme_backgroundColor = ColorPicker.backgroundColor

        contentView.theme_backgroundColor = ColorPicker.cardBackgroundColor
    
        nameTextField.delegate = self
        nameTextField.tag = 0
        nameTextField.font = FontConfigManager.shared.getMediumFont(size: 14)
        nameTextField.theme_tintColor = GlobalPicker.textColor
        nameTextField.theme_textColor = GlobalPicker.textColor
        nameTextField.theme_backgroundColor = ColorPicker.cardBackgroundColor
        nameTextField.placeholder = LocalizedString("Wallet Name", comment: "")
        nameTextField.setValue(UIColor.init(white: 1, alpha: 0.4), forKeyPath: "_placeholderLabel.textColor")
        nameTextField.contentMode = UIViewContentMode.bottom
        nameTextField.keyboardAppearance = Themes.isDark() ? .dark : .default

        separateLineUp.backgroundColor = UIColor.dark3
        separateLineDown.backgroundColor = UIColor.dark3
        
        nameTextField.text = appWallet.name
        
        let saveButon = UIBarButtonItem(title: LocalizedString("Save", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(pressedSaveButton))
        saveButon.setTitleTextAttributes([NSAttributedStringKey.font: FontConfigManager.shared.getCharactorFont(size: 14)], for: .normal)
        self.navigationItem.rightBarButtonItem = saveButon
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func pressedSaveButton(_ sender: Any) {
        print("pressedSwitchTokenBButton: \(appWallet)")
        print("wallet Name is: \(appWallet.name)")
        
        if nameTextField.text?.count != 0 {
            appWallet.name = nameTextField.text!
            let dataManager = AppWalletDataManager.shared
            dataManager.updateAppWalletsInLocalStorage(newAppWallet: appWallet)
            didChangeWalletName?(appWallet.name)
            self.navigationController?.popViewController(animated: true)
        } else {
            let alertController = UIAlertController(title: LocalizedString("New wallet name can't be empty", comment: ""), message: nil, preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                
            })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
