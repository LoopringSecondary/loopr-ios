//
//  OrderDetailViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/12.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var tokenS: UIView!
    @IBOutlet weak var tokenB: UIView!
    @IBOutlet weak var arrowRightImageView: UIImageView!
    @IBOutlet weak var statusTipLabel: UILabel!
    @IBOutlet weak var statusInfoLabel: UILabel!
    @IBOutlet weak var amountTipLabel: UILabel!
    @IBOutlet weak var amountInfoLabel: UILabel!
    @IBOutlet weak var filledTipLabel: UILabel!
    @IBOutlet weak var filledInfoLabel: UILabel!
    @IBOutlet weak var idTipLabel: UILabel!
    @IBOutlet weak var idInfoLabel: UILabel!
    @IBOutlet weak var dateTipLabel: UILabel!
    @IBOutlet weak var dateInfoLabel: UILabel!
    @IBOutlet weak var totalMaskView: UIView!
    
    var order: Order?
    
    var tokenSView: TradeTokenView!
    var tokenBView: TradeTokenView!
    
    var marketLabel: UILabel = UILabel()
    var typeLabel: UILabel = UILabel()
    var qrcodeImageView: UIImageView!
    var qrcodeImage: UIImage!
    var amountLabel: UILabel = UILabel()
    var displayLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Order Detail", comment: "")
        setBackButton()
        setupQRCodeButton()
        
        tokenSView = TradeTokenView(frame: tokenS.frame)
        view.addSubview(tokenSView)
        tokenBView = TradeTokenView(frame: tokenB.frame)
        view.addSubview(tokenBView)
        view.bringSubview(toFront: totalMaskView)
        
        statusTipLabel.setTitleCharFont()
        statusTipLabel.text = LocalizedString("Status", comment: "")
        statusInfoLabel.setTitleDigitFont()
        statusInfoLabel.text = order?.orderStatus.description
        
        amountTipLabel.setTitleCharFont()
        amountTipLabel.text = LocalizedString("Price", comment: "")
        amountInfoLabel.setTitleDigitFont()
        
        filledTipLabel.setTitleCharFont()
        filledTipLabel.text = LocalizedString("Filled", comment: "")
        filledInfoLabel.setTitleDigitFont()
        
        idTipLabel.setTitleCharFont()
        idTipLabel.text = LocalizedString("ID", comment: "")
        idInfoLabel.setTitleDigitFont()
        idInfoLabel.text = order?.originalOrder.hash
        
        dateTipLabel.setTitleCharFont()
        dateTipLabel.text = LocalizedString("Time", comment: "")
        dateInfoLabel.setTitleDigitFont()
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupQRCodeButton() {
        guard order?.originalOrder.orderType == .p2pOrder && order?.orderStatus == .opened else {
            return
        }
        let qrCodebutton = UIButton(type: UIButtonType.custom)
        // TODO: smaller images.
        qrCodebutton.theme_setImage(["QRCode-black", "QRCode-white"], forState: UIControlState.normal)
        qrCodebutton.setImage(UIImage(named: "QRCode-black")?.alpha(0.3), for: .highlighted)
        qrCodebutton.addTarget(self, action: #selector(self.pressQRCodeButton(_:)), for: UIControlEvents.touchUpInside)
        qrCodebutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let qrCodeBarButton = UIBarButtonItem(customView: qrCodebutton)
        self.navigationItem.rightBarButtonItem = qrCodeBarButton
    }
    
    @objc func pressQRCodeButton(_ sender: UIButton) {
        if let order = self.order {
            self.totalMaskView.alpha = 0.75
            let vc = OrderQRCodeViewController()
            vc.order = order.originalOrder
            vc.dismissClosure = {
                self.totalMaskView.alpha = 0
            }
            vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func setup() {
        guard let order = self.order else { return }
        setupTokenViews(order: order)
        setupOrderFilled(order: order)
        setupOrderAmount(order: order)
        setupOrderDate(order: order)
    }
    
    func setupTokenViews(order: Order) {
        let originOrder = order.originalOrder
        tokenBView.update(type: .buy, symbol: originOrder.tokenBuy, amount: originOrder.amountBuy)
        tokenSView.update(type: .sell, symbol: originOrder.tokenSell, amount: originOrder.amountSell)
    }
    
    func setupOrderFilled(order: Order) {
        var percent: Double = 0.0
        if order.originalOrder.side.lowercased() == "sell" {
            percent = order.dealtAmountS / order.originalOrder.amountSell
        } else if order.originalOrder.side.lowercased() == "buy" {
            percent = order.dealtAmountB / order.originalOrder.amountBuy
        }
        filledInfoLabel.text = (percent * 100).rounded().description + "%"
    }
    
    func setupOrderAmount(order: Order) {
        var price: Double = 0
        var unit: String = ""
        if order.originalOrder.side.lowercased() == "sell" {
            price = order.originalOrder.amountSell / order.originalOrder.amountBuy
            unit = "\(order.originalOrder.tokenSell) / \(order.originalOrder.tokenBuy)"
        } else if order.originalOrder.side.lowercased() == "buy" {
            price = order.originalOrder.amountBuy / order.originalOrder.amountSell
            unit = "\(order.originalOrder.tokenBuy) / \(order.originalOrder.tokenSell)"
        }
        amountInfoLabel.text = "\(price.withCommas()) \(unit)"
    }
    
    func setupOrderDate(order: Order) {
        let originOrder = order.originalOrder
        let since = DateUtil.convertToDate(UInt(originOrder.validSince), format: "MM-dd HH:mm")
        let until = DateUtil.convertToDate(UInt(originOrder.validUntil), format: "MM-dd HH:mm")
        dateInfoLabel.text = "\(since) ~ \(until)"
    }
}
