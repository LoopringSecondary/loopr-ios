//
//  ExportKeystoreSwipeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class ExportKeystoreSwipeViewController: SwipeViewController {
    
    var keystore: String = ""

    private var viewControllers: [UIViewController] = []
    var options = SwipeViewOptions()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = LocalizedString("Export Keystore", comment: "")
        setBackButton()

        let displayKeystoreViewController = DisplayKeystoreViewController()
        displayKeystoreViewController.keystore = keystore
        
        let displayKeystoreInQRCodeViewController = DisplayKeystoreInQRCodeViewController()
        displayKeystoreInQRCodeViewController.keystore = keystore
        
        viewControllers = [displayKeystoreViewController, displayKeystoreInQRCodeViewController]

        options.swipeTabView.height = 44
        options.swipeTabView.underlineView.height = 1
        options.swipeTabView.underlineView.margin = 85
        
        options.swipeTabView.style = .segmented
        options.swipeTabView.itemView.font = FontConfigManager.shared.getRegularFont()
        
        swipeView.reloadData(options: options)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: DataSource
    override func numberOfPages(in swipeView: SwipeView) -> Int {
        return viewControllers.count
    }
    
    override func swipeView(_ swipeView: SwipeView, titleForPageAt index: Int) -> String {
        if index == 0 {
            return "Keystore"
        } else {
            return LocalizedString("QR Code", comment: "")
        }
    }
    
    override func swipeView(_ swipeView: SwipeView, viewControllerForPageAt index: Int) -> UIViewController {
        var viewController: UIViewController

        if index == 0 {
            viewController = viewControllers[0]
        } else {
            viewController = viewControllers[1]
        }
        
        self.addChildViewController(viewController)
        return viewController
    }
}
