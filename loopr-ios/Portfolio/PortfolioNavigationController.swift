//
//  PortfolioViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 1/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class PortfolioNavigationController: UINavigationController {
    
    //TODO: Create Account Manager
    var userAccountExists = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.shadowImage = UIImage()

        let viewController = PortfolioViewController(nibName: nil, bundle: nil)
        self.setViewControllers([viewController], animated: false)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkForAccout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkForAccout(){
        if userAccountExists == false {
            tabBarController?.performSegue(withIdentifier: "showSetup", sender: tabBarController)
        }
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
