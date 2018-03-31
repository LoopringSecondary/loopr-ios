//
//  TradeConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeReviewViewController: UIViewController {

    @IBOutlet weak var placeOrderButton: UIButton!
    
    var tokenSView: TradeTokenView!
    var tokenBView: TradeTokenView!
    var arrowRightImageView: UIImageView = UIImageView()

    // TODO: put the following UILabel and UIView to a UIView?
    var marginSplitLabel: UILabel = UILabel()
    var marginSplitValueLabel: UILabel = UILabel()

    var LRCFeeLabel: UILabel = UILabel()
    var LRCFeeValueLabel: UILabel = UILabel()
    var LRCFeeUnderLine: UIView = UIView()

    var priceLabel: UILabel = UILabel()
    var priceValueLabel: UILabel = UILabel()
    var priceUnderLine: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationController?.isNavigationBarHidden = false
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        // TODO: Review or Confirmation?
        self.navigationItem.title = NSLocalizedString("Review", comment: "")
        
        placeOrderButton.title = NSLocalizedString("Place Order", comment: "")
        placeOrderButton.backgroundColor = UIColor.black
        placeOrderButton.layer.cornerRadius = 23
        placeOrderButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        
        let originY: CGFloat = 60
        let paddingLeft: CGFloat = 15
        let paddingTop: CGFloat = 50

        marginSplitLabel.text = "Margin Split"
        marginSplitLabel.textColor = UIColor.black
        marginSplitLabel.font = FontConfigManager.shared.getLabelFont()
        marginSplitLabel.frame = CGRect(x: paddingLeft, y: placeOrderButton.frame.minY - paddingTop - originY - 10, width: 160, height: 40)
        view.addSubview(marginSplitLabel)

        marginSplitValueLabel.textColor = UIColor.black
        marginSplitValueLabel.textAlignment = .right
        marginSplitValueLabel.font = FontConfigManager.shared.getLabelFont()
        marginSplitValueLabel.frame = CGRect(x: screenWidth - paddingLeft - 160, y: placeOrderButton.frame.minY - paddingTop - originY - 10, width: 160, height: 40)
        view.addSubview(marginSplitValueLabel)
        
        LRCFeeLabel.text = "LRC Fee"
        LRCFeeLabel.textColor = UIColor.black
        LRCFeeLabel.font = FontConfigManager.shared.getLabelFont()
        LRCFeeLabel.frame = CGRect(x: paddingLeft, y: marginSplitLabel.frame.minY - paddingTop, width: 160, height: 40)
        view.addSubview(LRCFeeLabel)

        LRCFeeValueLabel.textColor = UIColor.black
        LRCFeeValueLabel.textAlignment = .right
        LRCFeeValueLabel.font = FontConfigManager.shared.getLabelFont()
        LRCFeeValueLabel.frame = CGRect(x: screenWidth - paddingLeft - 160, y: marginSplitLabel.frame.minY - paddingTop, width: 160, height: 40)
        view.addSubview(LRCFeeValueLabel)
        
        LRCFeeUnderLine.frame = CGRect(x: paddingLeft, y: LRCFeeLabel.frame.maxY - 5, width: screenWidth - paddingLeft * 2, height: 1)
        LRCFeeUnderLine.backgroundColor = UIColor.black
        view.addSubview(LRCFeeUnderLine)
        
        priceLabel.text = "Price"
        priceLabel.textColor = UIColor.black
        priceLabel.font = FontConfigManager.shared.getLabelFont()
        priceLabel.frame = CGRect(x: paddingLeft, y: LRCFeeLabel.frame.minY - paddingTop, width: 160, height: 40)
        view.addSubview(priceLabel)

        priceValueLabel.textColor = UIColor.black
        priceValueLabel.textAlignment = .right
        priceValueLabel.font = FontConfigManager.shared.getLabelFont()
        priceValueLabel.frame = CGRect(x: screenWidth - paddingLeft - 200, y: LRCFeeLabel.frame.minY - paddingTop, width: 200, height: 40)
        view.addSubview(priceValueLabel)

        priceUnderLine.frame = CGRect(x: paddingLeft, y: priceLabel.frame.maxY - 5, width: screenWidth - paddingLeft * 2, height: 1)
        priceUnderLine.backgroundColor = UIColor.black
        view.addSubview(priceUnderLine)

        tokenSView = TradeTokenView(frame: CGRect(x: 10, y: screenHeight/9, width: (screenWidth-30)/2, height: 200))
        view.addSubview(tokenSView)

        tokenBView = TradeTokenView(frame: CGRect(x: (screenWidth+10)/2, y: screenHeight/9, width: (screenWidth-30)/2, height: 200))
        view.addSubview(tokenBView)
        
        arrowRightImageView = UIImageView(frame: CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY), size: CGSize(width: 32, height: 32)))
        arrowRightImageView.image = UIImage.init(named: "Arrow-right-black")
        view.addSubview(arrowRightImageView)
        
        // TODO: Use mock data for now.
        marginSplitValueLabel.text = "3.4%"
        LRCFeeValueLabel.text = "2 LRC"
        // priceValueLabel.text = "0.0047142 LRC/BNB"
        // tokenSView.update(title: "You send", symbol: "LRC", amount: 10.232591)
        // tokenBView.update(title: "You get", symbol: "ETH", amount: 3010.33111)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.navigationController?.isNavigationBarHidden = false

        tokenSView.update(title: "You send", symbol: TradeDataManager.shared.tokenS.symbol, amount: TradeDataManager.shared.amountTokenS)
        tokenBView.update(title: "You get", symbol: TradeDataManager.shared.tokenB.symbol, amount: TradeDataManager.shared.amountTokenB)
        
        // TODO: the precision should be dynamic
        let price: String = String(format: "%.6f", TradeDataManager.shared.amountTokenS / TradeDataManager.shared.amountTokenB)
        priceValueLabel.text = "\(price) \(TradeDataManager.shared.tokenS.symbol)/\(TradeDataManager.shared.tokenB.symbol)"
    }

    @IBAction func pressedPlaceOrderButton(_ sender: Any) {
        print("pressedPlaceOrderButton")
        
        let viewController = TradeConfirmationViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
