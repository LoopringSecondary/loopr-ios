//
//  SetupNavigationController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SetupNavigationController: UINavigationController {

    var isCreatingFirstWallet: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.tintColor = UIColor.dark1
        
        let viewController = SetupWalletViewController()
        self.setViewControllers([viewController], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
