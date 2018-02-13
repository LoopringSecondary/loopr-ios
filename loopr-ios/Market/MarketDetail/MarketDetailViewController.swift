//
//  MarketDetailViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var market: Market? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    let interactor = Interactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        self.title = market?.description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + OrderDataManager.shared.getOrders().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            // TODO: Simplify the code and make it reusable in other places.
            // window only available after iOS 11.0
            guard #available(iOS 11.0, *),
                let window = UIApplication.shared.keyWindow else {
                    let navBarHeight = (self.navigationController?.navigationBar.intrinsicContentSize.height)!
                        + UIApplication.shared.statusBarFrame.height
                    return MarketLineChartTableViewCell.getHeight(navigationBarHeight: navBarHeight)
            }

            let safeAreaHeight = window.safeAreaInsets.top + window.safeAreaInsets.bottom
            // Check if it's an iPhone X
            if (safeAreaHeight > 0) {
                let navBarHeight = (self.navigationController?.navigationBar.intrinsicContentSize.height)!
                return MarketLineChartTableViewCell.getHeight(navigationBarHeight: navBarHeight) - safeAreaHeight
            } else {
                let navBarHeight = (self.navigationController?.navigationBar.intrinsicContentSize.height)!
                    + UIApplication.shared.statusBarFrame.height
                return MarketLineChartTableViewCell.getHeight(navigationBarHeight: navBarHeight)
            }

        } else {
            return OpenOrderTableViewCell.getHeight()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cellIdentifier = "MarketLineChartTableViewCellIdentifier"
            
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MarketLineChartTableViewCell
            if (cell == nil) {
                let nib = Bundle.main.loadNibNamed("MarketLineChartTableViewCell", owner: self, options: nil)
                cell = nib![0] as? MarketLineChartTableViewCell
                cell?.selectionStyle = .none
            }
            
            cell!.pressedBuyButtonClosure = {
                let buyViewController = BuyViewController()
                buyViewController.transitioningDelegate = self
                buyViewController.interactor = self.interactor
                self.present(buyViewController, animated: true) {
                    
                }
            }
            
            cell!.pressedSellButtonClosure = {
                let sellViewController = SellViewController()
                sellViewController.transitioningDelegate = self
                sellViewController.interactor = self.interactor
                self.present(sellViewController, animated: true) {
                    
                }
            }
            
            // Configure the cell...
            return cell!
        } else {
            let cellIdentifier = "OpenOrderTableViewCellIdentifier"
            
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? OpenOrderTableViewCell
            if (cell == nil) {
                let nib = Bundle.main.loadNibNamed("OpenOrderTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OpenOrderTableViewCell
                cell?.selectionStyle = .none
            }
            
            cell?.order = OrderDataManager.shared.getOrders()[indexPath.row-1]
            cell?.update()
            
            // Configure the cell...
            return cell!
        }       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension MarketDetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
