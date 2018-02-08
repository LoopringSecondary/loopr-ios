//
//  SellViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SellViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func pressedCloseButton(_ sender: Any) {
        print("pressedCloseButton")
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func pressedOrderTypesButton(_ sender: Any) {
        print("pressedOrderTypesButton")

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
