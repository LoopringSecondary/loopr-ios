//
//  H5DexNavigationController.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/12/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class H5DexNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.shadowImage = UIImage()
        
        let viewController = H5DexViewController(nibName: nil, bundle: nil)
        self.setViewControllers([viewController], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
