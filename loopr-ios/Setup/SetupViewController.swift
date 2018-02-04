//
//  SetupViewController.swift
//  loopr-ios
//
//  Created by Matthew Cox on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {

    @IBOutlet weak var unlockWalletButton: UIButton!
    @IBOutlet weak var generateWalletButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unlockWalletButton.layer.cornerRadius = 10
        generateWalletButton.layer.cornerRadius = 10
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unlockButtonPressed(_ sender: Any) {
    
    }
    
    
    @IBAction func generateWalletButtonPressed(_ sender: Any) {
        let generateWalletViewController = GenerateWalletViewController();
        generateWalletViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(generateWalletViewController, animated: true)
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
