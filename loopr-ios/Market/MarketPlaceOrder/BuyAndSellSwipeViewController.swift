//
//  BuyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class BuyAndSellSwipeViewController: SwipeViewController {
    
    var market: Market!

    var initialType: TradeType = .buy
    private var types: [TradeType] = [.buy, .sell]
    private var viewControllers: [UIViewController] = []
    var options = SwipeViewOptions.getDefault()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        self.navigationItem.title = PlaceOrderDataManager.shared.market.description
        let initIndex = initialType == .buy ? 0 : 1

        let vc1 = BuyViewController(type: .buy)
        vc1.market = market

        let vc2 = BuyViewController(type: .sell)
        vc2.market = market

        viewControllers = [vc1, vc2]
        for viewController in viewControllers {
            self.addChildViewController(viewController)
        }

        swipeView.reloadData(options: options, default: initIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Themes.isDark() {
            options.swipeTabView.itemView.textColor = UIColor.init(white: 0.5, alpha: 1)
            options.swipeTabView.itemView.selectedTextColor = UIColor.white
            // swipeView.reloadData(options: options, default: initIndex)
        } else {
            options.swipeTabView.itemView.textColor = UIColor.init(white: 0.5, alpha: 1)
            options.swipeTabView.itemView.selectedTextColor = UIColor.black
            // swipeView.reloadData(options: options, default: initIndex)
        }
    }
    
    // To avoid gesture conflicts in swiping to back and UISlider
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != nil && touch.view!.isKind(of: UIControl.self) {
            return false
        }
        return true
    }

    // MARK: - Delegate
    override func swipeView(_ swipeView: SwipeView, viewWillSetupAt currentIndex: Int) {
        // print("will setup SwipeView")
    }
    
    override func swipeView(_ swipeView: SwipeView, viewDidSetupAt currentIndex: Int) {
        // print("did setup SwipeView")
    }
    
    override func swipeView(_ swipeView: SwipeView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // print("will change from item \(fromIndex) to item \(toIndex)")
    }
    
    override func swipeView(_ swipeView: SwipeView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // print("did change from item \(fromIndex) to section \(toIndex)")
    }
    
    // MARK: - DataSource
    override func numberOfPages(in swipeView: SwipeView) -> Int {
        return viewControllers.count
    }
    
    override func swipeView(_ swipeView: SwipeView, titleForPageAt index: Int) -> String {
        return types[index].description
    }
    
    override func swipeView(_ swipeView: SwipeView, viewControllerForPageAt index: Int) -> UIViewController {
        return viewControllers[index]
    }
}
