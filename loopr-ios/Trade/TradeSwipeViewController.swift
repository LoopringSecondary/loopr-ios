//
//  AssetSwipeViewController.swift
//  loopr-ios
//
//  Created by 王忱 on 2018/7/19.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class TradeSwipeViewController: SwipeViewController, QRCodeScanProtocol {
    
    private var type: TradeSwipeType = .trade
    private var types: [TradeSwipeType] = []
    
    private var viewControllers: [UIViewController] = []
    
    var options = SwipeViewOptions.getDefault()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor
        navigationItem.title = LocalizedString("P2P Trade", comment: "")
        setBackButton()
        setNavigationBarItem()
        setupChildViewControllers()
        
        // Get the updated nonce
        CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.getNonceFromEthereum(completionHandler: {})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Themes.isDark() {
            options.swipeTabView.itemView.textColor = UIColor(rgba: "#ffffff66")
            options.swipeTabView.itemView.selectedTextColor = UIColor(rgba: "#ffffffcc")
        } else {
            options.swipeTabView.itemView.textColor = UIColor(rgba: "#00000099")
            options.swipeTabView.itemView.selectedTextColor = UIColor(rgba: "#000000cc")
        }
        swipeView.reloadData(options: options, default: swipeView.currentIndex)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNavigationBarItem() {
        let icon = UIImage.init(named: "dropdown-scan")
        let button = UIBarButtonItem(image: icon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.pressedScanButton))
        self.navigationItem.rightBarButtonItem = button
    }
    
    @objc func pressedScanButton() {
        let viewController = ScanQRCodeViewController()
        // TODO: do we need to support these types
        viewController.expectedQRCodeTypes = [.submitOrder, .login, .cancelOrder, .convert, .approve, .p2pOrder, .address]
        viewController.delegate = self
        viewController.shouldPop = false
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setupChildViewControllers() {
        types = [.trade, .records]
        viewControllers.insert(TradeViewController(), at: 0)
        viewControllers.insert(P2POrderHistoryViewController(), at: 1)
        for viewController in viewControllers {
            self.addChildViewController(viewController)
        }
        swipeView.reloadData(options: options)
    }
    
    // MARK: - Delegate
    override func swipeView(_ swipeView: SwipeView, viewWillSetupAt currentIndex: Int) {
    }
    
    override func swipeView(_ swipeView: SwipeView, viewDidSetupAt currentIndex: Int) {
    }
    
    override func swipeView(_ swipeView: SwipeView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        type = types[toIndex]
    }
    
    override func swipeView(_ swipeView: SwipeView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
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
    
    // Copy code from WalletViewController.
    func setResultOfScanningQRCode(valueSent: String, type: QRCodeType) {
        let manager = AuthorizeDataManager.shared
        if let data = valueSent.data(using: .utf8) {
            let json = JSON(data)
            switch type {
            case .submitOrder:
                manager.submitHash = json["value"].stringValue
                manager.getSubmitOrder { (_, error) in
                    guard error == nil, let order = manager.submitOrder else { return }
                    DispatchQueue.main.async {
                        let vc = PlaceOrderConfirmationViewController()
                        vc.view.theme_backgroundColor = ColorPicker.backgroundColor
                        vc.order = order
                        vc.isSigning = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .login:
                manager.loginUUID = json["value"].stringValue
                manager._authorizeLogin { (_, error) in
                    let result = error == nil ? true : false
                    DispatchQueue.main.async {
                        let vc = LoginResultViewController()
                        vc.result = result
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .cancelOrder:
                manager.cancelHash = json["value"].stringValue
                manager.getCancelOrder { (_, error) in
                    let result = error == nil ? true : false
                    DispatchQueue.main.async {
                        let vc = LoginResultViewController()
                        vc.result = result
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .convert:
                manager.convertHash = json["value"].stringValue
                manager.getConvertTx { (_, error) in
                    let result = error == nil ? true : false
                    DispatchQueue.main.async {
                        let vc = LoginResultViewController()
                        vc.result = result
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            case .approve:
                manager.approveHash = json["value"].stringValue
                manager.getApproveTxs { (_, error) in
                    let result = error == nil ? true : false
                    DispatchQueue.main.async {
                        let vc = LoginResultViewController()
                        vc.result = result
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .p2pOrder:
                TradeDataManager.shared.handleResult(of: json["value"])
                let vc = TradeConfirmationViewController()
                vc.view.theme_backgroundColor = ColorPicker.backgroundColor
                vc.parentNavController = self.navigationController
                vc.order = TradeDataManager.shared.orders[1]
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .address:
                let vc = SendAssetViewController()
                vc.address = valueSent
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .keystore, .mnemonic, .privateKey:
                let vc = UnlockWalletSwipeViewController()
                vc.hidesBottomBarWhenPushed = true
                vc.setResultOfScanningQRCode(valueSent: valueSent, type: type)
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                return
            }
        }
    }

}
