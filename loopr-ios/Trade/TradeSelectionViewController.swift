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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        self.navigationItem.title = LocalizedString("Trade", comment: "")
        
        let iconTitlePadding: CGFloat = 14
        
        button1.cornerRadius = 8
        button1.titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 14)
        button1.titleLabel?.theme_textColor = ["#000000cc", "#ffffffcc"]
        button1.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button1.theme_setBackgroundImage(GlobalPicker.button, forState: .normal)
        button1.theme_setBackgroundImage(GlobalPicker.buttonHighlight, forState: .highlighted)
        button1.addTarget(self, action: #selector(self.pressedButton1(_:)), for: .touchUpInside)
        button1.set(image: UIImage.init(named: "Trade-decentralizaed-exchange-dark"), title: LocalizedString("Decentralized Exchange", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button1.set(image: UIImage.init(named: "Trade-decentralizaed-exchange-dark")?.alpha(0.6), title: LocalizedString("Decentralized Exchange", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button2.cornerRadius = 8
        button2.titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 14)
        button2.titleLabel?.theme_textColor = ["#000000cc", "#ffffffcc"]
        button2.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button2.theme_setBackgroundImage(GlobalPicker.button, forState: .normal)
        button2.theme_setBackgroundImage(GlobalPicker.buttonHighlight, forState: .highlighted)
        button2.addTarget(self, action: #selector(self.pressedButton2(_:)), for: .touchUpInside)
        button2.set(image: UIImage.init(named: "Trade-peer-to-peer-dark"), title: LocalizedString("Peer to Peer", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button2.set(image: UIImage.init(named: "Trade-peer-to-peer-dark")?.alpha(0.6), title: LocalizedString("Peer to Peer", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button3.cornerRadius = 8
        button3.titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 14)
        button3.titleLabel?.theme_textColor = ["#000000cc", "#ffffffcc"]
        button3.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button3.theme_setBackgroundImage(GlobalPicker.button, forState: .normal)
        button3.theme_setBackgroundImage(GlobalPicker.buttonHighlight, forState: .highlighted)
        button3.addTarget(self, action: #selector(self.pressedButton3(_:)), for: .touchUpInside)
        button3.set(image: UIImage.init(named: "Trade-weth-convert-dark"), title: LocalizedString("WETH Convert", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button3.set(image: UIImage.init(named: "Trade-weth-convert-dark")?.alpha(0.6), title: LocalizedString("WETH Convert", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
        
        button4.cornerRadius = 8
        button4.titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 14)
        button4.titleLabel?.theme_textColor = ["#000000cc", "#ffffffcc"]
        button4.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        button4.theme_setBackgroundImage(GlobalPicker.button, forState: .normal)
        button4.theme_setBackgroundImage(GlobalPicker.buttonHighlight, forState: .highlighted)
        button4.addTarget(self, action: #selector(self.pressedButton4(_:)), for: .touchUpInside)
        button4.set(image: UIImage.init(named: "Trade-scan-code-receipt-dark"), title: LocalizedString("Scan Code Receipt", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .normal)
        button4.set(image: UIImage.init(named: "Trade-scan-code-receipt-dark")?.alpha(0.6), title: LocalizedString("Scan Code Receipt", comment: ""), titlePosition: .bottom, additionalSpacing: iconTitlePadding, state: .highlighted)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func pressedButton1(_ button: UIButton) {
        print("pressedItem1Button")
        let viewController = MarketSwipeViewController(nibName: nil, bundle: nil)
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pressedButton2(_ button: UIButton) {
        print("pressedItem2Button")
        let viewController = TradeViewController()
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
        print("pressedItem4Button")
        let viewController = ScanQRCodeViewController()
        viewController.shouldPop = false
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
