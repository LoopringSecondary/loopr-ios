//
//  OrderDetailViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/12.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var order: Order?
    
    var marketLabel: UILabel = UILabel()
    var typeLabel: UILabel = UILabel()
    var filledPieChart: CircleChart = CircleChart()
    var qrcodeImageView: UIImageView!
    var qrcodeImage: UIImage!
    var amountLabel: UILabel = UILabel()
    var displayLabel: UILabel = UILabel()
    
    // Amount
    var amountTipLabel: UILabel = UILabel()
    var amountInfoLabel: UILabel = UILabel()
    var amountUnderline: UIView = UIView()
    // Status
    var statusTipLabel: UILabel = UILabel()
    var statusInfoLabel: UILabel = UILabel()
    var statusUnderline: UIView = UIView()
    // Total
    var totalTipLabel: UILabel = UILabel()
    var totalInfoLabel: UILabel = UILabel()
    // Trade
    var tradeTipLabel: PaddingLabel = PaddingLabel()
    // Filled
    var filledTipLabel: UILabel = UILabel()
    var filledInfoLabel: UILabel = UILabel()
    var filledUnderline: UIView = UIView()
    // ID
    var idTipLabel: UILabel = UILabel()
    var idInfoLabel: UILabel = UILabel()
    var idUnderline: UIView = UIView()
    // Date
    var dateTipLabel: UILabel = UILabel()
    var dateInfoLabel: UILabel = UILabel()
    var dateUnderline: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = LocalizedString("Order Detail", comment: "")
        setBackButton()
        setupQRCodeButton()
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
            let viewController = OrderQRCodeViewController()
            viewController.order = order.originalOrder
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func setupOrderType(order: Order) {
        if order.originalOrder.side == "buy" {
            typeLabel.backgroundColor = UIColor.black
            typeLabel.textColor = UIColor.white
        } else if order.originalOrder.side == "sell" {
            typeLabel.backgroundColor = UIColor.white
            typeLabel.textColor = UIColor.black
            typeLabel.borderColor = UIColor.gray
        }
        typeLabel.text = order.originalOrder.side.capitalized
        typeLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 20)
        typeLabel.borderWidth = 0.5
        typeLabel.layer.cornerRadius = 6.0
        typeLabel.layer.masksToBounds = true
    }
    
    func setupOrderFilled(order: Order) {
        var percent: Double = 0.0
        if order.originalOrder.side.lowercased() == "sell" {
            percent = order.dealtAmountS / order.originalOrder.amountSell
        } else if order.originalOrder.side.lowercased() == "buy" {
            percent = order.dealtAmountB / order.originalOrder.amountBuy
        }
        filledPieChart.backgroundColor = UIColor.white
        filledPieChart.strokeColor = Themes.isDark() ? UIColor.white.cgColor : UIColor.black.cgColor
        filledPieChart.textColor = Themes.isDark() ? UIColor.white : UIColor.black
        filledPieChart.textFont = UIFont(name: FontConfigManager.shared.getLight(), size: 20.0)!
        filledPieChart.desiredLineWidth = 1.5
        filledPieChart.percentage = CGFloat(percent)
        filledInfoLabel.text = (percent * 100).rounded().description + "%"
    }
    
    func setupOrderAmount(order: Order) {
        if order.originalOrder.side.lowercased() == "sell" {
            amountLabel.text = order.dealtAmountS.description + " " + order.originalOrder.tokenSell
            amountInfoLabel.text = order.dealtAmountS.description + " / " + order.originalOrder.amountSell.description + " " + order.originalOrder.tokenSell
            totalInfoLabel.text = order.originalOrder.amountBuy.description + " " + order.originalOrder.tokenBuy
            if let price = PriceDataManager.shared.getPrice(of: order.originalOrder.tokenSell) {
                let total = price * order.originalOrder.amountSell
                displayLabel.text = total.currency
            }
        } else if order.originalOrder.side.lowercased() == "buy" {
            amountLabel.text = order.dealtAmountB.description + " " + order.originalOrder.tokenBuy
            amountInfoLabel.text = order.dealtAmountB.description + " / " + order.originalOrder.amountBuy.description + " " + order.originalOrder.tokenBuy
            totalInfoLabel.text = order.originalOrder.amountSell.description + " " + order.originalOrder.tokenSell
            if let price = PriceDataManager.shared.getPrice(of: order.originalOrder.tokenBuy) {
                let total = price * order.originalOrder.amountBuy
                displayLabel.text = total.currency
            }
        }
        amountLabel.font = FontConfigManager.shared.getRegularFont(size: 40)
        amountLabel.textColor = Themes.isDark() ? UIColor.white : UIColor.black
        displayLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 20)
        displayLabel.textColor = UIColor.init(white: 0, alpha: 0.6)
    }
    
    func setup() {
        guard let order = self.order else { return }

        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let padding: CGFloat = 15
        let labelHeight: CGFloat = 40
        
        marketLabel.text = order.tradingPairDescription
        marketLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 30)
        marketLabel.textAlignment = .center
        marketLabel.textColor = UIColor.init(white: 0, alpha: 0.6)
        marketLabel.frame = CGRect(x: 0, y: 50, width: screenWidth, height: 40)
        scrollView.addSubview(marketLabel)
        
        setupOrderType(order: order)
        let contendWidth = marketLabel.intrinsicContentSize.width
        typeLabel.textAlignment = .center
        typeLabel.frame = CGRect(x: (screenWidth + contendWidth) / 2 + 5, y: marketLabel.frame.origin.y + 5, width: 40, height: 30)
        scrollView.addSubview(typeLabel)
        
        let circleChartWidth: CGFloat = round(screenWidth*0.3)
        var rect = CGRect(x: (screenWidth - circleChartWidth) / 2, y: marketLabel.frame.maxY + padding, width: circleChartWidth, height: circleChartWidth)
        filledPieChart = CircleChart(frame: rect)
        scrollView.addSubview(filledPieChart)
        setupOrderFilled(order: order)
        
        setupOrderAmount(order: order)
        amountLabel.textAlignment = .center
        amountLabel.frame = CGRect(x: 0, y: filledPieChart.frame.maxY + padding, width: screenWidth, height: 40)
        scrollView.addSubview(amountLabel)
        
        displayLabel.textAlignment = .center
        displayLabel.frame = CGRect(x: 0, y: amountLabel.frame.maxY + padding, width: screenWidth, height: 40)
        scrollView.addSubview(displayLabel)

        // setup rows
        // 1st row: amount
        amountTipLabel.setTitleDigitFont()
        amountTipLabel.text = LocalizedString("Filled/Amount", comment: "")
        amountTipLabel.frame = CGRect(x: padding, y: displayLabel.frame.maxY + padding*3, width: 150, height: labelHeight)
        scrollView.addSubview(amountTipLabel)
        amountInfoLabel.setTitleDigitFont()
        amountInfoLabel.textAlignment = .right
        amountInfoLabel.frame = CGRect(x: padding + 150, y: amountTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: labelHeight)
        scrollView.addSubview(amountInfoLabel)
        amountUnderline.frame = CGRect(x: padding, y: amountTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        amountUnderline.backgroundColor = UIStyleConfig.underlineColor
        scrollView.addSubview(amountUnderline)
        
        // 2nd row: status
        statusTipLabel.setTitleDigitFont()
        statusTipLabel.text = LocalizedString("Status", comment: "")
        statusTipLabel.frame = CGRect(x: padding, y: amountTipLabel.frame.maxY + padding, width: 150, height: labelHeight)
        scrollView.addSubview(statusTipLabel)
        statusInfoLabel.setTitleDigitFont()
        statusInfoLabel.text = order.orderStatus.description
        statusInfoLabel.textAlignment = .right
        statusInfoLabel.frame = CGRect(x: padding + 150, y: statusTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: labelHeight)
        scrollView.addSubview(statusInfoLabel)
        statusUnderline.frame = CGRect(x: padding, y: statusTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        statusUnderline.backgroundColor = UIStyleConfig.underlineColor
        scrollView.addSubview(statusUnderline)
        
        // 3rd row: total
        totalTipLabel.setTitleDigitFont()
        totalTipLabel.text = LocalizedString("Total", comment: "")
        totalTipLabel.frame = CGRect(x: padding, y: statusTipLabel.frame.maxY + padding, width: 150, height: labelHeight)
        scrollView.addSubview(totalTipLabel)
        totalInfoLabel.setTitleDigitFont()
        totalInfoLabel.textAlignment = .right
        totalInfoLabel.frame = CGRect(x: padding + 150, y: totalTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: labelHeight)
        scrollView.addSubview(totalInfoLabel)
        
        // 4th row: trade
        tradeTipLabel.setTitleDigitFont()
        tradeTipLabel.text = LocalizedString("Trade", comment: "")
        tradeTipLabel.backgroundColor = UIStyleConfig.underlineColor
        tradeTipLabel.frame = CGRect(x: 0, y: totalTipLabel.frame.maxY + padding, width: screenWidth, height: labelHeight)
        tradeTipLabel.leftInset = padding
        scrollView.addSubview(tradeTipLabel)
        
        // 5th row: filled
        filledTipLabel.setTitleDigitFont()
        filledTipLabel.text = LocalizedString("Filled", comment: "")
        filledTipLabel.frame = CGRect(x: padding, y: tradeTipLabel.frame.maxY + padding, width: 150, height: labelHeight)
        scrollView.addSubview(filledTipLabel)
        filledInfoLabel.setTitleDigitFont()
        filledInfoLabel.textAlignment = .right
        filledInfoLabel.frame = CGRect(x: padding + 150, y: filledTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: labelHeight)
        scrollView.addSubview(filledInfoLabel)
        filledUnderline.frame = CGRect(x: padding, y: filledTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        filledUnderline.backgroundColor = UIStyleConfig.underlineColor
        scrollView.addSubview(filledUnderline)
        
        // 6th row: ID
        idTipLabel.setTitleDigitFont()
        idTipLabel.text = LocalizedString("ID", comment: "")
        idTipLabel.frame = CGRect(x: padding, y: filledTipLabel.frame.maxY + padding, width: 50, height: labelHeight)
        scrollView.addSubview(idTipLabel)
        idInfoLabel.setTitleDigitFont()
        idInfoLabel.text = order.originalOrder.hash
        idInfoLabel.textAlignment = .right
        idInfoLabel.frame = CGRect(x: padding + 50, y: idTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 50, height: labelHeight)
        scrollView.addSubview(idInfoLabel)
        idUnderline.frame = CGRect(x: padding, y: idTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        idUnderline.backgroundColor = UIStyleConfig.underlineColor
        scrollView.addSubview(idUnderline)
        
        // 7th row: date
        dateTipLabel.setTitleDigitFont()
        dateTipLabel.text = LocalizedString("Time", comment: "")
        dateTipLabel.frame = CGRect(x: padding, y: idTipLabel.frame.maxY + padding, width: 150, height: labelHeight)
        scrollView.addSubview(dateTipLabel)
        dateInfoLabel.setTitleDigitFont()
        
        let time = UInt(order.originalOrder.validSince)
        dateInfoLabel.text = DateUtil.convertToDate(time, format: "yyyy-MM-dd HH:mm")
        dateInfoLabel.textAlignment = .right
        dateInfoLabel.frame = CGRect(x: padding + 150, y: dateTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: labelHeight)
        scrollView.addSubview(dateInfoLabel)
        
        dateUnderline.frame = CGRect(x: padding, y: dateTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        dateUnderline.backgroundColor = UIStyleConfig.underlineColor
        scrollView.addSubview(dateUnderline)
        
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: screenWidth, height: dateTipLabel.frame.maxY + 30)
    }

}
