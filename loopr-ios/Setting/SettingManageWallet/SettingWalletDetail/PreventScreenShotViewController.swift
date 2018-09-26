//
//  PreventScreenShotViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/9/3.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class PreventScreenShotViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tipInfoLabel: UILabel!
    @IBOutlet weak var seperator: UIView!
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
        
        titleLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        titleLabel.theme_textColor = ["#00000099", "#ffffff"]
        titleLabel.text = LocalizedString("Prevent_Title", comment: "")
        
        tipInfoLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        tipInfoLabel.theme_textColor = ["#00000099", "#ffffff66"]
        tipInfoLabel.text = LocalizedString("Prevent_Tip", comment: "")

        seperator.theme_backgroundColor = ColorPicker.cardHighLightColor
        
        confirmButton.titleLabel?.font = FontConfigManager.shared.getCharactorFont(size: 18)
        confirmButton.tintColor = UIColor.fail
        confirmButton.title = LocalizedString("Got it", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedConfirmButton(_ sender: UIButton) {
        close()
    }

    func close() {
        if let closure = self.dismissClosure {
            closure()
        }
        self.dismiss(animated: true, completion: {
        })
    }
}
