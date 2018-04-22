//
//  UnlockWalletSwipeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class UnlockWalletSwipeViewController: SwipeViewController {

    private var types: [UnlockWalletType] = [.mnemonic, .keystore, .privateKey]
    private var viewControllers: [UIViewController] = [MnemonicViewController(), UnlockKeystoreViewController(), PrivateKeyViewController()]
    var options = SwipeViewOptions()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Unlock Wallet", comment: "")
        setBackButton()
        
        self.navigationController?.isNavigationBarHidden = false
        
        options.swipeTabView.height = 44
        options.swipeTabView.underlineView.height = 1
        options.swipeTabView.underlineView.margin = 30

        options.swipeTabView.style = .segmented

        options.swipeTabView.itemView.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 21) ?? UIFont.systemFont(ofSize: 21)

        swipeView.reloadData(options: options)
        
        let button = UIBarButtonItem(image: UIImage.init(named: "Scan"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.pressScanButton(_:)))
        self.navigationItem.rightBarButtonItem = button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc func pressScanButton(_ button: UIBarButtonItem) {
        print("pressScanButton")
        let viewController = ScanQRCodeViewController()
        viewController.hidesBottomBarWhenPushed = true
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
    
    // MARK: DataSource
    override func numberOfPages(in swipeView: SwipeView) -> Int {
        return types.count
    }
    
    override func swipeView(_ swipeView: SwipeView, titleForPageAt index: Int) -> String {
        return types[index].description
    }
    
    override func swipeView(_ swipeView: SwipeView, viewControllerForPageAt index: Int) -> UIViewController {
        var viewController: UIViewController
        let type = types[index]

        switch type {
        case .mnemonic:
            viewController = viewControllers[0]
        case .keystore:
            viewController = viewControllers[1]
        case .privateKey:
            viewController = viewControllers[2]
        }

        self.addChildViewController(viewController)
        return viewController
    }

}
