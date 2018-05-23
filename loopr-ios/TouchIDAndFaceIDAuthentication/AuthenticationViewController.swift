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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Show AuthenticationViewController")
        
        unlockAppButton.title = NSLocalizedString("Unlock App", comment: "")
        unlockAppButton.setupRoundBlack()
        unlockAppButton.addTarget(self, action: #selector(pressedUnlockAppButton), for: .touchUpInside)
        view.addSubview(unlockAppButton)
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
    }

    @objc func pressedUnlockAppButton(_ sender: Any) {
        print("pressedUnlockAppButton")
        self.dismiss(animated: true, completion: {
            
        })
    }

}
