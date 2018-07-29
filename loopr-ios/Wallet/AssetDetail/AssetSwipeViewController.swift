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
    var baseView: UIImageView = UIImageView()
    let balanceLabel: UILabel = UILabel()
    let currencyLabel: UILabel = UILabel()
    
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = asset?.symbol
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        self.topConstraint = 140
        self.bottomConstraint = -60
        setBackButton()
        setupChildViewControllers()
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        baseView.frame = CGRect(x: 10, y: 10, width: screenWidth - 20, height: 120)
        baseView.image = UIImage(named: "Header-plain")
        baseView.contentMode = .scaleToFill
        view.addSubview(baseView)
        
        balanceLabel.frame = CGRect(x: 10, y: 40, width: screenWidth - 20, height: 36)
        balanceLabel.setHeaderDigitFont()
        balanceLabel.textAlignment = .center
        balanceLabel.text = asset?.display
        view.addSubview(balanceLabel)
        
        currencyLabel.frame = CGRect(x: 10, y: balanceLabel.frame.maxY, width: screenWidth - 20, height: 30)
        currencyLabel.setTitleDigitFont()
        currencyLabel.textAlignment = .center
        currencyLabel.text = asset?.currency
        view.addSubview(currencyLabel)
        
        // Receive button
        receiveButton.setTitle(LocalizedString("Receive", comment: "") + " " + (asset?.symbol ?? ""), for: .normal)
        receiveButton.setupSecondary(height: 44, gradientOrientation: .horizontal)
        
        // Send button
        sendButton.setTitle(LocalizedString("Send", comment: "") + " " + (asset?.symbol ?? ""), for: .normal)
        sendButton.setupSecondary(height: 44, gradientOrientation: .horizontal)
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
        options.swipeTabView.underlineView.height = 2
        swipeView.reloadData(options: options, default: swipeView.currentIndex)
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
        options.swipeTabView.itemView.font = FontConfigManager.shared.getCharactorFont()
        options.swipeContentScrollView.isScrollEnabled = false
        options.swipeTabView.style = .segmented
        swipeView.reloadData(options: options)
    }

    @IBAction func pressedReceiveButton(_ sender: Any) {
        print("pressedReceiveButton")
        let viewController = QRCodeViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func pressedSendButton(_ sender: Any) {
        print("pressedSendButton")
        let viewController = SendAssetViewController()
        viewController.asset = self.asset!
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Delegate
    override func swipeView(_ swipeView: SwipeView, viewWillSetupAt currentIndex: Int) {
    }
    
    override func swipeView(_ swipeView: SwipeView, viewDidSetupAt currentIndex: Int) {
    }
    
    override func swipeView(_ swipeView: SwipeView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        type = types[toIndex]
        let viewController = viewControllers[toIndex]
        viewController.reloadAfterSwipeViewUpdated()
    }
    
    override func swipeView(_ swipeView: SwipeView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
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
