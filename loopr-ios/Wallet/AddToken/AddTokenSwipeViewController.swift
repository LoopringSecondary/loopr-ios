//
//  AddTokenSwipeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AddTokenSwipeViewController: SwipeViewController {

    private var types: [String] = [LocalizedString("Select Tokens", comment: ""), LocalizedString("Custom Token", comment: "")]
    
    private var vc1 = AddTokenViewController()
    private var vc2 = AddCustomizedTokenViewController()
    private var viewControllers: [UIViewController] = []
    
    var options = SwipeViewOptions.getDefault()
    
    var searchButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Tokens", comment: "")
        SendCurrentAppWalletDataManager.shared.getNonceFromEthereum()
        setBackButton()
        setupChildViewControllers()
        
        searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.pressOrderSearchButton(_:)))
        self.navigationItem.rightBarButtonItems = [searchButton]
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
        swipeView.reloadData(options: options, default: swipeView.currentIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupChildViewControllers() {
        viewControllers = [vc1, vc2]
        for viewController in viewControllers {
            self.addChildViewController(viewController)
        }
        swipeView.reloadData(options: options)
    }
    
    @objc func pressOrderSearchButton(_ button: UIBarButtonItem) {
        
    }
    
    // MARK: - Delegate
    override func swipeView(_ swipeView: SwipeView, viewWillSetupAt currentIndex: Int) {
    }
    
    override func swipeView(_ swipeView: SwipeView, viewDidSetupAt currentIndex: Int) {
    }
    
    override func swipeView(_ swipeView: SwipeView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        if toIndex == 0 {
            vc2.addressTextField.resignFirstResponder()
            vc2.symbolTextField.resignFirstResponder()
            vc2.decimalTextField.resignFirstResponder()
            self.navigationItem.rightBarButtonItems = [searchButton]
        } else {
            self.navigationItem.rightBarButtonItems = []
        }
    }
    
    override func swipeView(_ swipeView: SwipeView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
    }
    
    // MARK: - DataSource
    override func numberOfPages(in swipeView: SwipeView) -> Int {
        return viewControllers.count
    }
    
    override func swipeView(_ swipeView: SwipeView, titleForPageAt index: Int) -> String {
        return types[index]
    }
    
    override func swipeView(_ swipeView: SwipeView, viewControllerForPageAt index: Int) -> UIViewController {
        return viewControllers[index]
    }
}
