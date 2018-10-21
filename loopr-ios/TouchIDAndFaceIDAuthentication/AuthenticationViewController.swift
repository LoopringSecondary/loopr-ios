//
//  AuthenticationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/23/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController {

    var unlockAppButton = UIButton(frame: .zero)
    var unlockAppIconButton = UIButton(frame: .zero)
    var backgrondImageView = UIImageView(frame: .zero)

    var needNavigate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Show AuthenticationViewController")

        let screenSize: CGRect = UIScreen.main.bounds
        backgrondImageView.frame = screenSize
        backgrondImageView.image = UIImage(named: "Background" + ColorTheme.getTheme())
        backgrondImageView.isUserInteractionEnabled = true
        view.addSubview(backgrondImageView)

        unlockAppButton.title = LocalizedString("Unlock", comment: "")
        unlockAppButton.setTitleColor(UIColor.white, for: .normal)
        unlockAppButton.setTitleColor(UIColor.init(white: 0.5, alpha: 1), for: .highlighted)
        unlockAppButton.titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 16)
        unlockAppButton.addTarget(self, action: #selector(pressedUnlockAppButton), for: .touchUpInside)
        backgrondImageView.addSubview(unlockAppButton)
        
        unlockAppIconButton.setImage(UIImage.init(named: "auth-icon-dark"), for: .normal)
        unlockAppIconButton.addTarget(self, action: #selector(pressedUnlockAppButton), for: .touchUpInside)
        backgrondImageView.addSubview(unlockAppIconButton)
        
        // TODO: need to consider Face ID
        unlockAppIconButton.isHidden = true
        
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: May need to use auto layout.
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let bottomPadding: CGFloat = UIDevice.current.iPhoneX ? 30 : 0
        unlockAppButton.frame = CGRect(x: 15, y: screenHeight - bottomPadding - 47 - 63, width: screenWidth - 15 * 2, height: 47)

        unlockAppIconButton.frame = CGRect(x: (screenWidth-60)*0.5, y: unlockAppButton.frame.minY - 60, width: 60, height: 60)
        
        startAuthentication()
    }

    @objc func pressedUnlockAppButton(_ sender: Any) {
        print("pressedUnlockAppButton")
        startAuthentication()
    }
    
    func startAuthentication() {
        AuthenticationDataManager.shared.authenticate(reason: LocalizedString("Authenticate to access your wallet", comment: "")) { (error) in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            if self.needNavigate {
                DispatchQueue.main.async {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.window?.rootViewController = MainTabController()
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
