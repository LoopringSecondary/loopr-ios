//
//  PortfolioViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 1/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class PortfolioNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let viewController = PortfolioViewController(nibName: nil, bundle: nil)
        self.setViewControllers([viewController], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
