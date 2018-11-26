//
//  ThirdPartyViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/11/1.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Crashlytics

class ThirdPartyViewController: UIViewController {
    
    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var wechatButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var footerTip: UILabel!
    @IBOutlet weak var footerTip2: UILabel!
    
    var fromSettingViewController: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor
        loginTitle.setTitleCharFont()
        loginTitle.text = LocalizedString("Third title", comment: "")
        skipButton.titleLabel?.setTitleCharFont()
        skipButton.title = LocalizedString("Third skip", comment: "")
        skipButton.setTitleColor(.theme, for: .normal)
        footerTip.setSubTitleCharFont()
        footerTip.text = LocalizedString("Third tip1", comment: "")
        footerTip2.setSubTitleCharFont()
        footerTip2.text = LocalizedString("Third tip2", comment: "")
    }
    
    @IBAction func pressedWechatLogin(_ sender: Any) {
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "App"
        if !WXApi.send(req) {
            print("weixin sendreq failed")
        }
        Answers.logCustomEvent(withName: "Wechat Login v1", customAttributes: ["skip": "false"])
    }
    
    @IBAction func pressedSkipButton(_ sender: Any) {
        if fromSettingViewController {
            self.dismiss(animated: true) {
                
            }
            return
        }
        
        var vc: UIViewController
        if AppWalletDataManager.shared.getWallets().isEmpty {
            vc = SetupNavigationController(nibName: nil, bundle: nil)
        } else {
            vc = MainTabController.instantiate()
        }
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.thirdParty.rawValue)
        self.present(vc, animated: true, completion: nil)
        Answers.logCustomEvent(withName: "Wechat Login v1", customAttributes: ["skip": "true"])
    }
    
}
