//
//  MarketLineChartTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/12/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Charts

class MarketLineChartTableViewCell: UITableViewCell {

    var market: Market?
    var trends: [Trend]?
    var interval: String = "1Hr"
    var dateFormat: String = "HH:mm"
    var lowLimit: Double = Double(Int.max)
    var highLimit: Double = Double(Int.min)
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var oneHourButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var twoHourButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var fourHourButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var oneDayButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var oneWeekButton: CustomUIButtonForUIToolbar!

    var pressedBuyButtonClosure: (() -> Void)?
    var pressedSellButtonClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        theme_backgroundColor = GlobalPicker.backgroundColor
        
        refreshTrend()
        
        // interval buttons group
        oneHourButton.selected()
        
        // Sell button
        sellButton.setTitle(NSLocalizedString("Sell", comment: ""), for: .normal)
        sellButton.theme_backgroundColor = ["#000", "#fff"]
        sellButton.theme_setTitleColor(["#fff", "#000"], forState: .normal)

        sellButton.backgroundColor = UIColor.clear
        sellButton.titleColor = UIColor.black
        sellButton.layer.cornerRadius = 23
        sellButton.layer.borderWidth = 0.5
        sellButton.layer.borderColor = UIColor.black.cgColor
        sellButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        
        // Buy button
        buyButton.setTitle(NSLocalizedString("Buy", comment: ""), for: .normal)
        buyButton.theme_backgroundColor = ["#000", "#fff"]
        buyButton.theme_setTitleColor(["#fff", "#000"], forState: .normal)

        buyButton.backgroundColor = UIColor.black
        buyButton.layer.cornerRadius = 23
        buyButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func refreshTrend() {
        if let market = self.market {
//            let pair = market.tradingPair.description
//            if let trends = MarketDataManager.shared.getTrends(market: pair, interval: self.interval) {
            if let trends = self.trends {
                for trend in trends {
                    if self.highLimit < trend.high {
                        self.highLimit = trend.high
                    }
                    if self.lowLimit > trend.low {
                        self.lowLimit = trend.low
                    }
                }
                switch self.interval {
                case "1H", "2H", "4H":
                    self.dateFormat = "HH:mm"
                case "1D", "1W":
                    self.dateFormat = "dd MMM HH:mm"
                default:
                    self.dateFormat = "HH:mm"
                }
                self.drawLineChartView()
            }
        }
    }
    
    func drawLineChartView() {
        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = true
        lineChartView.drawGridBackgroundEnabled = false
        
        lineChartView.xAxis.gridLineDashLengths = [5, 5]
        lineChartView.xAxis.gridLineDashPhase = 0
        lineChartView.xAxis.valueFormatter = DataUtil(format: self.dateFormat) // 这里
        
        let ll1 = ChartLimitLine(limit: self.highLimit, label: "Upper Limit")   // 这里
        ll1.lineWidth = 2
        ll1.lineDashLengths = [5, 5]
        ll1.labelPosition = .rightTop
        ll1.valueFont = .systemFont(ofSize: 10)
        
        let ll2 = ChartLimitLine(limit: self.lowLimit, label: "Lower Limit")  // 这里
        ll2.lineWidth = 2
        ll2.lineDashLengths = [5, 5]
        ll2.labelPosition = .rightBottom
        ll2.valueFont = .systemFont(ofSize: 10)
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.addLimitLine(ll1)
        leftAxis.addLimitLine(ll2)
        leftAxis.axisMaximum = self.highLimit * 1.2 // 这里
        leftAxis.axisMinimum = -0.0002  // 这里
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        lineChartView.rightAxis.enabled = false
        lineChartView.viewPortHandler.setMaximumScaleY(2)
        lineChartView.viewPortHandler.setMaximumScaleX(2)
        lineChartView.legend.enabled = false
        lineChartView.animate(yAxisDuration: 2.5)
        
        setDataCount(trends?.count ?? 0)
        
        for set in lineChartView.data!.dataSets as! [LineChartDataSet] {
            set.mode = .linear
        }
        lineChartView.setNeedsDisplay()
    }
    
    func setDataCount(_ count: Int) {
        let values = trends?.map({ (trend) -> ChartDataEntry in
            let x = trend.start
            let y = trend.close
            return ChartDataEntry(x: Double(x), y: y)
        })
        let set1 = LineChartDataSet(values: values, label: "")
        set1.drawIconsEnabled = false
        
        set1.lineDashLengths = [5, 2.5]
        set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(UIColor(red: 34/255, green: 53/255, blue: 89/255, alpha: 1))
        set1.lineWidth = 1
        //外圆
        set1.setCircleColor(.gray)
        //画外圆
        set1.drawCirclesEnabled = true
        //内圆
        set1.circleHoleColor = NSUIColor.black
        //画内圆
        set1.drawCircleHoleEnabled = true
        
        set1.valueFont = .systemFont(ofSize: 0)
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 15
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        
        let gradientColors = [ChartColorTemplates.colorFromString("#00f0f0f0").cgColor,
                              ChartColorTemplates.colorFromString("#ff080d16").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90)
        // Enable the filled.
        set1.drawFilledEnabled = true
        let data = LineChartData(dataSet: set1)
        lineChartView.data = data
    }

    @IBAction func pressedIntervalButtons(_ sender: CustomUIButtonForUIToolbar) {
        let buttonArray = [oneHourButton, twoHourButton, fourHourButton, oneDayButton, oneWeekButton]
        buttonArray.forEach {
            $0?.unselected()
        }
        sender.selected()
        interval = sender.title!
        refreshTrend()
    }

    @IBAction func pressedSellButton(_ sender: Any) {
        print("pressedSellButton")
        if let btnAction = self.pressedSellButtonClosure {
            btnAction()
        }
    }
    
    @IBAction func pressedBuyButton(_ sender: Any) {
        if let btnAction = self.pressedBuyButtonClosure {
            btnAction()
        }
    }
    
    class func getCellIdentifier() -> String {
        return "MarketLineChartTableViewCell"
    }
    
    class func getHeight(navigationBarHeight: CGFloat = 0) -> CGFloat {
        let screen = UIScreen.main.bounds
        let screenHeight = screen.height
        return screenHeight - navigationBarHeight
    }
}
