//
//  MarketSwipeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketSwipeViewController: SwipeViewController {

    private var types: [MarketSwipeViewType] = [.favorite, .ETH, .LRC, .all]
    private var viewControllers: [MarketViewController] = [MarketViewController(type: .favorite), MarketViewController(type: .ETH), MarketViewController(type: .LRC), MarketViewController(type: .all)]
    var options = SwipeViewOptions()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Market"
        
        options.swipeTabView.height = 44
        options.swipeTabView.itemView.width = 66
        
        // TODO: needsAdjustItemViewWidth will trigger expensive computation.
        // options.swipeTabView.needsAdjustItemViewWidth = false
        
        // TODO: .segmented will disable the value of width
        options.swipeTabView.style = .segmented
        
        options.swipeTabView.itemView.font = UIFont.boldSystemFont(ofSize: 17)
        
        // This conflicts to the swipe action in the table view cell.
        options.swipeContentScrollView.isScrollEnabled = false
        
        swipeView.reloadData(options: options)
        
        for viewController in viewControllers {
            self.addChildViewController(viewController)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func reload() {
        // Reload view controllers.
        swipeView.reloadData(options: options)
    }
    
    // MARK: - Delegate
    override func swipeView(_ swipeView: SwipeView, viewWillSetupAt currentIndex: Int) {
        print("will setup SwipeView")
    }
    
    override func swipeView(_ swipeView: SwipeView, viewDidSetupAt currentIndex: Int) {
        print("did setup SwipeView")
    }

    override func swipeView(_ swipeView: SwipeView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        print("will change from item \(fromIndex) to item \(toIndex)")
        let viewController = viewControllers[toIndex]
        viewController.reload()
    }

    override func swipeView(_ swipeView: SwipeView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        print("did change from item \(fromIndex) to section \(toIndex)")
    }

    // MARK - DataSource
    override func numberOfPages(in swipeView: SwipeView) -> Int {
        return types.count
    }
    
    override func swipeView(_ swipeView: SwipeView, titleForPageAt index: Int) -> String {
        return types[index].rawValue
    }

    override func swipeView(_ swipeView: SwipeView, viewControllerForPageAt index: Int) -> UIViewController {
        return viewControllers[index]
    }

}
