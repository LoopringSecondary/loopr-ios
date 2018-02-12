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
    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = market?.description
        
        // TODO: The auto layout in this part just works. Need improvement.
        let lineChartViewController = MarketLineChartViewController()
        self.addChildViewController(lineChartViewController)
        stackView.addArrangedSubview(lineChartViewController.view)

        let screen = UIScreen.main.bounds
        let screenHeight = screen.height
        lineChartViewController.view.heightAnchor.constraint(equalToConstant: screenHeight).isActive = true
        
        let openOrderViewController = OpenOrderViewController()
        self.addChildViewController(openOrderViewController)
        stackView.addArrangedSubview(openOrderViewController.view)
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
