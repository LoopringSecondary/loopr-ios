//
//  WalletNavigationViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class WalletNavigationViewController: UINavigationController {

    var walletExists = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showWallet()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //Present Wallet UI if wallet is present
    func showWallet(){
        if walletExists == true {
            let viewController = WalletViewController(nibName: nil, bundle: nil)
            self.setViewControllers([viewController], animated: false)
        }else{
            let viewController = SetupViewController(nibName: nil, bundle: nil)
            self.setViewControllers([viewController], animated: false)
            
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
