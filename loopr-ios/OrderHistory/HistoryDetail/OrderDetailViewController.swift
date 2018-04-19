//
//  OrderDetailViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/12.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var marketLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var filledPieChart: CircleChart!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var order: Order?
    
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
    var tradeTipLabel: UILabel = UILabel()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Order Detail", comment: "")
        setBackButton()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupOrderType(order: Order) {
        typeLabel.text = order.originalOrder.side.capitalized
        typeLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 20)
        typeLabel.borderWidth = 0.5
        if order.originalOrder.side == "buy" {
            typeLabel.backgroundColor = UIColor.black
            typeLabel.textColor = UIColor.white
        } else if order.originalOrder.side == "sell" {
            typeLabel.backgroundColor = UIColor.white
            typeLabel.textColor = UIColor.black
            typeLabel.borderColor = UIColor.gray
        }
        typeLabel.layer.cornerRadius = 2.0
        typeLabel.layer.masksToBounds = true
    }
    
    func setupOrderFilled(order: Order) {
        var percent: Double = 0.0
        if order.originalOrder.side.lowercased() == "sell" {
            percent = order.dealtAmountS / order.originalOrder.amountSell
        } else if order.originalOrder.side.lowercased() == "buy" {
            percent = order.dealtAmountB / order.originalOrder.amountBuy
        }
        filledPieChart.theme_backgroundColor = GlobalPicker.backgroundColor
        filledPieChart.strokeColor = Themes.isNight() ? UIColor.white.cgColor : UIColor.black.cgColor
        filledPieChart.textColor = Themes.isNight() ? UIColor.white : UIColor.black
        filledPieChart.textFont = UIFont(name: FontConfigManager.shared.getLight(), size: 20.0)!
        filledPieChart.desiredLineWidth = 1.5
        filledPieChart.percentage = CGFloat(percent)
        filledInfoLabel.text = (percent * 100).rounded().description + "%"
    }
    
    func setupOrderAmount(order: Order) {
        if order.originalOrder.side.lowercased() == "sell" {
            amountLabel.text = order.dealtAmountS.description + " " + order.originalOrder.tokenS
            amountInfoLabel.text = order.dealtAmountS.description + " / " + order.originalOrder.amountSell.description + " " + order.originalOrder.tokenS
            totalInfoLabel.text = order.originalOrder.amountBuy.description + " " + order.originalOrder.tokenB
            if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: order.originalOrder.tokenS) {
                let currencyFormatter = NumberFormatter()
                currencyFormatter.locale = NSLocale.current
                currencyFormatter.usesGroupingSeparator = true
                currencyFormatter.numberStyle = .currency
                let total = price * order.originalOrder.amountSell
                let formattedNumber = currencyFormatter.string(from: NSNumber(value: total)) ?? "\(total)"
                displayLabel.text = formattedNumber
            }
        } else if order.originalOrder.side.lowercased() == "buy" {
            amountLabel.text = order.dealtAmountB.description + " " + order.originalOrder.tokenB
            amountInfoLabel.text = order.dealtAmountB.description + " / " + order.originalOrder.amountBuy.description + " " + order.originalOrder.tokenB
            totalInfoLabel.text = order.originalOrder.amountSell.description + " " + order.originalOrder.tokenS
            if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: order.originalOrder.tokenB) {
                let currencyFormatter = NumberFormatter()
                currencyFormatter.locale = NSLocale.current
                currencyFormatter.usesGroupingSeparator = true
                currencyFormatter.numberStyle = .currency
                let total = price * order.originalOrder.amountBuy
                let formattedNumber = currencyFormatter.string(from: NSNumber(value: total)) ?? "\(total)"
                displayLabel.text = formattedNumber
            }
        }
        amountLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 40)
        amountLabel.textColor = Themes.isNight() ? UIColor.white : UIColor.black
        displayLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 20)
        displayLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    }
    
    func setup() {
        guard let order = self.order else { return }
        // config label
        marketLabel.text = order.tradingPairDescription
        marketLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 30)
        marketLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        setupOrderType(order: order)
        setupOrderFilled(order: order)
        setupOrderAmount(order: order)

        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let padding: CGFloat = 15
        // 1st row: amount
        amountTipLabel.font = FontConfigManager.shared.getLabelFont()
        amountTipLabel.text = NSLocalizedString("Filled/Amount", comment: "")
        amountTipLabel.frame = CGRect(x: padding, y: 50, width: 150, height: 40)
        scrollView.addSubview(amountTipLabel)
        amountInfoLabel.font = FontConfigManager.shared.getLabelFont()
        amountInfoLabel.textAlignment = .right
        amountInfoLabel.frame = CGRect(x: padding + 150, y: amountTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(amountInfoLabel)
        amountUnderline.frame = CGRect(x: padding, y: amountTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        amountUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(amountUnderline)
        
        // 2nd row: status
        statusTipLabel.font = FontConfigManager.shared.getLabelFont()
        statusTipLabel.text = NSLocalizedString("Status", comment: "")
        statusTipLabel.frame = CGRect(x: padding, y: amountTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(statusTipLabel)
        statusInfoLabel.font = FontConfigManager.shared.getLabelFont()
        statusInfoLabel.text = order.orderStatus.description
        statusInfoLabel.textAlignment = .right
        statusInfoLabel.frame = CGRect(x: padding + 150, y: statusTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(statusInfoLabel)
        statusUnderline.frame = CGRect(x: padding, y: statusTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        statusUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(statusUnderline)
        
        // 3rd row: total
        totalTipLabel.font = FontConfigManager.shared.getLabelFont()
        totalTipLabel.text = NSLocalizedString("Total", comment: "")
        totalTipLabel.frame = CGRect(x: padding, y: statusTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(totalTipLabel)
        totalInfoLabel.font = FontConfigManager.shared.getLabelFont()
        totalInfoLabel.textAlignment = .right
        totalInfoLabel.frame = CGRect(x: padding + 150, y: totalTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(totalInfoLabel)
        
        // 4th row: trade
        tradeTipLabel.font = FontConfigManager.shared.getLabelFont()
        tradeTipLabel.text = NSLocalizedString("    Trade", comment: "")
        tradeTipLabel.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        tradeTipLabel.frame = CGRect(x: 0, y: totalTipLabel.frame.maxY + padding, width: screenWidth, height: 40)
        scrollView.addSubview(tradeTipLabel)
        
        // 5th row: filled
        filledTipLabel.font = FontConfigManager.shared.getLabelFont()
        filledTipLabel.text = NSLocalizedString("Filled", comment: "")
        filledTipLabel.frame = CGRect(x: padding, y: tradeTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(filledTipLabel)
        filledInfoLabel.font = FontConfigManager.shared.getLabelFont()
        filledInfoLabel.textAlignment = .right
        filledInfoLabel.frame = CGRect(x: padding + 150, y: filledTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(filledInfoLabel)
        filledUnderline.frame = CGRect(x: padding, y: filledTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        filledUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(filledUnderline)
        
        // 6th row: ID
        idTipLabel.font = FontConfigManager.shared.getLabelFont()
        idTipLabel.text = NSLocalizedString("ID", comment: "")
        idTipLabel.frame = CGRect(x: padding, y: filledTipLabel.frame.maxY + padding, width: 50, height: 40)
        scrollView.addSubview(idTipLabel)
        idInfoLabel.font = FontConfigManager.shared.getLabelFont()
        idInfoLabel.text = order.originalOrder.hash
        idInfoLabel.textAlignment = .right
        idInfoLabel.frame = CGRect(x: padding + 50, y: idTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 50, height: 40)
        scrollView.addSubview(idInfoLabel)
        idUnderline.frame = CGRect(x: padding, y: idTipLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        idUnderline.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        scrollView.addSubview(idUnderline)
        
        // 7th row: date
        dateTipLabel.font = FontConfigManager.shared.getLabelFont()
        dateTipLabel.text = NSLocalizedString("Date", comment: "")
        dateTipLabel.frame = CGRect(x: padding, y: idTipLabel.frame.maxY + padding, width: 150, height: 40)
        scrollView.addSubview(dateTipLabel)
        dateInfoLabel.font = FontConfigManager.shared.getLabelFont()
        dateInfoLabel.text = order.originalOrder.validSince
        dateInfoLabel.textAlignment = .right
        dateInfoLabel.frame = CGRect(x: padding + 150, y: dateTipLabel.frame.origin.y, width: screenWidth - padding * 2 - 150, height: 40)
        scrollView.addSubview(dateInfoLabel)
        
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: screenWidth, height: dateTipLabel.frame.maxY + 30)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
