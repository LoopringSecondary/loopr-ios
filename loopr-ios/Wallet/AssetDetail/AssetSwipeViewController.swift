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
    private var types: [TxSwipeViewType] = [.all]
    private var viewControllers: [AssetDetailViewController] = []
    
    var asset: Asset?
    var options = SwipeViewOptions.getDefault()
    var baseView: UIImageView = UIImageView(frame: .zero)
    let balanceLabel: UILabel = UILabel(frame: .zero)
    let currencyLabel: UILabel = UILabel(frame: .zero)
    
    @IBOutlet weak var receiveButton: GradientButton!
    @IBOutlet weak var sendButton: GradientButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = asset?.symbol
        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.topConstraint = 140
        self.bottomConstraint = -54
        options.swipeTabView.height = 0
        
        setBackButton()
        setupChildViewControllers()
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        baseView.frame = CGRect(x: 15, y: 10, width: screenWidth - 30, height: 120)
        baseView.image = UIImage(named: "wallet-selected-background" + ColorTheme.getTheme())
        baseView.contentMode = .scaleToFill
        view.addSubview(baseView)
        
        balanceLabel.frame = CGRect(x: 10, y: 40, width: screenWidth - 20, height: 36)
        balanceLabel.font = FontConfigManager.shared.getMediumFont(size: 32)
        balanceLabel.textColor = UIColor.white
        balanceLabel.textAlignment = .center
        balanceLabel.text = asset?.display
        view.addSubview(balanceLabel)
        
        currencyLabel.frame = CGRect(x: 10, y: balanceLabel.frame.maxY, width: screenWidth - 20, height: 30)
        currencyLabel.font = FontConfigManager.shared.getRegularFont(size: 20)
        currencyLabel.textColor = UIColor.init(rgba: "#ffffffcc")
        currencyLabel.textAlignment = .center
        currencyLabel.text = asset?.currency
        view.addSubview(currencyLabel)
        
        // Receive & Send button
        receiveButton.setTitle(LocalizedString("Receive", comment: "") + " " + (asset?.symbol ?? ""), for: .normal)
        sendButton.setTitle(LocalizedString("Send", comment: "") + " " + (asset?.symbol ?? ""), for: .normal)

        if ColorTheme.current == .green {
            sendButton.setPrimaryColor()
        } else {
            receiveButton.setPrimaryColor()
        }
        
        if Themes.isDark() {
            options.swipeTabView.itemView.textColor = UIColor(rgba: "#ffffff66")
            options.swipeTabView.itemView.selectedTextColor = UIColor(rgba: "#ffffffcc")
        } else {
            options.swipeTabView.itemView.textColor = UIColor(rgba: "#00000099")
            options.swipeTabView.itemView.selectedTextColor = UIColor(rgba: "#000000cc")
        }
        swipeView.reloadData(options: options, default: swipeView.currentIndex)
        
        if asset?.symbol == "ETH" || asset?.symbol == "WETH" {
            let convertButon = UIBarButtonItem(title: LocalizedString("Convert", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(pressedConvertButton))
            convertButon.setTitleTextAttributes([NSAttributedStringKey.font: FontConfigManager.shared.getCharactorFont(size: 14)], for: .normal)
            self.navigationItem.rightBarButtonItem = convertButon
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupChildViewControllers() {
        for (index, type) in types.enumerated() {
            let vc = AssetDetailViewController(type: type)
            vc.asset = self.asset
            viewControllers.insert(vc, at: index)
        }
        for viewController in viewControllers {
            self.addChildViewController(viewController)
        }
        swipeView.reloadData(options: options)
    }
    
    @objc func pressedConvertButton() {
        let viewController = ConvertETHViewController()
        viewController.asset = CurrentAppWalletDataManager.shared.getAsset(symbol: asset!.symbol)
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func pressedReceiveButton(_ sender: Any) {
        print("pressedReceiveButton")
        let viewController = QRCodeViewController()
        viewController.hidesBottomBarWhenPushed = true
        viewController.address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func pressedSendButton(_ sender: Any) {
        print("pressedSendButton")
        let viewController = SendAssetViewController()
        viewController.asset = self.asset!
        SendCurrentAppWalletDataManager.shared.token = TokenDataManager.shared.getTokenBySymbol(self.asset!.symbol)
        self.navigationController?.pushViewController(viewController, animated: true)
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

}
