//
//  AssetSwipeViewController.swift
//  loopr-ios
//
//  Created by 王忱 on 2018/7/19.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class AssetSwipeViewController: SwipeViewController {

    private var type: TxSwipeViewType = .all
    private var types: [TxSwipeViewType] = []
    private var viewControllers: [AssetDetailViewController] = []
    
    var asset: Asset?
    var options = SwipeViewOptions()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        self.topConstraint = 140
        setBackButton()
        setupChildViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Themes.isDark() {
            options.swipeTabView.itemView.textColor = UIColor.init(white: 0.5, alpha: 1)
            options.swipeTabView.itemView.selectedTextColor = UIColor.white
        } else {
            options.swipeTabView.itemView.textColor = UIColor.init(white: 0.5, alpha: 1)
            options.swipeTabView.itemView.selectedTextColor = UIColor.black
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupChildViewControllers() {
        types = [.all, .time, .type, .status]
        for (index, type) in types.enumerated() {
            let vc = AssetDetailViewController(type: type)
            vc.asset = self.asset
            viewControllers.insert(vc, at: index)
        }
        for viewController in viewControllers {
            self.addChildViewController(viewController)
        }
        options.swipeTabView.height = 44
        options.swipeTabView.underlineView.height = 1
        options.swipeTabView.underlineView.margin = 20
        options.swipeTabView.itemView.font = FontConfigManager.shared.getRegularFont()
        options.swipeContentScrollView.isScrollEnabled = false
        options.swipeTabView.style = .segmented
        swipeView.reloadData(options: options)
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
        type = types[toIndex]
        let viewController = viewControllers[toIndex]
        viewController.reloadAfterSwipeViewUpdated()
    }
    
    override func swipeView(_ swipeView: SwipeView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // print("did change from item \(fromIndex) to section \(toIndex)")
        viewControllers[fromIndex].viewAppear = false
        viewControllers[toIndex].viewAppear = true
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
