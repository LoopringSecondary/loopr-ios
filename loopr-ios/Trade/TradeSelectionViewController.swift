//
//  TradeSelectionViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/21/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeSelectionViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    var isViewDidAppear: Bool = false
    
    // It's slow to load MarketSwipeViewController. So make a property to store the instance.
    var marketSwipeViewController: MarketSwipeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor
        
        self.navigationItem.title = LocalizedString("Trade", comment: "")
        
        button1.cornerRadius = 8
        button1.titleLabel?.setSubTitleCharFont()
        button1.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button1.theme_setBackgroundImage(ColorPicker.button, forState: .normal)
        button1.theme_setBackgroundImage(ColorPicker.buttonHighlight, forState: .highlighted)
        button1.addTarget(self, action: #selector(self.pressedButton1(_:)), for: .touchUpInside)
        
        button2.cornerRadius = 8
        button2.titleLabel?.setSubTitleCharFont()
        button2.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button2.theme_setBackgroundImage(ColorPicker.button, forState: .normal)
        button2.theme_setBackgroundImage(ColorPicker.buttonHighlight, forState: .highlighted)
        button2.addTarget(self, action: #selector(self.pressedButton2(_:)), for: .touchUpInside)
        
        button3.cornerRadius = 8
        button3.titleLabel?.setSubTitleCharFont()
        button3.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button3.theme_setBackgroundImage(ColorPicker.button, forState: .normal)
        button3.theme_setBackgroundImage(ColorPicker.buttonHighlight, forState: .highlighted)
        button3.addTarget(self, action: #selector(self.pressedButton3(_:)), for: .touchUpInside)
        
        button4.cornerRadius = 8
        button4.titleLabel?.setSubTitleCharFont()
        button4.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button4.theme_setBackgroundImage(ColorPicker.button, forState: .normal)
        button4.theme_setBackgroundImage(ColorPicker.buttonHighlight, forState: .highlighted)
        button4.addTarget(self, action: #selector(self.pressedButton4(_:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        button1.isUserInteractionEnabled = true
        
        let iconTitlePadding: CGFloat = 14
        button1.set(image: UIImage.init(named: "Trade-decentralizaed-exchange-dark"), title: LocalizedString("DEX Trade", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button1.set(image: UIImage.init(named: "Trade-decentralizaed-exchange-dark")?.alpha(0.6), title: LocalizedString("DEX Trade", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button2.set(image: UIImage.init(named: "Trade-peer-to-peer-dark"), title: "P2P", titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button2.set(image: UIImage.init(named: "Trade-peer-to-peer-dark")?.alpha(0.6), title: "P2P", titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button3.set(image: UIImage.init(named: "Trade-weth-convert-dark"), title: LocalizedString("Convert WETH", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button3.set(image: UIImage.init(named: "Trade-weth-convert-dark")?.alpha(0.6), title: LocalizedString("Convert WETH", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button4.set(image: UIImage.init(named: "dropdown-transaction"), title: LocalizedString("Orders", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button4.set(image: UIImage.init(named: "dropdown-transaction")?.alpha(0.6), title: LocalizedString("Orders", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isViewDidAppear {
            button1.applyShadow(withColor: UIColor.black)
            button2.applyShadow(withColor: UIColor.black)
            button3.applyShadow(withColor: UIColor.black)
            button4.applyShadow(withColor: UIColor.black)
            isViewDidAppear = true

            let start = Date()
            marketSwipeViewController = MarketSwipeViewController()
            marketSwipeViewController!.hidesBottomBarWhenPushed = true
            let end = Date()
            let timeInterval: Double = end.timeIntervalSince(start)
            print("##########Time to generate MarketSwipeViewController: \(timeInterval) seconds############")
        }
    }

    @objc func pressedButton1(_ button: UIButton) {
        print("pressedItem1Button")
        if marketSwipeViewController != nil {
            self.navigationController?.pushViewController(marketSwipeViewController!, animated: true)
        } else {
            let viewController = MarketSwipeViewController(nibName: nil, bundle: nil)
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        button1.isUserInteractionEnabled = false
    }
    
    @objc func pressedButton2(_ button: UIButton) {
        print("pressedItem2Button")
        let viewController = TradeSwipeViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pressedButton3(_ button: UIButton) {
        print("pressedItem3Button")
        let viewController = ConvertETHViewController()
        viewController.asset = CurrentAppWalletDataManager.shared.getAsset(symbol: "ETH")
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func pressedButton4(_ button: UIButton) {
        print("pressedButton4")
        let viewController = OrderHistorySwipeViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
