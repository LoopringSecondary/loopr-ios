//
//  AuthenticationNavigationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/23/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AuthenticationNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.tintColor = UIStyleConfig.defaultTintColor

        let viewController = AuthenticationViewController(nibName: nil, bundle: nil)
        self.setViewControllers([viewController], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
