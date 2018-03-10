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
        view.theme_backgroundColor = GlobalPicker.backgroundColor

        self.navigationItem.title = NSLocalizedString("Market", comment: "")

        options.swipeTabView.height = 44
        options.swipeTabView.underlineView.height = 1
        options.swipeTabView.underlineView.margin = 20

        // TODO: needsAdjustItemViewWidth will trigger expensive computation.
        // options.swipeTabView.needsAdjustItemViewWidth = false
        
        // TODO: .segmented will disable the value of width
        options.swipeTabView.style = .segmented
        
        options.swipeTabView.itemView.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 21) ?? UIFont.systemFont(ofSize: 21)
        
        // This conflicts to the swipe action in the table view cell.
        options.swipeContentScrollView.isScrollEnabled = false
        
        swipeView.reloadData(options: options)
        
        for viewController in viewControllers {
            self.addChildViewController(viewController)
        }

        let orderHistoryButton = UIButton(type: UIButtonType.custom)
        let image = UIImage(named: "Order-history-black")
        orderHistoryButton.setBackgroundImage(image, for: .normal)
        orderHistoryButton.setBackgroundImage(image?.alpha(0.3), for: .highlighted)
        
        orderHistoryButton.addTarget(self, action: #selector(self.pressOrderHistoryButton(_:)), for: UIControlEvents.touchUpInside)
        orderHistoryButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let orderHistoryBarButton = UIBarButtonItem(customView: orderHistoryButton)
        self.navigationItem.rightBarButtonItem = orderHistoryBarButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Themes.isNight() {
            options.swipeTabView.itemView.textColor = UIColor.init(white: 0.5, alpha: 1)
            options.swipeTabView.itemView.selectedTextColor = UIColor.white
            swipeView.reloadData(options: options)
        } else {
            options.swipeTabView.itemView.textColor = UIColor.init(white: 0.5, alpha: 1)
            options.swipeTabView.itemView.selectedTextColor = UIColor.black
            swipeView.reloadData(options: options)
        }
    }
    
    private func reload() {
        // Reload view controllers.
        swipeView.reloadData(options: options)
    }
    
    @objc func pressOrderHistoryButton(_ button: UIBarButtonItem) {
        print("pressOrderHistoryButton")
        let viewController = OrderHistoryViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
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

    // MARK: - DataSource
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
