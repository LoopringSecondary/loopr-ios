//
//  TradePlaceReplyViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/2/28.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class TradePlaceReplyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        placedReply("successed!")
        // Do any additional setup after loading the view.
    }

    @IBAction func pressedCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func placedReply(_ message: String) {
        
        let a = CGRect(x: view.center.x, y: view.center.y, width: 100, height: 10)
        let label = UILabel(frame: a)
        label.text = message
        label.textAlignment = .center
        label.center = self.view.center
        self.view.addSubview(label)
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
