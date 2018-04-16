//
//  PlaceOrderConfirmationViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class PlaceOrderConfirmationViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var typeTipLabel: UILabel!
    @IBOutlet weak var typeInfoLabel: UILabel!
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var tokenImage: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var confirmationButton: UIButton!
    
    var order: OriginalOrder?
    var type: TradeType = .buy
    var price: String = "0.0"
    var expires: String = "1 Hour"
    
    // Price
    var priceTipLabel: UILabel = UILabel()
    var priceInfoLabel: UILabel = UILabel()
    var priceUnderline: UIView = UIView()
    // Expires
    var expiresTipLabel: UILabel = UILabel()
    var expiresInfoLabel: UILabel = UILabel()
    var expiresUnderline: UIView = UIView()
    // LRC Fee
    var feeTipLabel: UILabel = UILabel()
    var feeInfoLabel: UILabel = UILabel()
    var feeUnderline: UIView = UIView()
    // Margin
    var marginTipLabel: UILabel = UILabel()
    var marginInfoLabel: UILabel = UILabel()
    var marginUnderline: UIView = UIView()
    // Total
    var totalTipLabel: UILabel = UILabel()
    var totalInfoLabel: UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = NSLocalizedString("Confirmation", comment: "")
        confirmationButton.title = NSLocalizedString("Confirmation", comment: "")
        confirmationButton.backgroundColor = UIColor.black
        confirmationButton.layer.cornerRadius = 23
        confirmationButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)

        if let order = self.order {
            initLabels()
            initTokenView(order: order)
            initOrderAmount(order: order)
            initRows(order: order)
        }
    }
    
    func initLabels() {
        typeTipLabel.text = NSLocalizedString("You are ", comment: "")
        typeTipLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 30)
        typeTipLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        typeInfoLabel.text = (type == .buy ? NSLocalizedString("buying", comment: "") : NSLocalizedString("selling", comment: ""))
        typeInfoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 30)
        typeInfoLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    }
    
    func initTokenView(order: OriginalOrder) {
        if order.side.lowercased() == "buy" {
            if let icon = UIImage(named: order.tokenB) {
                tokenImage.image = icon
                tokenImage.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = order.tokenB
                iconView.symbolLabel.text = order.tokenB
                tokenImage.isHidden = true
            }
        } else if order.side.lowercased() == "sell" {
            if let icon = UIImage(named: order.tokenS) {
                tokenImage.image = icon
                tokenImage.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = order.tokenS
                iconView.symbolLabel.text = order.tokenS
                tokenImage.isHidden = true
            }
        }
    }
    
    func initOrderAmount(order: OriginalOrder) {
        if order.side.lowercased() == "sell" {
            amountLabel.text = order.amountSell.description + " " + order.tokenS
            if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: order.tokenS) {
                displayLabel.text = "$ " + (price * order.amountSell).description // TODO: $
            }
        } else if order.side.lowercased() == "buy" {
            amountLabel.text = order.amountBuy.description + " " + order.tokenB
            if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: order.tokenB) {
                displayLabel.text = "$ " + (price * order.amountBuy).description // TODO: $
            }
        }
        amountLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 40)
        amountLabel.textColor = Themes.isNight() ? UIColor.white : UIColor.black
        displayLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 20)
        displayLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    }
    
    func initRows(order: OriginalOrder) {
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let padding: CGFloat = 15
        // 1st row: price
        priceTipLabel.font = FontConfigManager.shared.getLabelFont()
        priceTipLabel.text = NSLocalizedString("Price", comment: "")
        priceTipLabel.frame = CGRect(x: padding, y: padding, width: 150, height: 40)
        scrollView.addSubview(priceTipLabel)
        priceInfoLabel.font = FontConfigManager.shared.getLabelFont()
        priceInfoLabel.text = self.price + " " + PlaceOrderDataManager.shared.getPairDescription()
        priceInfoLabel.textAlignment = .right
        priceInfoLabel.frame = CGRect(x: padding + 150, y: priceTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(priceInfoLabel)
        priceUnderline.frame = CGRect(x: padding, y: priceTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        priceUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(priceUnderline)
        
        // 2nd row: expires
        expiresTipLabel.font = FontConfigManager.shared.getLabelFont()
        expiresTipLabel.text = NSLocalizedString("Order Expires in", comment: "")
        expiresTipLabel.frame = CGRect(x: padding, y: priceTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(expiresTipLabel)
        expiresInfoLabel.font = FontConfigManager.shared.getLabelFont()
        expiresInfoLabel.text = self.expires
        expiresInfoLabel.textAlignment = .right
        expiresInfoLabel.frame = CGRect(x: padding + 150, y: expiresTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(expiresInfoLabel)
        expiresUnderline.frame = CGRect(x: padding, y: expiresTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        expiresUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(expiresUnderline)
        
        // 3rd row: lrc fee
        feeTipLabel.font = FontConfigManager.shared.getLabelFont()
        feeTipLabel.text = NSLocalizedString("LRC Fee", comment: "")
        feeTipLabel.frame = CGRect(x: padding, y: expiresTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(feeTipLabel)
        feeInfoLabel.font = FontConfigManager.shared.getLabelFont()
        if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: "LRC") {
            let display = order.lrcFee * price
            feeInfoLabel.text = order.lrcFee.description + "LRC (≈$\(display))"
        }
        feeInfoLabel.textAlignment = .right
        feeInfoLabel.frame = CGRect(x: padding + 150, y: feeTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(feeInfoLabel)
        feeUnderline.frame = CGRect(x: padding, y: feeTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        feeUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(feeUnderline)
        
        // 4th row: margin split
        marginTipLabel.font = FontConfigManager.shared.getLabelFont()
        marginTipLabel.text = NSLocalizedString("Margin Split", comment: "")
        marginTipLabel.frame = CGRect(x: padding, y: feeTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(marginTipLabel)
        marginInfoLabel.font = FontConfigManager.shared.getLabelFont()
        marginInfoLabel.text = order.marginSplitPercentage
        marginInfoLabel.textAlignment = .right
        marginInfoLabel.frame = CGRect(x: padding + 150, y: marginTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(marginInfoLabel)
        marginUnderline.frame = CGRect(x: padding, y: marginTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        marginUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(marginUnderline)
        
        // 5th row: total
        totalTipLabel.font = FontConfigManager.shared.getLabelFont()
        totalTipLabel.text = NSLocalizedString("Total", comment: "")
        totalTipLabel.frame = CGRect(x: padding, y: marginTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(totalTipLabel)
        totalInfoLabel.font = FontConfigManager.shared.getLabelFont()
        totalInfoLabel.text = (order.side.lowercased() == "buy" ? order.amountBuy.description + " " + order.tokenB : order.amountSell.description + " " + order.tokenS)
        totalInfoLabel.textAlignment = .right
        totalInfoLabel.frame = CGRect(x: padding + 150, y: totalTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(totalInfoLabel)
        
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: screenWidth, height: totalTipLabel.frame.maxY + padding)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedConfirmationButton(_ sender: Any) {
        print("pressedConfirmationButton")
        
        let viewController = ConfirmationResultViewController()
        viewController.order = self.order
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
