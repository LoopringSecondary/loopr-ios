//
//  ThirdPartyViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/11/1.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class ThirdPartyViewController: UIViewController {
    
    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var wechatButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var footerTip: UILabel!
    @IBOutlet weak var footerTip2: UILabel!
    
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
    }
    
    @IBAction func pressedSkipButton(_ sender: Any) {
        var vc: UIViewController
        if AppWalletDataManager.shared.getWallets().isEmpty {
            vc = SetupNavigationController(nibName: nil, bundle: nil)
        } else {
            vc = MainTabController(nibName: nil, bundle: nil)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
}
