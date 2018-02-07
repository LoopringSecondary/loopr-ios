//
//  MarketDetailViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailViewController: UIViewController {

    var market: Market? = nil
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = market?.description
        
        let lineChartViewController = MarketLineChartViewController()

        self.addChildViewController(lineChartViewController)
        mainScrollView.addSubview(lineChartViewController.view)

        lineChartViewController.view.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 0.0).isActive = true
        lineChartViewController.view.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 0.0).isActive = true
        lineChartViewController.view.rightAnchor.constraint(equalTo: mainScrollView.rightAnchor, constant: 0.0).isActive = true
        lineChartViewController.view.frame.size.height = 400
        
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
