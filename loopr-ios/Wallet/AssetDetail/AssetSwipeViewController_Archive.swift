//
//  AssetSwipeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetSwipeViewController_Archive: SwipeViewController {
    
    var asset: Asset?

    private var viewControllers: [UIViewController] = []
    var options = SwipeViewOptions()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        
        options.swipeTabView.height = 50
        options.swipeTabView.underlineView.height = 1
        options.swipeTabView.underlineView.margin = 0  // 85  // This value is to have a wide underline.
        options.swipeTabView.underlineView.animationDuration = 0.2
        options.swipeTabView.itemView.font = FontConfigManager.shared.getRegularFont()
        options.swipeContentScrollView.isScrollEnabled = false
        
        // TODO: needsAdjustItemViewWidth will trigger expensive computation.
        // options.swipeTabView.needsAdjustItemViewWidth = false
        
        // TODO: .segmented will disable the value of width
        options.swipeTabView.style = .segmented

        let vc0 = AssetDetailViewController()
        vc0.asset = asset
        viewControllers.append(vc0)

        let vc1 = AssetMarketViewController()
        vc1.asset = asset
        viewControllers.append(vc1)

        for viewController in viewControllers {
            self.addChildViewController(viewController)
        }
        
        swipeView.reloadData(options: options)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = asset?.symbol
        // For back button in navigation bar
        setBackButton()
        if let asset = asset, asset.symbol.uppercased() == "ETH" || asset.symbol.uppercased() == "WETH" {
            let convertButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 28))
            convertButton.setupRoundWhite(height: 28)
            convertButton.setTitle(LocalizedString("Convert", comment: ""), for: .normal)
            convertButton.contentHorizontalAlignment = .center
            convertButton.titleColor = UIColor.darkGray
            convertButton.titleLabel?.font = FontConfigManager.shared.getLabelFont(size: 11)
            convertButton.addTarget(self, action: #selector(self.pressedConvertButton(_:)), for: UIControlEvents.touchUpInside)
            let convertBarButtton = UIBarButtonItem(customView: convertButton)
            self.navigationItem.rightBarButtonItem = convertBarButtton
        }
    }
    
    @objc func pressedConvertButton(_ sender: Any) {
        print("pressedConvertButton")
        let viewController = ConvertETHViewController()
        viewController.asset = asset
        self.navigationController?.pushViewController(viewController, animated: true)
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
        return index == 0 ? LocalizedString("Transactions", comment: "") : LocalizedString("Markets", comment: "")
    }
    
    override func swipeView(_ swipeView: SwipeView, viewControllerForPageAt index: Int) -> UIViewController {
        return viewControllers[index]
    }
}
