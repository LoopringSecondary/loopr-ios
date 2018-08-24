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
    @IBOutlet weak var lrcFeeTipLabel: UILabel!
    @IBOutlet weak var lrcFeeInfoLabel: UILabel!
    @IBOutlet weak var filledTipLabel: UILabel!
    @IBOutlet weak var filledInfoLabel: UILabel!
    @IBOutlet weak var idTipLabel: UILabel!
    @IBOutlet weak var idInfoLabel: UILabel!
    @IBOutlet weak var dateTipLabel: UILabel!
    @IBOutlet weak var dateInfoLabel: UILabel!
    
    @IBOutlet weak var seperatorA: UIView!
    @IBOutlet weak var seperatorB: UIView!
    @IBOutlet weak var seperatorC: UIView!
    @IBOutlet weak var seperatorD: UIView!
    @IBOutlet weak var seperatorE: UIView!
    @IBOutlet weak var seperatorF: UIView!
    @IBOutlet weak var seperatorG: UIView!
    
    // Mask view
    var blurVisualEffectView = UIView()
    
    // Drag down to close a present view controller.
    var dismissInteractor = MiniToLargeViewInteractive()
    
    var order: Order?
    
    var tokenSView: TradeViewOnlyViewController = TradeViewOnlyViewController()
    var tokenBView: TradeViewOnlyViewController = TradeViewOnlyViewController()
    
    var marketLabel: UILabel = UILabel()
    var typeLabel: UILabel = UILabel()
    var qrcodeImageView: UIImageView!
    var qrcodeImage: UIImage!
    var amountLabel: UILabel = UILabel()
    var displayLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Order Detail", comment: "")
        setBackButton()
        setupQRCodeButton()
        
        // TokenView
        tokenSView.view.frame = CGRect(x: 0, y: 0, width: tokenS.frame.width, height: tokenS.frame.height)
        tokenS.addSubview(tokenSView.view)
        tokenSView.view.bindFrameToAnotherView(anotherView: tokenS)
        
        tokenBView.view.frame = CGRect(x: 0, y: 0, width: tokenB.frame.width, height: tokenB.frame.height)
        tokenB.addSubview(tokenBView.view)
        tokenBView.view.bindFrameToAnotherView(anotherView: tokenB)
        
        statusTipLabel.setTitleCharFont()
        statusTipLabel.text = LocalizedString("Status", comment: "")
        statusInfoLabel.setTitleDigitFont()
        statusInfoLabel.text = order?.orderStatus.description
        
        amountTipLabel.setTitleCharFont()
        amountTipLabel.text = LocalizedString("Price", comment: "")
        amountInfoLabel.setTitleDigitFont()
        
        lrcFeeTipLabel.setTitleCharFont()
        lrcFeeTipLabel.text = LocalizedString("Trading Fee", comment: "")
        lrcFeeInfoLabel.setTitleDigitFont()
        
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
        
        let seperators = [seperatorA, seperatorB, seperatorC, seperatorD, seperatorE, seperatorF, seperatorG]
        seperators.forEach { $0?.theme_backgroundColor = ColorPicker.cardBackgroundColor }
        
        blurVisualEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        blurVisualEffectView.alpha = 1
        blurVisualEffectView.frame = UIScreen.main.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setup()
    }
    
    func setupQRCodeButton() {
        guard order?.originalOrder.orderType == .p2pOrder && order?.orderStatus == .opened && order?.originalOrder.p2pType == .maker else {
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
            guard P2POrderHistoryDataManager.shared.getOrderDataFromLocal(originalOrder: order.originalOrder) != nil else {
                // TODO: Not sure about the title.
                let title = LocalizedString("The P2P order is not created in this iPhone. You can't share the QR code.", comment: "")
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: LocalizedString("OK", comment: ""), style: .default, handler: { _ in
                    
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let vc = OrderQRCodeViewController()
            vc.originalOrder = order.originalOrder

            vc.transitioningDelegate = self
            vc.modalPresentationStyle = .overFullScreen
            vc.dismissClosure = {
                UIView.animate(withDuration: 0.1, animations: {
                    self.blurVisualEffectView.alpha = 0.0
                }, completion: {(_) in
                    self.blurVisualEffectView.removeFromSuperview()
                })
            }
            
            dismissInteractor.percentThreshold = 0.2
            dismissInteractor.dismissClosure = {
                
            }
            
            self.present(vc, animated: true) {
                self.dismissInteractor.attachToViewController(viewController: vc, withView: vc.view, presentViewController: nil, backgroundView: self.blurVisualEffectView)
            }

            self.navigationController?.view.addSubview(self.blurVisualEffectView)
            UIView.animate(withDuration: 0.2, animations: {
                self.blurVisualEffectView.alpha = 1.0
            }, completion: {(_) in
                
            })
        }
    }
    
    func setup() {
        guard let order = self.order else { return }
        setupTokenViews(order: order)
        setupOrderAmount(order: order)
        setupLRCFee(order: order)
        setupOrderFilled(order: order)
        setupOrderDate(order: order)
    }
    
    func setupLRCFee(order: Order) {
        lrcFeeInfoLabel.text = "\(order.originalOrder.lrcFee.withCommas(3)) LRC"
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

extension OrderDetailViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MiniToLargeViewAnimator()
        animator.transitionType = .Dismiss
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // guard !disableInteractivePlayerTransitioning else { return nil }
        return dismissInteractor
    }

}
