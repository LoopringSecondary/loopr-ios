//
//  AuthenticationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/23/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController {

    var unlockAppButton = UIButton()
    var backgrondImageView = UIImageView()

    var needNavigate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Show AuthenticationViewController")

        let screenSize: CGRect = UIScreen.main.bounds
        backgrondImageView.frame = screenSize
        backgrondImageView.image = UIImage(named: "Background")
        backgrondImageView.isUserInteractionEnabled = true
        view.addSubview(backgrondImageView)

        unlockAppButton.title = LocalizedString("Unlock", comment: "")
        unlockAppButton.setupSecondary()
        unlockAppButton.addTarget(self, action: #selector(pressedUnlockAppButton), for: .touchUpInside)
        backgrondImageView.addSubview(unlockAppButton)

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

        startAuthentication()
    }

    @objc func pressedUnlockAppButton(_ sender: Any) {
        print("pressedUnlockAppButton")
        startAuthentication()
    }
    
    func startAuthentication() {
        AuthenticationDataManager.shared.authenticate { (error) in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            if self.needNavigate {
                DispatchQueue.main.async {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
