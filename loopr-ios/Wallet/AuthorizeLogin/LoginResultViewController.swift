//
//  LoginResultViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/6/11.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class LoginResultViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var result: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        view.theme_backgroundColor = ColorPicker.backgroundColor
        
        resultLabel.font = FontConfigManager.shared.getMediumFont(size: 20)
        resultLabel.theme_textColor = GlobalPicker.textColor

        detailLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        detailLabel.theme_textColor = GlobalPicker.textColor
        
        doneButton.title = LocalizedString("Done", comment: "")
        doneButton.setupSecondary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if result {
            resultLabel.text = LocalizedString("Authorization Successful", comment: "")
            detailLabel.text = LocalizedString("Authorize_Successfully", comment: "")
        } else {
            resultLabel.text = LocalizedString("Authorization Failed", comment: "")
            detailLabel.text = LocalizedString("Authorize_Failed", comment: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedDoneButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
